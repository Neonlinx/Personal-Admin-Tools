# PowerShell execution policy notes

Prefer a temporary per-process bypass when you only need to run a trusted local script:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This affects only the current PowerShell process.

Avoid permanently setting the machine to `Unrestricted` unless you have a specific reason and understand the security implications.

> Security note: do not blindly execute internet-downloaded code through patterns such as `irm <url> | iex`. Download and inspect scripts first.
