@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title L3MON-Revival Launcher

echo.
echo  ============================================
echo       L3MON-Revival - Universal Launcher
echo  ============================================
echo.

node -v >nul 2>&1
if !errorlevel! neq 0 (
    echo [*] Installing Node.js...
    winget install OpenJS.NodeJS -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
)

java -version >nul 2>&1
if !errorlevel! neq 0 (
    echo [*] Installing Java 17...
    winget install Microsoft.OpenJDK.17 -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
)

if not exist node_modules (
    echo [*] Installing npm dependencies...
    call npm install --quiet
)

where pm2 >nul 2>&1
if !errorlevel! neq 0 (
    echo [*] Installing PM2...
    call npm install pm2 -g --quiet
)

echo  [+] All dependencies are ready.
echo.
echo  Select connection method:
echo.
echo   [1] Local Network
echo   [2] Cloudflare Tunnel
echo   [3] Ngrok
echo   [4] Custom URL
echo.
set /p choice="  Your choice [1-4]: "

if "%choice%"=="1" goto :mode_local
if "%choice%"=="2" goto :mode_cloudflare
if "%choice%"=="3" goto :mode_ngrok
if "%choice%"=="4" goto :mode_custom
goto :mode_local

:mode_local
set PUBLIC_URL=127.0.0.1
set TUNNEL_TYPE=local
set TUNNEL_PORT=22222
goto :start_server

:mode_cloudflare
where cloudflared >nul 2>&1
if !errorlevel! neq 0 (
    echo [*] Installing Cloudflare Tunnel...
    winget install Cloudflare.cloudflared -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
)
echo [*] Starting Cloudflare Tunnel on port 22222...
if exist .cf.log del .cf.log
start /b cloudflared tunnel --url http://127.0.0.1:22222 > .cf.log 2>&1
echo [*] Waiting 15 seconds for Cloudflare URL...
timeout /t 15 >nul
set "PUBLIC_URL=TUNNEL_PENDING"
for /f "tokens=*" %%a in ('findstr "trycloudflare.com" .cf.log 2^>nul') do (
    set "CF_LINE=%%a"
)
for %%w in (!CF_LINE!) do (
    echo %%w | findstr "trycloudflare.com" >nul 2>&1
    if !errorlevel! equ 0 set "PUBLIC_URL=%%w"
)
set "PUBLIC_URL=!PUBLIC_URL:https://=!"
set "PUBLIC_URL=!PUBLIC_URL:/=!"
set TUNNEL_TYPE=cloudflare
set TUNNEL_PORT=443
goto :start_server

:mode_ngrok
where ngrok >nul 2>&1
if !errorlevel! neq 0 (
    echo [*] Installing ngrok...
    winget install ngrok.ngrok -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
)
set /p authtoken="  Enter Ngrok Authtoken: "
ngrok config add-authtoken !authtoken! >nul 2>&1
echo [*] Starting Ngrok TCP on port 22222...
if exist .ngrok.log del .ngrok.log
start /b ngrok tcp 22222 --log=stdout > .ngrok.log 2>&1
echo [*] Waiting 10 seconds for Ngrok URL...
timeout /t 10 >nul
set "PUBLIC_URL=TUNNEL_PENDING"
set "TUNNEL_PORT=22222"
for /f "tokens=*" %%a in ('findstr "tcp://" .ngrok.log 2^>nul') do (
    set "NK_LINE=%%a"
)
for %%w in (!NK_LINE!) do (
    echo %%w | findstr "tcp://" >nul 2>&1
    if !errorlevel! equ 0 set "NK_URL=%%w"
)
set "NK_URL=!NK_URL:tcp://=!"
for /f "tokens=1,2 delims=:" %%a in ("!NK_URL!") do (
    set "PUBLIC_URL=%%a"
    set "TUNNEL_PORT=%%b"
)
set TUNNEL_TYPE=ngrok
goto :start_server

:mode_custom
set /p PUBLIC_URL="  Enter custom domain/IP: "
set /p TUNNEL_PORT="  Enter control port [22222]: "
if "!TUNNEL_PORT!"=="" set TUNNEL_PORT=22222
set TUNNEL_TYPE=custom
goto :start_server

:start_server
echo.
echo  ============================================
echo   Tunnel Type  : !TUNNEL_TYPE!
echo   Public URL   : !PUBLIC_URL!
echo   Control Port : !TUNNEL_PORT!
echo   Panel URL    : http://127.0.0.1:22533
echo  ============================================
echo.
echo  [+] Starting L3MON-Revival...
echo  [+] Press Ctrl+C to stop.
echo.

set L3MON_PUBLIC_URL=!PUBLIC_URL!
set L3MON_TUNNEL_TYPE=!TUNNEL_TYPE!
set L3MON_TUNNEL_PORT=!TUNNEL_PORT!

node index.js
pause
