@echo off
REM ============================================================================
REM  Acronis Backup Uploader - example local configuration
REM
REM  Normally you do NOT need to edit this file.
REM  Run Acronis-Backup-Uploader.bat and the first-time wizard will create:
REM      Acronis-Upload.config.local.bat
REM
REM  The *.local.bat file is ignored by Git because it can contain private paths
REM  and optional Telegram credentials.
REM ============================================================================

REM Folder containing already-created Acronis .tibx files.
set "LOCAL=D:\Path\To\Acronis Backup"

REM Full path to rclone.exe, or simply "rclone" if it is in PATH.
set "RCLONE_EXE=C:\Path\To\rclone.exe"

REM rclone destinations.
set "REMOTE_FULL=myremote:/Backups/Acronis/Full"
set "REMOTE_INC=myremote:/Backups/Acronis/Incremental"
set "REMOTE_LOG=myremote:/Backups/Acronis/Logs"

REM Local uploader log folder.
set "LOG_DIR=D:\Path\To\Acronis Backup\Uploader-Logs"

REM Console / housekeeping preferences.
set "SHOW_PROGRESS=YES"
set "DELETE_LOCAL_LOGS=YES"
set "LOCAL_LOG_RETENTION_DAYS=7"

REM Remote deletion is intentionally disabled by default.
set "DELETE_REMOTE_BACKUPS=NO"
set "RETENTION_DAYS=30"

REM Optional Telegram notifications.
set "ENABLE_TELEGRAM=NO"
set "TELEGRAM_TOKEN="
set "TELEGRAM_CHAT_ID="
