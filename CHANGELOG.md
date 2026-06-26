# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-26

### Added

- NIC adapter optimization: disabled Wake-on-LAN, Packet Coalescing, WoWLAN
  offloads; configured MIMO, Preferred Band, and Roaming Aggressiveness
- TCP/IP registry tweaks: disabled Nagle's Algorithm and Delayed ACK, enabled
  ECN, confirmed Auto-Tuning at Normal level
- MMCSS prioritization: reduced SystemResponsiveness to 10, set
  NetworkThrottlingIndex to 10
- RSS configuration for multi-core processors when supported by the adapter
- NIC power management disable to prevent adapter sleep
- NetBIOS over TCP/IP disable for reduced broadcast traffic
- Master orchestration script with automatic adapter detection and error
  handling
- Backup and restore registry files for manual deployment
- Comprehensive documentation: usage guide, FAQ, and changelog

[1.0.0]: https://github.com/ABDULLAH-GHAITH/Windows-Optimizer/releases/tag/v1.0.0
