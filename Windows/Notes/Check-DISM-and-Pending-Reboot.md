# Check DISM health and pending reboot state

Run PowerShell as Administrator.

## Pending file rename operations

```powershell
(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
```

If this returns `True`, restart Windows before operations such as cloning or servicing.

## Quick DISM health check

```cmd
DISM /Online /Cleanup-Image /CheckHealth
```

If corruption is reported:

```cmd
DISM /Online /Cleanup-Image /RestoreHealth
```
