@echo off
setlocal
title Refresh NetBIOS and Open SMB Host

REM Refreshes NetBIOS caches, tests a host by name/IP, and opens its SMB path.
REM Usage:
REM   Refresh-NetBIOS-And-Open-SMB-Host.bat MYPC 192.168.1.10

set "HOST_NAME=%~1"
set "HOST_IP=%~2"

if not defined HOST_NAME set /p "HOST_NAME=Host name: "
if not defined HOST_IP set /p "HOST_IP=IP address (optional): "

if not defined HOST_NAME exit /b 1

echo [1/4] Purging and reloading NetBIOS name cache...
nbtstat -R
nbtstat -c

echo.
echo [2/4] Testing %HOST_NAME%...
ping -n 1 "%HOST_NAME%" >nul
if errorlevel 1 (
    if defined HOST_IP (
        echo Name did not respond. Testing %HOST_IP%...
        ping -n 1 "%HOST_IP%" >nul
        if errorlevel 1 (
            echo Host is not reachable by name or IP.
            pause
            exit /b 1
        )
    ) else (
        echo Host name did not respond and no fallback IP was supplied.
        pause
        exit /b 1
    )
)

echo [3/4] Host is reachable.
echo [4/4] Opening \\%HOST_NAME% ...
start "" "\\%HOST_NAME%"

pause
