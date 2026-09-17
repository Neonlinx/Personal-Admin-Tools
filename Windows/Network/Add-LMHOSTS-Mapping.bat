@echo off
setlocal
title Add LMHOSTS Mapping

REM Adds an IP-to-hostname mapping to the Windows LMHOSTS file.
REM Usage:
REM   Add-LMHOSTS-Mapping.bat 192.168.1.10 MYPC
REM If parameters are omitted, the script asks for them interactively.

net session >nul 2>&1
if errorlevel 1 (
    echo This script requires Administrator privileges.
    pause
    exit /b 1
)

set "HOST_IP=%~1"
set "HOST_NAME=%~2"

if not defined HOST_IP set /p "HOST_IP=IP address: "
if not defined HOST_NAME set /p "HOST_NAME=Host name: "

if not defined HOST_IP exit /b 1
if not defined HOST_NAME exit /b 1

set "LMHOSTS_FILE=%SystemRoot%\System32\drivers\etc\lmhosts"
set "ENTRY=%HOST_IP% %HOST_NAME%"

findstr /I /C:"%ENTRY%" "%LMHOSTS_FILE%" >nul 2>&1
if errorlevel 1 (
    echo %ENTRY%>>"%LMHOSTS_FILE%"
    echo Added: %ENTRY%
) else (
    echo Mapping already exists: %ENTRY%
)

nbtstat -R
nbtstat -c

echo.
echo Done.
pause
