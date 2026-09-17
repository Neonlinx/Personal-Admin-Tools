# Test and repair WMI

Start with the least invasive checks.

```cmd
winmgmt /verifyrepository
```

If the repository is inconsistent, try:

```cmd
winmgmt /salvagerepository
```

Also verify system files:

```cmd
sfc /scannow
```

## Last resort: reset WMI repository

```cmd
winmgmt /resetrepository
```

> Warning: resetting/rebuilding the WMI repository can affect installed software and management providers. Use only after backups and after less invasive repair steps have failed.
