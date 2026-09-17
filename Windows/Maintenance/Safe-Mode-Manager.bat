@echo off
setlocal
title Safe Mode Manager

REM Interactive Safe Mode boot manager.
REM Requires Administrator privileges because it modifies BCD settings.

net session >nul 2>&1
if errorlevel 1 (
    echo This script requires Administrator privileges.
    pause
    exit /b 1
)

:menu
cls
echo ==============================================
echo              SAFE MODE MANAGER
echo ==============================================
echo.
echo  1^) Configure next boot: Safe Mode ^(Minimal^)
echo  2^) Configure next boot: Safe Mode with Networking
echo  3^) Return to Normal Boot
echo  4^) Show current safeboot setting
echo  5^) Exit
echo.
set /p "choice=Select an option [1-5]: "

if "%choice%"=="1" goto minimal
if "%choice%"=="2" goto network
if "%choice%"=="3" goto normal
if "%choice%"=="4" goto status
if "%choice%"=="5" exit /b 0
goto menu

:minimal
bcdedit /set {current} safeboot minimal
if errorlevel 1 goto fail
goto rebootPrompt

:network
bcdedit /set {current} safeboot network
if errorlevel 1 goto fail
goto rebootPrompt

:normal
bcdedit /deletevalue {current} safeboot
if errorlevel 1 (
    echo.
    echo No safeboot value was removed. The system may already be configured for normal boot.
)
goto rebootPrompt

:status
echo.
bcdedit /enum {current} | findstr /I "safeboot"
echo.
pause
goto menu

:rebootPrompt
echo.
set /p "reboot=Setting updated. Restart now? [Y/N]: "
if /I "%reboot%"=="Y" shutdown /r /t 0
pause
goto menu

:fail
echo.
echo Failed to update the BCD configuration.
pause
goto menu
