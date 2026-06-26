# Windows Optimizer -- Usage Guide

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Running the Scripts](#running-the-scripts)
- [Available Parameters](#available-parameters)
- [Configuration](#configuration)
- [Verification](#verification)
- [Restoring Defaults](#restoring-defaults)
- [Performance Expectations](#performance-expectations)

## Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Operating System | Windows 10 Build 1903 | Windows 11 23H2+ |
| PowerShell | 5.1 | 7.x |
| CPU | 2 cores | 4+ cores |
| RAM | 4 GB | 8+ GB |
| Network | Active adapter | Wi-Fi 6 or Gigabit Ethernet |
| Privileges | Administrator | Administrator |

## Installation

### Git

```powershell
git clone https://github.com/yourusername/Windows-Optimizer.git
cd Windows-Optimizer
```

### Download ZIP

1. Click **Code > Download ZIP** on the GitHub repository page
2. Extract to any location (e.g., `C:\Tools\Windows-Optimizer`)

## Running the Scripts

All scripts must be executed with Administrator privileges. Use one of the
following methods to open an elevated PowerShell session:

- Press **Win + X** and select **Windows Terminal (Admin)**
- Press **Win**, type `PowerShell`, then click **Run as Administrator**
- Press **Win + R**, type `powershell`, then press **Ctrl + Shift + Enter**

### Master Script

The master script (`scripts\master.ps1`) runs all three optimization modules in
sequence with automatic adapter detection and error handling.

```powershell
cd C:\path\to\Windows-Optimizer
.\scripts\master.ps1
```

### Individual Modules

```powershell
.\scripts\01-NIC-Tuning.ps1
.\scripts\02-Registry-Tweaks.ps1
.\scripts\03-Performance.ps1
```

It is safe to run individual modules in any order. Each module is self-contained.

### Execution Policy

If PowerShell blocks script execution, bypass the execution policy for the
current session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Available Parameters

### Master Script

| Parameter | Description |
|-----------|-------------|
| `-Restore` | Reverts all changes to Windows defaults |
| `-SkipNIC` | Skips NIC Tuning module |
| `-SkipRegistry` | Skips Registry Tweaks module |
| `-SkipPerformance` | Skips Performance Tuning module |

**Examples:**

```powershell
# Run only NIC and Performance modules
.\scripts\master.ps1 -SkipRegistry

# Restore all settings to defaults
.\scripts\master.ps1 -Restore
```

### Individual Scripts

Each module accepts a single parameter:

```powershell
.\scripts\01-NIC-Tuning.ps1 -Restore
```

## Configuration

### Finding Your Adapter Name

```powershell
Get-NetAdapter | Select-Object Name, Status, InterfaceDescription
```

### Finding Your Adapter GUID

```powershell
Get-NetAdapter | Select-Object Name, InterfaceGuid
```

### Viewing Current NIC Properties

```powershell
Get-NetAdapterAdvancedProperty -Name "Wi-Fi" | Format-Table DisplayName, DisplayValue
```

### Setting DNS to AdGuard (Optional)

```powershell
Set-DnsClientServerAddress -InterfaceIndex `
    (Get-NetAdapter -Name "Wi-Fi").ifIndex `
    -ServerAddresses ("94.140.14.14", "94.140.15.15")
```

Manual configuration:
1. Open **Settings > Network & Internet > Wi-Fi**
2. Click **Hardware properties** then **Edit** (next to DNS)
3. Select **Manual**
4. Set Preferred DNS to `94.140.14.14` with encryption **Encrypted only (DNS over HTTPS)**
5. Set Alternate DNS to `94.140.15.15`

## Verification

### Network Latency

```powershell
# Continuous ping (Ctrl+C to stop)
ping -t 8.8.8.4

# 20-packet latency test
ping -n 20 8.8.8.4 | Select-String "Average"
```

### NIC Settings

```powershell
Get-NetAdapterAdvancedProperty -Name "Wi-Fi" | Format-Table DisplayName, DisplayValue -AutoSize
```

### Registry Changes

```powershell
$guid = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).InterfaceGuid
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
```

### TCP/IP Stack

```powershell
netsh int tcp show global
```

## Restoring Defaults

The master script reverts all changes when called with the `-Restore` flag:

```powershell
.\scripts\master.ps1 -Restore
```

Individual restore is also supported:

```powershell
.\scripts\01-NIC-Tuning.ps1 -Restore
.\scripts\02-Registry-Tweaks.ps1 -Restore
.\scripts\03-Performance.ps1 -Restore
```

For a complete network stack reset:

```powershell
netsh int ip reset
netsh winsock reset
```

> [!NOTE]
> Restoring defaults and resetting the network stack both require a system
> restart.

## Performance Expectations

### Before Optimization

```
Ping: 45-80 ms (fluctuating)
Packet Loss: 1-3%
Jitter: 5-15 ms
```

### After Optimization

```
Ping: 20-35 ms (stable)
Packet Loss: 0%
Jitter: 1-3 ms
```

> [!TIP]
> Actual results depend on your network hardware, ISP, and environmental
> conditions. Wi-Fi connections are subject to more variability than wired
> Ethernet.

## Support

- Consult the [FAQ](FAQ.md) for common issues
- Open an issue on the GitHub repository
