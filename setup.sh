#!/bin/bash

# L3MON - Universal Auto-Setup Script
# Supports: Termux, Ubuntu, Kali Linux, Debian, etc.

echo "------------------------------------------------"
echo "      L3MON - Universal Auto-Installer         "
echo "------------------------------------------------"

# Detect Environment
if [ -d "/data/data/com.termux/files/usr/bin" ]; then
    ENV="TERMUX"
elif [ -f /etc/debian_version ]; then
    ENV="DEBIAN" # Covers Ubuntu, Kali, etc.
else
    ENV="LINUX"
fi

echo "[*] Environment Detected: $ENV"

if [ "$ENV" == "TERMUX" ]; then
    echo "[*] Updating Termux packages..."
    pkg update && pkg upgrade -y
    echo "[*] Installing dependencies (NodeJS, Java, Git)..."
    pkg install nodejs openjdk-17 git -y
elif [ "$ENV" == "DEBIAN" ]; then
    echo "[*] Updating system packages..."
    sudo apt update
    echo "[*] Installing dependencies (NodeJS, Java, Git, npm)..."
    sudo apt install nodejs npm openjdk-17-jdk git -y
else
    echo "[!] Unknown Linux distro. Attempting generic install..."
    # Try apt anyway
    sudo apt update && sudo apt install nodejs npm openjdk-17-jdk git -y
fi

echo "[*] Installing PM2 for process management..."
npm install pm2 -g

echo "[*] Installing L3MON project dependencies..."
npm install

echo "[*] Cleaning up and fixing potential issues..."
npm audit fix --force

# Get IP Address
IP_ADDR=$(hostname -I | awk '{print $1}')
if [ -z "$IP_ADDR" ]; then
    IP_ADDR="127.0.0.1"
fi

echo "------------------------------------------------"
echo "             INSTALLATION COMPLETE              "
echo "------------------------------------------------"
echo "[+] Starting L3MON Server..."
pm2 start index.js --name l3mon

echo ""
echo "================================================"
echo "   L3MON Panel is now running!"
echo "   Access URL: http://$IP_ADDR:22533"
echo "================================================"
echo ""
