# Guide

Admin rights needed. PowerShell 5.1+. Windows 10/11.

## Setup

clone or download the repo. cd into it.

```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## master.ps1

runs all three modules. detects your network adapter automatically.

```
.\scripts\master.ps1
```

### flags

-Restore
-SkipNIC
-SkipRegistry
-SkipPerformance

example:

```
.\scripts\master.ps1 -Restore
```

## individual modules

```
.\scripts\01-NIC-Tuning.ps1
.\scripts\02-Registry-Tweaks.ps1
.\scripts\03-Performance.ps1
```

each one also accepts -Restore.

## finding your adapter

```
Get-NetAdapter | Select-Object Name, InterfaceGuid
```

## verify

```
netsh int tcp show global
ping -n 20 8.8.8.4
```

## reset if something breaks

```
netsh int ip reset
netsh winsock reset
```

reboot after everything.
