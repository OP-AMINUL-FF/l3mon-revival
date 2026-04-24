@echo off
title L3MON Auto-Installer (Windows)
echo ------------------------------------------------
echo      L3MON - Universal Auto-Installer         
echo ------------------------------------------------

:: Check for Node.js
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Node.js not found. Attempting auto-install...
    winget install OpenJS.NodeJS -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    if %errorlevel% neq 0 (
        echo [!] Auto-install failed. Please install Node.js manually.
        pause
        exit /b 1
    )
    echo [+] Node.js installed successfully.
)

:: Check for Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Java not found. Attempting auto-install...
    winget install Microsoft.OpenJDK.17 -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    if %errorlevel% neq 0 (
        winget install Oracle.JDK.17 -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    )
    java -version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [!] Auto-install failed. Please install Java JDK 17 manually.
        pause
        exit /b 1
    )
    echo [+] Java installed successfully.
)

:: Check if node_modules exists
if not exist node_modules (
    echo [*] Installing project dependencies...
    call npm install --quiet
)

:: Check if PM2 is installed
where pm2 >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Installing PM2 globally...
    call npm install pm2 -g --quiet
)

echo ------------------------------------------------
echo             L3MON IS READY
echo ------------------------------------------------
echo [+] Starting L3MON Server...
echo.
echo ================================================
echo    L3MON Panel is now running!
echo    Access URL: http://127.0.0.1:22533
echo    Press Ctrl+C to stop the server
echo ================================================
echo.

node index.js
pause
