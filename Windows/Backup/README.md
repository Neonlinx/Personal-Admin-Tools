# Backup tools

## Acronis Backup Uploader

`Acronis-Backup-Uploader.bat` uploads **existing** Acronis `.tibx` files to one or more rclone destinations.

> It does **not** create or start an Acronis backup.

### First run

Run:

```text
Acronis-Backup-Uploader.bat
```

If no local configuration exists, the tool offers two setup methods:

1. **Interactive setup wizard** — answer each question step by step.
2. **Manual configuration** — create the local config from the example template and open it automatically in Notepad.

After either setup method, the tool asks whether to start immediately or exit and run it later.

The interactive wizard asks for:

- local Acronis backup folder;
- `rclone.exe` location;
- FULL backup destination;
- incremental backup destination;
- log destination;
- local log location;
- transfer-progress preference;
- local log retention;
- optional remote backup retention;
- optional Telegram notifications.

The wizard creates:

```text
Acronis-Upload.config.local.bat
```

This file can contain private paths and credentials and is excluded by `.gitignore`.

### Main menu

The tool provides options to:

1. upload backups;
2. test the configuration;
3. edit the local configuration;
4. test rclone destinations;
5. test Telegram notifications;
6. show the current configuration with secrets hidden;
7. open the local log folder;
8. rerun the setup wizard;
9. reset the local configuration.

### Scheduled / unattended mode

For Windows Task Scheduler or another automation system:

```cmd
Acronis-Backup-Uploader.bat --run
```

This bypasses the interactive menu and starts the configured upload directly.

### Safety

Remote deletion is **disabled by default**. If enabled, rclone removes remote `.tibx` files older than the configured retention period.

Before enabling unattended operation, use the built-in configuration and rclone connection tests.

### Standalone use

`Acronis-Backup-Uploader.bat` is self-contained for first-time configuration.
If `Acronis-Upload.config.example.bat` is not present (for example when the BAT
is copied alone to the Desktop), option 2 generates a built-in local template
and opens it in Notepad.

### Configuration editor

When manual configuration is selected, the uploader tries to open the local
configuration in **Notepad++** first. If Notepad++ is not installed in the
standard Program Files locations, it automatically falls back to Windows Notepad.
