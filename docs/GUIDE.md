# Guide

## Requirements

- Windows 10 build 1903 or Windows 11
- PowerShell 5.1 or newer
- Administrator access
- An active network connection

## Setup

Clone the repo or download the ZIP.

```
git clone https://github.com/AntiSourceHub/Windows-Optimizer.git
cd Windows-Optimizer
```

If PowerShell blocks script execution:

```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Running the master script

```
.\scripts\master.ps1
```

This runs NIC tuning, registry tweaks, and performance tuning in that order. It detects your active adapter automatically.

### Flags

- **-Restore** — reverts all changes back to Windows defaults
- **-SkipNIC** — skips the NIC tuning module
- **-SkipRegistry** — skips the registry module
- **-SkipPerformance** — skips the performance module

Example:

```
.\scripts\master.ps1 -SkipRegistry
.\scripts\master.ps1 -Restore
```

## Individual scripts

```
.\scripts\01-NIC-Tuning.ps1
.\scripts\02-Registry-Tweaks.ps1
.\scripts\03-Performance.ps1
```

Each one does one thing. They also accept -Restore.

```
.\scripts\02-Registry-Tweaks.ps1 -Restore
```

## Registry files

If you prefer not to run PowerShell, the registry directory has two files. Open apply-tcp-tweaks.reg in a text editor and replace YOUR_NIC_GUID with the GUID from:

```
Get-NetAdapter | Select-Object Name, InterfaceGuid
```

Then double click the file. The restore-defaults.reg file works the same way.

## Adapter info

```
Get-NetAdapter | Select-Object Name, Status, InterfaceDescription
Get-NetAdapterAdvancedProperty -Name "Wi-Fi" | Format-Table DisplayName, DisplayValue
```

## Verifying changes

```
netsh int tcp show global

$guid = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).InterfaceGuid
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"

ping -n 20 8.8.8.4 | Select-String "Average"
```

## Restoring defaults

```
.\scripts\master.ps1 -Restore
```

If something goes wrong and the script cant help:

```
netsh int ip reset
netsh winsock reset
```

Reboot after restoring.

## AdGuard DNS

Optional but useful for blocking ads at the network level.

```
Set-DnsClientServerAddress -InterfaceIndex `
    (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).ifIndex `
    -ServerAddresses ("94.140.14.14", "94.140.15.15")
```

Or manually through Settings > Network > Wi-Fi > Hardware properties > DNS.

- Primary: 94.140.14.14
- Secondary: 94.140.15.15
