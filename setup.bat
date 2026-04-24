@echo off
title L3MON-Revival Launcher
setlocal enabledelayedexpansion
chcp 65001 >nul

echo.
echo  ============================================
echo       L3MON-Revival - Universal Launcher    
echo  ============================================
echo.

:: ---- Dependency Checks ----
node -v >nul 2>&1 || (
    echo [*] Installing Node.js via winget...
    winget install OpenJS.NodeJS -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
)

java -version >nul 2>&1 || (
    echo [*] Installing Java 17 via winget...
    winget install Microsoft.OpenJDK.17 -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    if !errorlevel! neq 0 (
        winget install Oracle.JDK.17 -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    )
)

if not exist node_modules (
    echo [*] Installing npm dependencies...
    call npm install --quiet
)

where pm2 >nul 2>&1 || (
    echo [*] Installing PM2...
    call npm install pm2 -g --quiet
)

echo  [+] All dependencies are ready.
echo.

:: ---- Connection Method Menu ----
echo  Select connection method:
echo.
echo   [1] Local Network  (LAN - No internet required)
echo   [2] Cloudflare Tunnel  (No port forwarding - Recommended)
echo   [3] Ngrok  (Requires free account)
echo   [4] Custom URL  (Enter manually)
echo.
set /p choice="  Your choice [1-4]: "

set PUBLIC_URL=127.0.0.1
set TUNNEL_TYPE=local
set TUNNEL_PORT=22222

:: ---- LOCAL ----
if "%choice%"=="1" (
    set PUBLIC_URL=127.0.0.1
    set TUNNEL_TYPE=local
    set TUNNEL_PORT=22222
    goto :start_server
)

:: ---- CLOUDFLARE ----
if "%choice%"=="2" (
    where cloudflared >nul 2>&1 || (
        echo [*] Installing Cloudflare Tunnel...
        winget install Cloudflare.cloudflared -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
        if !errorlevel! neq 0 (
            echo [*] Trying alternative install via scoop...
            scoop install cloudflared >nul 2>&1
        )
    )
    echo [*] Starting Cloudflare Tunnel on port 22222...
    if exist .cf.log del .cf.log
    start /b cloudflared tunnel --url http://127.0.0.1:22222 > .cf.log 2>&1
    echo [*] Waiting for Cloudflare URL (15 seconds)...
    timeout /t 15 >nul
    set "CF_LINE="
    for /f "delims=" %%a in ('findstr /C:"trycloudflare.com" .cf.log 2^>nul') do (
        set "CF_LINE=%%a"
    )
    :: Extract URL from the line
    for %%a in (!CF_LINE!) do (
        echo %%a | findstr /C:"trycloudflare.com" >nul && set "RAW_URL=%%a"
    )
    set "PUBLIC_URL=!RAW_URL!"
    if "!PUBLIC_URL!"=="" set "PUBLIC_URL=TUNNEL_PENDING"
    set TUNNEL_TYPE=cloudflare
    set TUNNEL_PORT=22222
    goto :start_server
)

:: ---- NGROK ----
if "%choice%"=="3" (
    where ngrok >nul 2>&1 || (
        echo [*] Installing Ngrok via winget...
        winget install ngrok.ngrok -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    )
    set /p authtoken="  Enter Ngrok Authtoken (get from https://dashboard.ngrok.com): "
    ngrok config add-authtoken !authtoken! >nul 2>&1
    echo [*] Starting Ngrok TCP tunnel on port 22222...
    if exist .ngrok.log del .ngrok.log
    start /b ngrok tcp 22222 --log=stdout > .ngrok.log 2>&1
    echo [*] Waiting for Ngrok URL (10 seconds)...
    timeout /t 10 >nul
    set "NGROK_HOST="
    set "NGROK_PORT=22222"
    for /f "tokens=*" %%a in ('findstr /C:"tcp://" .ngrok.log 2^>nul') do (
        set "NGROK_LINE=%%a"
    )
    :: Parse tcp://x.tcp.ngrok.io:PORT
    for %%a in (!NGROK_LINE!) do (
        echo %%a | findstr /C:"tcp://" >nul && set "RAW_NGROK=%%a"
    )
    set "RAW_NGROK=!RAW_NGROK:tcp://=!"
    for /f "tokens=1,2 delims=:" %%a in ("!RAW_NGROK!") do (
        set "NGROK_HOST=%%a"
        set "NGROK_PORT=%%b"
    )
    if "!NGROK_HOST!"=="" set "NGROK_HOST=TUNNEL_PENDING"
    set PUBLIC_URL=!NGROK_HOST!
    set TUNNEL_PORT=!NGROK_PORT!
    set TUNNEL_TYPE=ngrok
    goto :start_server
)

:: ---- CUSTOM ----
if "%choice%"=="4" (
    set /p PUBLIC_URL="  Enter your custom domain/IP (e.g. mydomain.com): "
    set /p TUNNEL_PORT="  Enter control port [default 22222]: "
    if "!TUNNEL_PORT!"=="" set TUNNEL_PORT=22222
    set TUNNEL_TYPE=custom
    goto :start_server
)

echo [!] Invalid choice. Starting in local mode...
set PUBLIC_URL=127.0.0.1
set TUNNEL_TYPE=local
set TUNNEL_PORT=22222

:start_server
echo.
echo  ============================================
echo   Tunnel Type : %TUNNEL_TYPE%
echo   Public URL  : %PUBLIC_URL%
echo   Control Port: %TUNNEL_PORT%
echo   Panel URL   : http://127.0.0.1:22533
echo  ============================================
echo.
echo  [+] Starting L3MON-Revival Server...
echo  [+] Press Ctrl+C to stop.
echo.

set L3MON_PUBLIC_URL=%PUBLIC_URL%
set L3MON_TUNNEL_TYPE=%TUNNEL_TYPE%
set L3MON_TUNNEL_PORT=%TUNNEL_PORT%

node index.js
pause
