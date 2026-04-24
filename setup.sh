#!/bin/bash

echo ""
echo " ============================================"
echo "      L3MON-Revival - Universal Launcher    "
echo " ============================================"
echo ""

export DEBIAN_FRONTEND=noninteractive

# Detect Environment
if [ -d "/data/data/com.termux/files/usr/bin" ]; then
    ENV="TERMUX"
elif [ -f /etc/debian_version ]; then
    ENV="DEBIAN"
else
    ENV="LINUX"
fi

echo " [*] Detected: $ENV"
echo ""

# ---- Install Dependencies ----
if ! command -v node &>/dev/null; then
    echo " [*] Installing Node.js..."
    if [ "$ENV" == "TERMUX" ]; then
        pkg install nodejs -y
    else
        sudo apt-get install -y nodejs npm
    fi
fi

if ! command -v java &>/dev/null; then
    echo " [*] Installing Java..."
    if [ "$ENV" == "TERMUX" ]; then
        pkg install openjdk-17 -y
    else
        sudo apt-get install -y openjdk-17-jdk
    fi
fi

if [ ! -d "node_modules" ]; then
    echo " [*] Installing npm dependencies..."
    npm install --quiet
fi

if ! command -v pm2 &>/dev/null; then
    echo " [*] Installing PM2..."
    npm install pm2 -g --quiet
fi

echo " [+] All dependencies ready."
echo ""

# ---- Connection Method Menu ----
echo " Select connection method:"
echo ""
echo "  [1] Local Network  (LAN)"
echo "  [2] Cloudflare Tunnel  (No port forwarding)"
echo "  [3] Ngrok  (Requires account)"
echo "  [4] Custom URL"
echo ""
read -p "  Your choice [1-4]: " choice

PUBLIC_URL="127.0.0.1"
TUNNEL_TYPE="local"
TUNNEL_PORT="22222"

case $choice in
    1)
        # Get LAN IP
        if [ "$ENV" == "TERMUX" ]; then
            PUBLIC_URL=$(ip route get 1 | awk '{print $7; exit}' 2>/dev/null || echo "127.0.0.1")
        else
            PUBLIC_URL=$(hostname -I | awk '{print $1}')
        fi
        TUNNEL_TYPE="local"
        TUNNEL_PORT="22222"
        ;;
    2)
        # Cloudflare
        if ! command -v cloudflared &>/dev/null; then
            echo " [*] Installing cloudflared..."
            if [ "$ENV" == "TERMUX" ]; then
                pkg install cloudflared -y 2>/dev/null || \
                curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o $PREFIX/bin/cloudflared && chmod +x $PREFIX/bin/cloudflared
            else
                curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
                sudo chmod +x /usr/local/bin/cloudflared
            fi
        fi
        echo " [*] Starting Cloudflare Tunnel..."
        rm -f .cf.log
        cloudflared tunnel --url http://127.0.0.1:22222 > .cf.log 2>&1 &
        CF_PID=$!
        echo " [*] Waiting for Cloudflare URL (15s)..."
        sleep 15
        PUBLIC_URL=$(grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com' .cf.log | tail -1)
        if [ -z "$PUBLIC_URL" ]; then
            PUBLIC_URL="TUNNEL_PENDING"
        fi
        TUNNEL_TYPE="cloudflare"
        TUNNEL_PORT="443"
        ;;
    3)
        # Ngrok
        if ! command -v ngrok &>/dev/null; then
            echo " [*] Installing ngrok..."
            if [ "$ENV" == "TERMUX" ]; then
                pkg install ngrok -y 2>/dev/null || \
                curl -L https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz | tar xz -C $PREFIX/bin
            else
                curl -L https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | sudo tar xz -C /usr/local/bin
            fi
        fi
        read -p "  Enter Ngrok Authtoken: " authtoken
        ngrok config add-authtoken "$authtoken" > /dev/null 2>&1
        echo " [*] Starting Ngrok..."
        rm -f .ngrok.log
        ngrok tcp 22222 --log=stdout > .ngrok.log 2>&1 &
        sleep 10
        NGROK_FULL=$(grep -o 'tcp://[a-zA-Z0-9.:-]*' .ngrok.log | tail -1 | sed 's|tcp://||')
        PUBLIC_URL=$(echo $NGROK_FULL | cut -d: -f1)
        TUNNEL_PORT=$(echo $NGROK_FULL | cut -d: -f2)
        TUNNEL_TYPE="ngrok"
        ;;
    4)
        read -p "  Enter custom domain/IP: " PUBLIC_URL
        read -p "  Enter control port [22222]: " TUNNEL_PORT
        [ -z "$TUNNEL_PORT" ] && TUNNEL_PORT="22222"
        TUNNEL_TYPE="custom"
        ;;
    *)
        echo " [!] Invalid choice. Using local mode."
        PUBLIC_URL="127.0.0.1"
        TUNNEL_TYPE="local"
        TUNNEL_PORT="22222"
        ;;
esac

echo ""
echo " ============================================"
echo "  Tunnel Type : $TUNNEL_TYPE"
echo "  Public URL  : $PUBLIC_URL"
echo "  Control Port: $TUNNEL_PORT"
echo "  Panel URL   : http://127.0.0.1:22533"
echo " ============================================"
echo ""
echo " [+] Starting L3MON-Revival..."
echo " [+] Press Ctrl+C to stop."
echo ""

export L3MON_PUBLIC_URL="$PUBLIC_URL"
export L3MON_TUNNEL_TYPE="$TUNNEL_TYPE"
export L3MON_TUNNEL_PORT="$TUNNEL_PORT"

node index.js
