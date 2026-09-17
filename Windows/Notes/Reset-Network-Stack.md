# Reset Windows network stack

Run an elevated PowerShell or Command Prompt.

```cmd
netsh winsock reset
netsh int ip reset C:\resetlog.txt
ipconfig /flushdns
ipconfig /release
ipconfig /renew
```

Restart Windows afterwards.

## Firewall reset (optional, destructive)

```cmd
netsh advfirewall reset
```

This resets Windows Firewall policy/settings. Do not run it casually on a configured system.
