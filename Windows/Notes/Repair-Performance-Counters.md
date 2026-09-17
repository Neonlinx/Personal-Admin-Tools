# Repair Windows Performance Counters

Run an elevated Command Prompt.

Rebuild performance counter settings from the system backup store:

```cmd
lodctr /r
```

List provider status:

```cmd
lodctr /q
```

If a required provider is disabled, enable it explicitly:

```cmd
lodctr /e:<provider name>
```

Examples:

```cmd
lodctr /e:NetBT
lodctr /e:Dnscache
```
