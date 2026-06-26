# Windows Optimizer

PowerShell scripts and registry files that change how Windows 10 and 11 handle network traffic. Targets the TCP/IP stack, adapter behavior, and system scheduling for lower latency.

## Project structure

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

## What each script does

**01-NIC-Tuning.ps1** — turns off power saving features on the network adapter. Wake-on-LAN, packet coalescing, WoWLAN offloads all get disabled. MIMO power save is set to no SMPS, preferred band to 5 GHz, roaming to the lowest setting.

**02-Registry-Tweaks.ps1** — disables Nagle's Algorithm and Delayed ACK through the registry. Enables ECN. Changes MMCSS values so the system reserves less CPU for background tasks and more for whatever is in focus.

**03-Performance.ps1** — turns off power management on the adapter so Windows cant put it to sleep. Disables NetBIOS over TCP/IP. Configures RSS on machines with 4 or more cores if the adapter supports it.

**master.ps1** — runs all three in order. Detects the active adapter automatically.

## Requirements

- Windows 10 build 1903 or Windows 11
- Administrator access
- PowerShell 5.1 or newer
- An active network connection (Wi-Fi or Ethernet)

## Quick start

Open PowerShell as administrator.

```
.\scripts\master.ps1
```

Individual modules run on their own:

```
.\scripts\01-NIC-Tuning.ps1
.\scripts\02-Registry-Tweaks.ps1
.\scripts\03-Performance.ps1
```

Skip specific modules:

```
.\scripts\master.ps1 -SkipRegistry -SkipPerformance
```

## What gets changed

### Network adapter

- Wake on Magic Packet — Enabled → Disabled
- Wake on Pattern Match — Enabled → Disabled
- Packet Coalescing — Enabled → Disabled
- MIMO Power Save — Auto SMPS → No SMPS
- Preferred Band — No Preference → 5 GHz
- Roaming Aggressiveness — Medium → Lowest

### Registry (TCP/IP)

- Nagle's Algorithm — Enabled → Disabled
- Delayed ACK — Enabled → Disabled
- ECN — Disabled → Enabled
- Network Throttling Index — 32 → 10
- System Responsiveness — 20 → 10

### System

- NIC Power Management — Enabled → Disabled
- NetBIOS over TCP/IP — Enabled → Disabled
- RSS Base Processor — Default → Core 2 (multi-core only)

## Verification

```
netsh int tcp show global
Get-NetAdapterAdvancedProperty -Name "Wi-Fi" | Format-Table DisplayName, DisplayValue
ping -n 20 8.8.8.4 | Select-String "Average"
```

Changes need a restart to take full effect.

## Restore defaults

Revert everything:

```
.\scripts\master.ps1 -Restore
```

Or one module at a time:

```
.\scripts\01-NIC-Tuning.ps1 -Restore
.\scripts\02-Registry-Tweaks.ps1 -Restore
.\scripts\03-Performance.ps1 -Restore
```

If something breaks and the scripts cant help:

```
netsh int ip reset
netsh winsock reset
```

Reboot after restoring.

## AdGuard DNS

Optional but useful for blocking ads at the network level. Set the adapter to use:

```
Set-DnsClientServerAddress -InterfaceIndex `
    (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).ifIndex `
    -ServerAddresses ("94.140.14.14", "94.140.15.15")
```

Or manually through Settings > Network > Wi-Fi > Hardware properties > DNS.

- Primary: 94.140.14.14
- Secondary: 94.140.15.15

## Documentation

- [Usage guide](docs/GUIDE.md)
- [FAQ](docs/FAQ.md)
- [Changelog](CHANGELOG.md)

## Contributing

Fork, branch, commit, push, pull request. Keep it simple.

## License

MIT. See [LICENSE](LICENSE).
