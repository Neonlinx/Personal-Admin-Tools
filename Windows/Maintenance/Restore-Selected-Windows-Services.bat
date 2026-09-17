@echo off
setlocal
title Restore Selected Windows Services

REM Restores the service start modes expected by this tool. Requires Administrator privileges.
REM This is paired with Disable-Selected-Windows-Services.bat.

echo Administrator privileges required...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Run this script as Administrator.
    pause
    exit /b
)

echo Restoring selected Windows services...

sc config "DiagTrack" start= demand
sc start "DiagTrack"

sc config "dmwappushservice" start= demand
sc start "dmwappushservice"

sc config "WerSvc" start= demand
sc start "WerSvc"

sc config "PcaSvc" start= demand
sc start "PcaSvc"

sc config "WSearch" start= delayed-auto
sc start "WSearch"

sc config "WbioSrvc" start= demand
sc start "WbioSrvc"

sc config "DPS" start= demand
sc start "DPS"

echo Selected services restored to the configured start modes.
pause
