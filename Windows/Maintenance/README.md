# Windows Maintenance Tools

These scripts perform system-wide maintenance and generally require Administrator privileges.

- `Disable-Selected-Windows-Services.bat` and `Restore-Selected-Windows-Services.bat` are designed as a pair. Review the service list before using them on another machine.
- `Post-Windows-Update-Cleanup.bat` contains DISM `/ResetBase`, which is not reversible for superseded component versions.
- `Safe-Mode-Manager.bat` modifies the current BCD safeboot setting.
