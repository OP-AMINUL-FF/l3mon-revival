@echo off
title L3MON Auto-Installer (Windows)
echo ------------------------------------------------
echo      L3MON - Universal Auto-Installer         
echo ------------------------------------------------

echo [*] Checking for Node.js...
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Node.js not found! 
    echo [!] Please download and install it from: https://nodejs.org/
    start https://nodejs.org/
    pause
    exit
)

echo [*] Checking for Java...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Java not found!
    echo [!] Please install Java - JDK 11 or 17 recommended.
    start https://www.oracle.com/java/technologies/downloads/
    pause
    exit
)

echo [*] Installing project dependencies...
call npm install

echo [*] Installing PM2...
call npm install pm2 -g

echo ------------------------------------------------
echo             INSTALLATION COMPLETE              
echo ------------------------------------------------
echo [+] Starting L3MON Server...
start /b node index.js

echo.
echo ================================================
echo    L3MON Panel is now running!
echo    Access URL: http://127.0.0.1:22533
echo ================================================
echo.
pause
