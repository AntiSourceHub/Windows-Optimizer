# Windows Optimizer

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PowerShell: 5.1+](https://img.shields.io/badge/PowerShell-5.1+-purple.svg)](https://learn.microsoft.com/powershell/)
[![Platform: Windows 10/11](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078d4.svg)](https://www.microsoft.com/windows)
[![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-grey.svg)](CHANGELOG.md)

A collection of PowerShell scripts and registry configurations that optimize
the network stack, TCP/IP parameters, and system responsiveness on Windows 10
and Windows 11. Designed for latency-sensitive applications including gaming,
streaming, and real-time communications.

## Structure

```
Windows-Optimizer/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── .gitignore
├── scripts/
│   ├── master.ps1
│   ├── 01-NIC-Tuning.ps1
│   ├── 02-Registry-Tweaks.ps1
│   └── 03-Performance.ps1
├── registry/
│   ├── apply-tcp-tweaks.reg
│   └── restore-defaults.reg
└── docs/
    ├── GUIDE.md
    └── FAQ.md
```

## Features

### Network Adapter
Disables power-saving features that degrade connection stability: Wake-on-LAN,
packet coalescing, ARP/NS/GTK offloads for WoWLAN. Sets MIMO power save to
disabled, preferred band to 5 GHz, and roaming aggressiveness to lowest.

### TCP/IP Stack
Disables Nagle's Algorithm and Delayed ACK to reduce latency. Enables Explicit
Congestion Notification (ECN). Configures Multimedia Class Scheduler Service
(MMCSS) to reduce background CPU reservation from 20% to 10%.

### System
Disables NIC power management and NetBIOS over TCP/IP. Configures Receive Side
Scaling (RSS) for multi-core processors when supported.

## Requirements

- Windows 10 (Build 1903+) or Windows 11
- Administrator privileges
- PowerShell 5.1 or later
- Active network adapter (Wi-Fi or Ethernet)

## Usage

All scripts require elevated privileges. Open PowerShell as Administrator before
executing any commands.

### Master Script

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\master.ps1
```

### Individual Modules

```powershell
.\scripts\01-NIC-Tuning.ps1
.\scripts\02-Registry-Tweaks.ps1
.\scripts\03-Performance.ps1
```

### Skip Specific Modules

```powershell
.\scripts\master.ps1 -SkipRegistry -SkipPerformance
```

### Restore Defaults

```powershell
.\scripts\master.ps1 -Restore
```

Individual modules also accept the `-Restore` flag.
Restore registry files are available in `registry/restore-defaults.reg`.

### Registry Files

Replace `YOUR_NIC_GUID` in `registry/apply-tcp-tweaks.reg` with your adapter's
GUID, then double-click to apply:

```powershell
Get-NetAdapter | Select-Object Name, InterfaceGuid
```

## Configuration Details

### Adapter Settings

| Setting | Default | Optimized |
|---------|---------|-----------|
| Wake on Magic Packet | Enabled | Disabled |
| Wake on Pattern Match | Enabled | Disabled |
| ARP offload for WoWLAN | Enabled | Disabled |
| NS offload for WoWLAN | Enabled | Disabled |
| GTK rekeying for WoWLAN | Enabled | Disabled |
| Packet Coalescing | Enabled | Disabled |
| MIMO Power Save | Auto SMPS | No SMPS |
| Preferred Band | No Preference | 5 GHz |
| Roaming Aggressiveness | Medium | Lowest |

### TCP/IP Parameters

| Setting | Default | Optimized |
|---------|---------|-----------|
| Nagle's Algorithm | Enabled | Disabled (TCPNoDelay=1) |
| Delayed ACK | Enabled | Disabled (TcpAckFrequency=1) |
| Network Throttling Index | 32 | 10 |
| System Responsiveness | 20 | 10 |
| ECN Capability | Disabled | Enabled |
| Auto-Tuning Level | Normal | Normal (unchanged) |

### System

| Setting | Default | Optimized |
|---------|---------|-----------|
| NIC Power Management | Enabled | Disabled |
| NetBIOS over TCP/IP | Enabled | Disabled |
| RSS Base Processor | Default | Core 2 (multi-core only) |

> [!NOTE]
> A system restart is required for all registry and NIC changes to take effect.

## Verification

```powershell
# Display current TCP/IP global parameters
netsh int tcp show global

# Display NIC advanced properties
Get-NetAdapterAdvancedProperty -Name "Wi-Fi" | Format-Table DisplayName, DisplayValue

# Display registry values for the active adapter
$guid = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).InterfaceGuid
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"

# Test latency
ping -n 20 8.8.8.4 | Select-String "Average"
```

## DNS Configuration (Optional)

For network-level ad and tracker blocking, configure your adapter to use
AdGuard DNS:

```powershell
Set-DnsClientServerAddress -InterfaceIndex `
    (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).ifIndex `
    -ServerAddresses ("94.140.14.14", "94.140.15.15")
```

| Address | Value |
|---------|-------|
| Primary DNS | 94.140.14.14 |
| Secondary DNS | 94.140.15.15 |
| Protocol | DNS over HTTPS (recommended) |

## Documentation

- [Usage Guide](docs/GUIDE.md) -- detailed instructions and examples
- [FAQ & Troubleshooting](docs/FAQ.md) -- common issues and solutions
- [Changelog](CHANGELOG.md) -- version history

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/improvement`
3. Commit changes: `git commit -m 'Add feature'`
4. Push to branch: `git push origin feature/improvement`
5. Submit a pull request

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
