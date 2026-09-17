# Personal Admin Tools

A personal collection of Windows administration, diagnostics, maintenance, networking, permissions, registry, and backup utilities.

> **Caution:** several tools require Administrator privileges and some make system-wide or irreversible changes. Read the script comments before running a tool on a different system.

## Repository layout

```text
Windows/
  Backup/        Backup upload and retention utilities
  Diagnostics/   Windows Update, event log and system diagnostics
  Maintenance/   Servicing, service and boot tools
  Network/       DNS, NetBIOS, SMB and connectivity tools
  Notes/         Administration reference notes
  Permissions/   NTFS ownership and ACL tools
  Registry/      Explorer and context-menu registry tweaks
Third-Party/      References to tools authored by others
```

## Tools

| Tool | Category | Admin | Description |
|---|---|---:|---|
| `Acronis-Backup-Uploader.bat` | Backup | No* | Uploads existing Acronis `.tibx` files through rclone; optional retention, Telegram notifications and unattended mode. |
| `Collect-Windows-Logs.ps1` | Diagnostics | Recommended | Collects servicing, Windows Update and Event Log diagnostics into a package. |
| `Get-Windows-Update-Health.ps1` | Diagnostics | Yes | Reports unsuccessful updates, Windows Update events, DISM package states and pending reboot indicators. |
| `Disable-Selected-Windows-Services.bat` | Maintenance | Yes | Disables the curated service set defined inside the script. |
| `Restore-Selected-Windows-Services.bat` | Maintenance | Yes | Restores the service start modes expected by the paired disable script. |
| `Post-Windows-Update-Cleanup.bat` | Maintenance | Yes / auto-elevates | Runs PnP cleanup, DISM/SFC health checks and component cleanup. |
| `Safe-Mode-Manager.bat` | Maintenance | Yes | Configures Safe Mode, Safe Mode with Networking, or returns to normal boot. |
| `Add-LMHOSTS-Mapping.bat` | Network | Yes | Adds an IP/hostname mapping to the Windows LMHOSTS file and refreshes NetBIOS cache. |
| `Network-Toolbox.bat` | Network | Some operations | Menu-driven DNS, adapter, ping, traceroute, routing, ARP, netstat and diagnostic logging toolkit. |
| `Refresh-NetBIOS-And-Open-SMB-Host.bat` | Network | Recommended | Refreshes NetBIOS, checks a host and opens its SMB path. |
| `NTFS-Permissions-Toolkit.ps1` | Permissions | Some operations | Inspects, backs up, restores and modifies NTFS ACLs and ownership. |
| `Add-Admin-Command-Prompt-Here.reg` | Registry | Yes to import | Adds an elevated Command Prompt entry to the directory context menu. |
| `Explorer-NavPane-Expand-Current-Folder-On.reg` | Registry | No | Enables automatic expansion to the current folder in Explorer's navigation pane. |
| `Explorer-NavPane-Expand-Current-Folder-Off.reg` | Registry | No | Disables automatic expansion to the current folder in Explorer's navigation pane. |

`*` Administrator rights are not normally required by the uploader itself, but access to the configured source/destination may depend on local permissions.

## Backup configuration and secrets

`Windows/Backup/Acronis-Backup-Uploader.bat` stores machine-specific settings in:

```text
Acronis-Upload.config.local.bat
```

The first-run wizard can create it interactively or open a template for manual editing. Files matching `*.local.bat` are ignored by Git. Never commit API tokens, passwords, chat IDs or private machine-specific data.

## Third-party tools

Third-party utilities are kept under `Third-Party/Local/` in the local working copy and are ignored by Git unless redistribution rights are confirmed. See `Third-Party/README.md`.

## Notes

- `Post-Windows-Update-Cleanup.bat` uses DISM `/ResetBase`. This makes superseded component versions non-removable and can affect update rollback/uninstall options.
- The selected-services scripts are a paired configuration for a specific curated service list; they are not a generic service-state backup/restore mechanism.
- WMI repository reset and firewall reset commands documented under `Windows/Notes/` should be treated as repair operations, not routine maintenance.
