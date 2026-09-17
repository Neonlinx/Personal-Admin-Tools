@echo off
setlocal
title Disable Selected Windows Services

REM Disables a curated set of Windows services. Requires Administrator privileges.
REM Review the service list below before running on a different system.

echo Administrator privileges required...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Run this script as Administrator.
    pause
    exit /b
)

echo Disabling selected Windows services...

sc stop "DiagTrack"
sc config "DiagTrack" start= disabled

sc stop "dmwappushservice"
sc config "dmwappushservice" start= disabled

sc stop "WerSvc"
sc config "WerSvc" start= disabled

sc stop "PcaSvc"
sc config "PcaSvc" start= disabled

sc stop "WSearch"
sc config "WSearch" start= disabled

sc stop "WbioSrvc"
sc config "WbioSrvc" start= disabled

sc stop "DPS"
sc config "DPS" start= disabled

echo Operation completed.
pause
