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
        exit /b 1
    )
    echo [+] Node.js installed successfully.
) else (
    echo [+] Node.js is already installed.
)

:: Check for Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Java not found. Attempting auto-install via winget...
    
    :: Try Microsoft OpenJDK 17 first (highly reliable)
    winget install Microsoft.OpenJDK.17 -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    
    if %errorlevel% neq 0 (
        :: Try Oracle JDK 17 as fallback
        winget install Oracle.JDK.17 -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    )
    
    if %errorlevel% neq 0 (
        :: Try Eclipse Adoptium Temurin 17 as last resort
        winget install EclipseAdoptium.Temurin.17 -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    )

    java -version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [!] Auto-install failed. Winget could not install Java.
        echo [!] Please install Java JDK 17 manually.
        exit /b 1
    )
    echo [+] Java installed successfully.
) else (
    echo [+] Java is already installed.
)

echo [*] Installing project dependencies...
call npm install --quiet

echo [*] Installing PM2 globally...
call npm install pm2 -g --quiet

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
timeout /t 5
exit
