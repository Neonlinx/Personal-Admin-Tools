@echo off
setlocal DisableDelayedExpansion
title Acronis Backup Uploader

REM ============================================================================
REM  Acronis Backup Uploader - v2.4
REM  Uploads existing Acronis .tibx files through rclone.
REM
REM  IMPORTANT:
REM  - This tool DOES NOT create Acronis backups.
REM  - Personal values and secrets are stored only in:
REM      Acronis-Upload.config.local.bat
REM  - The local config file is excluded from Git by .gitignore.
REM ============================================================================

set "SCRIPT_DIR=%~dp0"
set "CONFIG=%SCRIPT_DIR%Acronis-Upload.config.local.bat"
set "EXAMPLE_CONFIG=%SCRIPT_DIR%Acronis-Upload.config.example.bat"

if /I "%~1"=="--run" goto :ScheduledRun
if /I "%~1"=="--setup" goto :SetupWizard
if /I "%~1"=="--test" goto :TestConfiguration

call :EnsureConfiguration
if errorlevel 2 exit /b 0
if errorlevel 1 exit /b 1
goto :MainMenu


:MainMenu
call :LoadConfiguration
if errorlevel 1 (
    echo.
    echo Press ENTER to return to first-time configuration.
    pause >nul
    goto :FirstRunMenu
)

cls
echo ============================================================================
echo                         ACRONIS BACKUP UPLOADER
echo ============================================================================
echo.
echo  This tool uploads EXISTING Acronis .tibx backup files.
echo  It does NOT create or start an Acronis backup.
echo.
echo  Configuration : OK
echo  Source folder : %LOCAL%
echo  Telegram      : %ENABLE_TELEGRAM%
echo  Remote cleanup: %DELETE_REMOTE_BACKUPS%
if /I "%DELETE_REMOTE_BACKUPS%"=="YES" echo  Retention      : %RETENTION_DAYS% days
echo.
echo ----------------------------------------------------------------------------
echo  [1] Upload backups now
echo  [2] Test configuration
echo  [3] Edit configuration
echo  [4] Test rclone connection
echo  [5] Test Telegram notification
echo  [6] Show current configuration
echo  [7] Open local log folder
echo  [8] Run setup wizard again
echo  [9] Reset local configuration
echo.
echo  [Q] Quit
echo ----------------------------------------------------------------------------
echo.
set "CHOICE="
set /p "CHOICE=Select an option: "

if "%CHOICE%"=="1" call :InteractiveUpload
if "%CHOICE%"=="2" call :TestConfiguration
if "%CHOICE%"=="3" call :EditConfiguration
if "%CHOICE%"=="4" call :TestRcloneConnection
if "%CHOICE%"=="5" call :TestTelegram
if "%CHOICE%"=="6" call :ShowConfiguration
if "%CHOICE%"=="7" call :OpenLogFolder
if "%CHOICE%"=="8" (
    call :SetupWizard
    if errorlevel 1 goto :MainMenu
)
if "%CHOICE%"=="9" call :ResetConfiguration
if /I "%CHOICE%"=="Q" exit /b 0
goto :MainMenu


:EnsureConfiguration
if exist "%CONFIG%" exit /b 0

:FirstRunMenu
cls
echo ============================================================================
echo                       FIRST-TIME CONFIGURATION
echo ============================================================================
echo.
echo No local configuration was found:
echo   %CONFIG%
echo.
echo Choose how you want to configure the uploader:
echo.
echo   [1] Interactive setup wizard
echo       Answer each configuration question step by step.
echo.
echo   [2] Open configuration file
echo       Create a local config and edit it manually in Notepad.
echo.
echo   [Q] Quit
echo.
set "ANSWER="
set /p "ANSWER=Select an option: "

if "%ANSWER%"=="1" (
    call :SetupWizard
    if errorlevel 1 exit /b 1
    if not exist "%CONFIG%" exit /b 1
    call :PostSetupAction
    exit /b %ERRORLEVEL%
)

if "%ANSWER%"=="2" (
    call :CreateAndEditConfiguration
    if errorlevel 1 exit /b 1
    if not exist "%CONFIG%" exit /b 1
    call :PostSetupAction
    exit /b %ERRORLEVEL%
)

if /I "%ANSWER%"=="Q" exit /b 2

echo.
echo Invalid selection.
echo Press ENTER to try again.
pause >nul
goto :FirstRunMenu


:CreateAndEditConfiguration
cls
echo ============================================================================
echo                         MANUAL CONFIGURATION
echo ============================================================================
echo.

if not exist "%CONFIG%" (
    if exist "%EXAMPLE_CONFIG%" (
        copy /y "%EXAMPLE_CONFIG%" "%CONFIG%" >nul
    ) else (
        call :CreateBuiltInConfigTemplate
    )

    if errorlevel 1 (
        echo ERROR: Could not create the local configuration file:
        echo   %CONFIG%
        echo.
        echo Press ENTER to return.
        pause >nul
        exit /b 1
    )
)

echo The local configuration will now open in Notepad++ if available.
echo If Notepad++ is not found, Windows Notepad will be used instead.
echo.
echo Fill in the values, save the file, then close the editor.
echo The local file is ignored by Git and may contain private information.
echo.
echo File:
echo   %CONFIG%
echo.
echo Press ENTER to open it.
pause >nul

if exist "%ProgramFiles%\Notepad++\notepad++.exe" (
    start "" /wait "%ProgramFiles%\Notepad++\notepad++.exe" "%CONFIG%"
) else if exist "%ProgramFiles(x86)%\Notepad++\notepad++.exe" (
    start "" /wait "%ProgramFiles(x86)%\Notepad++\notepad++.exe" "%CONFIG%"
) else (
    start "" /wait notepad.exe "%CONFIG%"
)
exit /b 0


:CreateBuiltInConfigTemplate
REM This embedded template makes the standalone BAT self-contained.
> "%CONFIG%" echo @echo off
>>"%CONFIG%" echo REM Local configuration for Acronis Backup Uploader.
>>"%CONFIG%" echo REM This file may contain private data and must not be committed to Git.
>>"%CONFIG%" echo.
>>"%CONFIG%" echo REM Folder containing already-created Acronis .tibx files.
>>"%CONFIG%" echo set "LOCAL=C:\Path\To\Acronis Backup"
>>"%CONFIG%" echo.
>>"%CONFIG%" echo REM Full path to rclone.exe, or simply rclone if it is in PATH.
>>"%CONFIG%" echo set "RCLONE_EXE=rclone"
>>"%CONFIG%" echo.
>>"%CONFIG%" echo REM rclone destinations.
>>"%CONFIG%" echo set "REMOTE_FULL=myremote:/Backups/Acronis/Full"
>>"%CONFIG%" echo set "REMOTE_INC=myremote:/Backups/Acronis/Incremental"
>>"%CONFIG%" echo set "REMOTE_LOG=myremote:/Backups/Acronis/Logs"
>>"%CONFIG%" echo.
>>"%CONFIG%" echo REM Local uploader log folder.
>>"%CONFIG%" echo set "LOG_DIR=C:\Path\To\Acronis Backup\Uploader-Logs"
>>"%CONFIG%" echo.
>>"%CONFIG%" echo REM Console and housekeeping preferences.
>>"%CONFIG%" echo set "SHOW_PROGRESS=YES"
>>"%CONFIG%" echo set "DELETE_LOCAL_LOGS=YES"
>>"%CONFIG%" echo set "LOCAL_LOG_RETENTION_DAYS=7"
>>"%CONFIG%" echo.
>>"%CONFIG%" echo REM Remote deletion is intentionally disabled by default.
>>"%CONFIG%" echo set "DELETE_REMOTE_BACKUPS=NO"
>>"%CONFIG%" echo set "RETENTION_DAYS=30"
>>"%CONFIG%" echo.
>>"%CONFIG%" echo REM Optional Telegram notifications.
>>"%CONFIG%" echo set "ENABLE_TELEGRAM=NO"
>>"%CONFIG%" echo set "TELEGRAM_TOKEN="
>>"%CONFIG%" echo set "TELEGRAM_CHAT_ID="
exit /b %ERRORLEVEL%


:PostSetupAction
:PostSetupActionPrompt
cls
echo ============================================================================
echo                         CONFIGURATION READY
echo ============================================================================
echo.
echo Local configuration:
echo   %CONFIG%
echo.
set "RUNNOW="
set /p "RUNNOW=Start Acronis Backup Uploader now? [Y/N]: "

if /I "%RUNNOW%"=="Y" exit /b 0

if /I "%RUNNOW%"=="N" (
    echo.
    echo Configuration saved. You can run the uploader whenever you want.
    echo.
    echo Press ENTER to exit.
    pause >nul
    exit /b 2
)

echo.
echo Please answer Y or N.
echo Press ENTER to try again.
pause >nul
goto :PostSetupActionPrompt


:SetupWizard
cls
echo ============================================================================
echo                    ACRONIS BACKUP UPLOADER - SETUP
echo ============================================================================
echo.
echo This wizard creates:
echo   %CONFIG%
echo.
echo Leave a value blank where a default is shown in [brackets].
echo Type CANCEL at any prompt to stop without saving.
echo.

set "LOCAL="
call :PromptRequired "Local folder containing Acronis .tibx files" LOCAL
if errorlevel 1 goto :SetupCancelled

set "RCLONE_EXE="
set /p "RCLONE_EXE=Path to rclone.exe [rclone]: "
if /I "%RCLONE_EXE%"=="CANCEL" goto :SetupCancelled
if not defined RCLONE_EXE set "RCLONE_EXE=rclone"

set "REMOTE_FULL="
call :PromptRequired "rclone destination for FULL backups (example: myremote:/Backups/Acronis/Full)" REMOTE_FULL
if errorlevel 1 goto :SetupCancelled

set "REMOTE_INC="
call :PromptRequired "rclone destination for INCREMENTAL backups" REMOTE_INC
if errorlevel 1 goto :SetupCancelled

set "REMOTE_LOG="
call :PromptRequired "rclone destination for uploader logs" REMOTE_LOG
if errorlevel 1 goto :SetupCancelled

set "LOG_DIR="
set /p "LOG_DIR=Local uploader log folder [SOURCE\Uploader-Logs]: "
if /I "%LOG_DIR%"=="CANCEL" goto :SetupCancelled
if not defined LOG_DIR set "LOG_DIR=%LOCAL%\Uploader-Logs"

echo.
call :PromptYesNo "Show rclone transfer progress in the console?" SHOW_PROGRESS YES
if errorlevel 1 goto :SetupCancelled

echo.
call :PromptYesNo "Delete old LOCAL uploader logs automatically?" DELETE_LOCAL_LOGS YES
if errorlevel 1 goto :SetupCancelled

set "LOCAL_LOG_RETENTION_DAYS=7"
if /I "%DELETE_LOCAL_LOGS%"=="YES" (
    set "LOCAL_LOG_RETENTION_DAYS="
    set /p "LOCAL_LOG_RETENTION_DAYS=Keep local uploader logs for how many days? [7]: "
    if /I "%LOCAL_LOG_RETENTION_DAYS%"=="CANCEL" goto :SetupCancelled
    if not defined LOCAL_LOG_RETENTION_DAYS set "LOCAL_LOG_RETENTION_DAYS=7"
)

echo.
call :PromptYesNo "Delete old REMOTE backup files automatically?" DELETE_REMOTE_BACKUPS NO
if errorlevel 1 goto :SetupCancelled

set "RETENTION_DAYS=30"
if /I "%DELETE_REMOTE_BACKUPS%"=="YES" (
    echo.
    echo WARNING: Remote retention permanently deletes old backup files.
    set "RETENTION_DAYS="
    set /p "RETENTION_DAYS=Delete remote backups older than how many days? [30]: "
    if /I "%RETENTION_DAYS%"=="CANCEL" goto :SetupCancelled
    if not defined RETENTION_DAYS set "RETENTION_DAYS=30"
)

echo.
call :PromptYesNo "Enable Telegram notifications?" ENABLE_TELEGRAM NO
if errorlevel 1 goto :SetupCancelled

set "TELEGRAM_TOKEN="
set "TELEGRAM_CHAT_ID="
if /I "%ENABLE_TELEGRAM%"=="YES" (
    echo.
    echo Telegram credentials are stored ONLY in the local config file ignored by Git.
    call :PromptRequired "Telegram Bot Token" TELEGRAM_TOKEN
    if errorlevel 1 goto :SetupCancelled
    call :PromptRequired "Telegram Chat ID" TELEGRAM_CHAT_ID
    if errorlevel 1 goto :SetupCancelled
)

call :SaveConfiguration
if errorlevel 1 (
    echo.
    echo ERROR: Could not save the configuration.
    echo Press ENTER to return to the main menu.
    pause >nul
    exit /b 1
)

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1

echo.
echo Configuration saved successfully:
echo   %CONFIG%
echo.
echo IMPORTANT:
echo   This file can contain private paths and credentials.
echo   It is intentionally excluded from Git.
echo.
echo Press ENTER to continue.
pause >nul
exit /b 0

:SetupCancelled
echo.
echo Setup cancelled. No configuration changes were saved.
echo Press ENTER to return.
pause >nul
exit /b 1


:PromptRequired
set "%~2="
:PromptRequiredAgain
set /p "%~2=%~1: "
call set "TEMP_VALUE=%%%~2%%"
if /I "%TEMP_VALUE%"=="CANCEL" exit /b 1
if not defined TEMP_VALUE (
    echo A value is required.
    goto :PromptRequiredAgain
)
set "TEMP_VALUE="
exit /b 0


:PromptYesNo
set "%~2="
:PromptYesNoAgain
set /p "%~2=%~1 [Y/N, default %~3]: "
call set "TEMP_VALUE=%%%~2%%"
if /I "%TEMP_VALUE%"=="CANCEL" exit /b 1
if not defined TEMP_VALUE set "TEMP_VALUE=%~3"
if /I "%TEMP_VALUE%"=="Y" set "TEMP_VALUE=YES"
if /I "%TEMP_VALUE%"=="N" set "TEMP_VALUE=NO"
if /I not "%TEMP_VALUE%"=="YES" if /I not "%TEMP_VALUE%"=="NO" (
    echo Please answer Y or N.
    set "TEMP_VALUE="
    goto :PromptYesNoAgain
)
set "%~2=%TEMP_VALUE%"
set "TEMP_VALUE="
exit /b 0


:SaveConfiguration
REM PowerShell writes the config so values containing common shell metacharacters
REM are not accidentally interpreted by CMD while the file is being generated.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p=$env:CONFIG;" ^
  "$lines=@(" ^
  "'@echo off'," ^
  "'REM Local configuration for Acronis Backup Uploader.'," ^
  "'REM This file may contain private paths or credentials and must not be committed to Git.'," ^
  "''," ^
  "'set ""LOCAL=' + $env:LOCAL + '""'," ^
  "'set ""RCLONE_EXE=' + $env:RCLONE_EXE + '""'," ^
  "'set ""REMOTE_FULL=' + $env:REMOTE_FULL + '""'," ^
  "'set ""REMOTE_INC=' + $env:REMOTE_INC + '""'," ^
  "'set ""REMOTE_LOG=' + $env:REMOTE_LOG + '""'," ^
  "'set ""LOG_DIR=' + $env:LOG_DIR + '""'," ^
  "''," ^
  "'set ""SHOW_PROGRESS=' + $env:SHOW_PROGRESS + '""'," ^
  "'set ""DELETE_LOCAL_LOGS=' + $env:DELETE_LOCAL_LOGS + '""'," ^
  "'set ""LOCAL_LOG_RETENTION_DAYS=' + $env:LOCAL_LOG_RETENTION_DAYS + '""'," ^
  "'set ""DELETE_REMOTE_BACKUPS=' + $env:DELETE_REMOTE_BACKUPS + '""'," ^
  "'set ""RETENTION_DAYS=' + $env:RETENTION_DAYS + '""'," ^
  "''," ^
  "'set ""ENABLE_TELEGRAM=' + $env:ENABLE_TELEGRAM + '""'," ^
  "'set ""TELEGRAM_TOKEN=' + $env:TELEGRAM_TOKEN + '""'," ^
  "'set ""TELEGRAM_CHAT_ID=' + $env:TELEGRAM_CHAT_ID + '""'" ^
  "); Set-Content -LiteralPath $p -Value $lines -Encoding ASCII"
exit /b %ERRORLEVEL%


:LoadConfiguration
if not exist "%CONFIG%" (
    echo ERROR: Local configuration not found:
    echo   %CONFIG%
    exit /b 1
)
call "%CONFIG%"
if not defined RCLONE_EXE set "RCLONE_EXE=rclone"
if not defined LOG_DIR set "LOG_DIR=%LOCAL%\Uploader-Logs"
if not defined SHOW_PROGRESS set "SHOW_PROGRESS=YES"
if not defined DELETE_LOCAL_LOGS set "DELETE_LOCAL_LOGS=YES"
if not defined LOCAL_LOG_RETENTION_DAYS set "LOCAL_LOG_RETENTION_DAYS=7"
if not defined DELETE_REMOTE_BACKUPS set "DELETE_REMOTE_BACKUPS=NO"
if not defined RETENTION_DAYS set "RETENTION_DAYS=30"
if not defined ENABLE_TELEGRAM set "ENABLE_TELEGRAM=NO"
exit /b 0


:InteractiveUpload
call :LoadConfiguration
cls
echo ============================================================================
echo                            UPLOAD BACKUPS
echo ============================================================================
echo.
echo Source:
echo   %LOCAL%
echo.
echo Destinations:
echo   FULL        %REMOTE_FULL%
echo   INCREMENTAL %REMOTE_INC%
echo   LOGS        %REMOTE_LOG%
echo.
echo This tool will NOT create a backup. It only uploads existing .tibx files.
echo.
if /I "%DELETE_REMOTE_BACKUPS%"=="YES" (
    echo WARNING: Remote files older than %RETENTION_DAYS% days will be deleted.
    echo.
)
set "ANSWER="
set /p "ANSWER=Start upload now? [Y/N]: "
if /I not "%ANSWER%"=="Y" exit /b 0

call :RunUpload
echo.
echo Press ENTER to return to the main menu.
pause >nul
exit /b 0


:ScheduledRun
if not exist "%CONFIG%" (
    echo ERROR: Scheduled mode requires an existing local configuration:
    echo   %CONFIG%
    exit /b 1
)
if not exist "%CONFIG%" (
    echo ERROR: Scheduled mode requires an existing local configuration:
    echo   %CONFIG%
    exit /b 1
)
call :LoadConfiguration
call :RunUpload
exit /b %ERRORLEVEL%


:RunUpload
call :ValidateConfiguration
if errorlevel 1 exit /b 1

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1

for /f %%D in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TIMESTAMP=%%D"
set "LOGFILE=%LOG_DIR%\Acronis-Upload_%TIMESTAMP%.log"
set "ERRORFLAG=0"
set "PROGRESS_SWITCH="
if /I "%SHOW_PROGRESS%"=="YES" set "PROGRESS_SWITCH=--progress"

echo ============================================================================
echo                           ACRONIS BACKUP UPLOAD
echo ============================================================================
echo Started : %DATE% %TIME%
echo Log     : %LOGFILE%
echo.

echo [1/5] Upload FULL backups...
"%RCLONE_EXE%" copy "%LOCAL%" "%REMOTE_FULL%" --filter "+ *Full*.tibx" --filter "- *" %PROGRESS_SWITCH% --log-file "%LOGFILE%" --log-level INFO
if errorlevel 1 set "ERRORFLAG=1"

echo.
echo [2/5] Upload INCREMENTAL backups...
"%RCLONE_EXE%" copy "%LOCAL%" "%REMOTE_INC%" --filter "- *Full*.tibx" --filter "+ *.tibx" --filter "- *" %PROGRESS_SWITCH% --log-file "%LOGFILE%" --log-level INFO
if errorlevel 1 set "ERRORFLAG=1"

echo.
echo [3/5] Upload uploader log...
"%RCLONE_EXE%" copyto "%LOGFILE%" "%REMOTE_LOG%/Acronis-Upload_%TIMESTAMP%.log" %PROGRESS_SWITCH% --log-file "%LOGFILE%" --log-level INFO
if errorlevel 1 set "ERRORFLAG=1"

echo.
echo [4/5] Local log retention...
if /I "%DELETE_LOCAL_LOGS%"=="YES" (
    forfiles /p "%LOG_DIR%" /m Acronis-Upload_*.log /d -%LOCAL_LOG_RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1
    echo Old local logs: cleanup requested ^(older than %LOCAL_LOG_RETENTION_DAYS% days^).
) else (
    echo Local log cleanup disabled.
)

echo.
echo [5/5] Remote backup retention...
if /I "%DELETE_REMOTE_BACKUPS%"=="YES" (
    echo Deleting remote FULL backups older than %RETENTION_DAYS% days...
    "%RCLONE_EXE%" delete "%REMOTE_FULL%" --min-age %RETENTION_DAYS%d --include "*.tibx" --log-file "%LOGFILE%" --log-level INFO
    if errorlevel 1 set "ERRORFLAG=1"

    echo Deleting remote INCREMENTAL backups older than %RETENTION_DAYS% days...
    "%RCLONE_EXE%" delete "%REMOTE_INC%" --min-age %RETENTION_DAYS%d --include "*.tibx" --log-file "%LOGFILE%" --log-level INFO
    if errorlevel 1 set "ERRORFLAG=1"
) else (
    echo Remote backup deletion disabled.
)

echo.
if "%ERRORFLAG%"=="0" (
    echo RESULT: SUCCESS
) else (
    echo RESULT: ERROR - check the log file.
)

if /I "%ENABLE_TELEGRAM%"=="YES" call :SendTelegramResult "%ERRORFLAG%" "%TIMESTAMP%"

echo.
echo Finished: %DATE% %TIME%
exit /b %ERRORFLAG%


:ValidateConfiguration
set "VALIDATION_ERROR=0"

if not defined LOCAL (
    echo ERROR: LOCAL is not configured.
    set "VALIDATION_ERROR=1"
)
if not defined REMOTE_FULL (
    echo ERROR: REMOTE_FULL is not configured.
    set "VALIDATION_ERROR=1"
)
if not defined REMOTE_INC (
    echo ERROR: REMOTE_INC is not configured.
    set "VALIDATION_ERROR=1"
)
if not defined REMOTE_LOG (
    echo ERROR: REMOTE_LOG is not configured.
    set "VALIDATION_ERROR=1"
)
if not exist "%LOCAL%" (
    echo ERROR: Local backup folder not found:
    echo   %LOCAL%
    set "VALIDATION_ERROR=1"
)

"%RCLONE_EXE%" version >nul 2>&1
if errorlevel 1 (
    echo ERROR: rclone could not be started:
    echo   %RCLONE_EXE%
    set "VALIDATION_ERROR=1"
)

if /I "%ENABLE_TELEGRAM%"=="YES" (
    if not defined TELEGRAM_TOKEN (
        echo ERROR: Telegram is enabled but TELEGRAM_TOKEN is empty.
        set "VALIDATION_ERROR=1"
    )
    if not defined TELEGRAM_CHAT_ID (
        echo ERROR: Telegram is enabled but TELEGRAM_CHAT_ID is empty.
        set "VALIDATION_ERROR=1"
    )
)

if "%VALIDATION_ERROR%"=="1" exit /b 1
exit /b 0


:TestConfiguration
call :LoadConfiguration
cls
echo ============================================================================
echo                         TEST CONFIGURATION
echo ============================================================================
echo.
call :ValidateConfiguration
if errorlevel 1 (
    echo.
    echo Configuration test: FAILED
) else (
    echo Configuration test: BASIC CHECKS PASSED
    echo.
    echo This test validates local settings and rclone availability.
    echo Use option 4 to test access to the configured remote destinations.
)
echo.
echo Press ENTER to return to the main menu.
pause >nul
exit /b 0


:EditConfiguration
call :LoadConfiguration
if not exist "%CONFIG%" exit /b 1
start "" /wait notepad.exe "%CONFIG%"
call :LoadConfiguration
exit /b 0


:TestRcloneConnection
call :LoadConfiguration
cls
echo ============================================================================
echo                        TEST RCLONE CONNECTION
echo ============================================================================
echo.
"%RCLONE_EXE%" version
if errorlevel 1 (
    echo.
    echo ERROR: rclone could not be started.
    goto :TestRcloneDone
)

echo.
echo [1/3] FULL destination:
echo   %REMOTE_FULL%
"%RCLONE_EXE%" lsf "%REMOTE_FULL%" --max-depth 1 >nul
if errorlevel 1 (echo   FAILED) else (echo   OK)

echo.
echo [2/3] INCREMENTAL destination:
echo   %REMOTE_INC%
"%RCLONE_EXE%" lsf "%REMOTE_INC%" --max-depth 1 >nul
if errorlevel 1 (echo   FAILED) else (echo   OK)

echo.
echo [3/3] LOG destination:
echo   %REMOTE_LOG%
"%RCLONE_EXE%" lsf "%REMOTE_LOG%" --max-depth 1 >nul
if errorlevel 1 (echo   FAILED) else (echo   OK)

:TestRcloneDone
echo.
echo Press ENTER to return to the main menu.
pause >nul
exit /b 0


:TestTelegram
call :LoadConfiguration
cls
echo ============================================================================
echo                       TEST TELEGRAM NOTIFICATION
echo ============================================================================
echo.
if /I not "%ENABLE_TELEGRAM%"=="YES" (
    echo Telegram notifications are disabled.
    echo Run the setup wizard or edit the configuration to enable them.
    goto :TestTelegramDone
)

if not defined TELEGRAM_TOKEN (
    echo ERROR: Telegram token is missing.
    goto :TestTelegramDone
)
if not defined TELEGRAM_CHAT_ID (
    echo ERROR: Telegram chat ID is missing.
    goto :TestTelegramDone
)

echo Sending a test message...
curl.exe -s -f -X POST "https://api.telegram.org/bot%TELEGRAM_TOKEN%/sendMessage" ^
    --data-urlencode "chat_id=%TELEGRAM_CHAT_ID%" ^
    --data-urlencode "text=Acronis Backup Uploader test - %COMPUTERNAME% - %DATE% %TIME%" >nul 2>&1

if errorlevel 1 (
    echo FAILED - Telegram API returned an error.
) else (
    echo SUCCESS - test message sent.
)

:TestTelegramDone
echo.
echo Press ENTER to return to the main menu.
pause >nul
exit /b 0


:SendTelegramResult
set "RESULT_CODE=%~1"
set "RESULT_TIME=%~2"
if "%RESULT_CODE%"=="0" (
    set "TG_TEXT=Acronis upload completed successfully - %COMPUTERNAME% - %RESULT_TIME%"
) else (
    set "TG_TEXT=Acronis upload ERROR - check uploader log - %COMPUTERNAME% - %RESULT_TIME%"
)

curl.exe -s -f -X POST "https://api.telegram.org/bot%TELEGRAM_TOKEN%/sendMessage" ^
    --data-urlencode "chat_id=%TELEGRAM_CHAT_ID%" ^
    --data-urlencode "text=%TG_TEXT%" >nul 2>&1
exit /b 0


:ShowConfiguration
call :LoadConfiguration
cls
echo ============================================================================
echo                        CURRENT CONFIGURATION
echo ============================================================================
echo.
echo Local backup folder       : %LOCAL%
echo rclone executable         : %RCLONE_EXE%
echo FULL destination          : %REMOTE_FULL%
echo INCREMENTAL destination   : %REMOTE_INC%
echo Remote log destination    : %REMOTE_LOG%
echo Local log folder          : %LOG_DIR%
echo.
echo Show transfer progress    : %SHOW_PROGRESS%
echo Delete old local logs     : %DELETE_LOCAL_LOGS%
echo Local log retention       : %LOCAL_LOG_RETENTION_DAYS% days
echo Delete old remote backups : %DELETE_REMOTE_BACKUPS%
echo Remote retention          : %RETENTION_DAYS% days
echo.
echo Telegram notifications    : %ENABLE_TELEGRAM%
if /I "%ENABLE_TELEGRAM%"=="YES" (
    echo Telegram Bot Token     : [CONFIGURED - HIDDEN]
    echo Telegram Chat ID       : [CONFIGURED - HIDDEN]
) else (
    echo Telegram Bot Token     : [NOT USED]
    echo Telegram Chat ID       : [NOT USED]
)
echo.
echo Local config file:
echo   %CONFIG%
echo.
echo Press ENTER to return to the main menu.
pause >nul
exit /b 0


:OpenLogFolder
call :LoadConfiguration
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
start "" explorer.exe "%LOG_DIR%"
exit /b 0


:ResetConfiguration
cls
echo ============================================================================
echo                         RESET CONFIGURATION
echo ============================================================================
echo.
echo This will DELETE the local configuration file:
echo   %CONFIG%
echo.
echo It will NOT delete backups, logs or remote files.
echo.
set "ANSWER="
set /p "ANSWER=Type RESET to continue: "
if /I not "%ANSWER%"=="RESET" exit /b 0

del /q "%CONFIG%" >nul 2>&1
if exist "%CONFIG%" (
    echo.
    echo ERROR: The configuration file could not be deleted.
) else (
    echo.
    echo Local configuration deleted.
)
echo.
echo Press ENTER to return to the main menu.
pause >nul
exit /b 0
