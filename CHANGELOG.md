# Changelog

## 1.0.0 — 2026-06-26

Initial release.

- NIC tuning: disabled Wake-on-LAN, Packet Coalescing, WoWLAN offloads. Set MIMO to No SMPS, preferred band to 5 GHz, roaming to Lowest
- Registry tweaks: disabled Nagles Algorithm and Delayed ACK. Enabled ECN. Changed MMCSS throttling and responsiveness values
- Performance: disabled NIC power management, disabled NetBIOS over TCP/IP, configured RSS on supported hardware
- Master orchestrator that runs all modules with error handling
- Registry files for manual import
- Documentation and changelog
