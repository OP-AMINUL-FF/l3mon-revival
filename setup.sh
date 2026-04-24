#!/bin/bash

# L3MON - Universal Auto-Setup Script (Fully Automatic)
# Supports: Termux, Ubuntu, Kali Linux, Debian, etc.

echo "------------------------------------------------"
echo "      L3MON - Universal Auto-Installer         "
echo "------------------------------------------------"

# Non-interactive mode for APT
export DEBIAN_FRONTEND=noninteractive

# Detect Environment
if [ -d "/data/data/com.termux/files/usr/bin" ]; then
    ENV="TERMUX"
elif [ -f /etc/debian_version ]; then
    ENV="DEBIAN"
else
    ENV="LINUX"
fi

echo "[*] Environment Detected: $ENV"

if [ "$ENV" == "TERMUX" ]; then
    echo "[*] Updating Termux packages (Auto)..."
    pkg update -y && pkg upgrade -y
    echo "[*] Installing dependencies (NodeJS, Java, Git) - Auto..."
    pkg install nodejs openjdk-17 git -y
elif [ "$ENV" == "DEBIAN" ]; then
    echo "[*] Updating system packages (Auto)..."
    sudo apt-get update -y
    echo "[*] Installing dependencies (NodeJS, Java, Git, npm) - Auto..."
    sudo apt-get install -y nodejs npm openjdk-17-jdk git
else
    echo "[!] Unknown Linux distro. Attempting generic auto-install..."
    sudo apt-get update -y && sudo apt-get install -y nodejs npm openjdk-17-jdk git
fi

echo "[*] Installing PM2 globally..."
npm install pm2 -g --quiet

echo "[*] Installing L3MON project dependencies..."
npm install --quiet

# Get IP Address
IP_ADDR=$(hostname -I | awk '{print $1}')
if [ -z "$IP_ADDR" ]; then
    IP_ADDR="127.0.0.1"
fi

echo "------------------------------------------------"
echo "             INSTALLATION COMPLETE              "
echo "------------------------------------------------"
echo "[+] Starting L3MON Server..."
pm2 delete l3mon 2>/dev/null || true
pm2 start index.js --name l3mon

echo ""
echo "================================================"
echo "   L3MON Panel is now running!"
echo "   Access URL: http://$IP_ADDR:22533"
echo "================================================"
echo ""
