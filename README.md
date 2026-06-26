# Windows Optimizer

Tweaks network settings on Windows 10/11.

## Files

scripts/master.ps1 - run everything
scripts/01-NIC-Tuning.ps1
scripts/02-Registry-Tweaks.ps1
scripts/03-Performance.ps1
registry/apply-tcp-tweaks.reg
registry/restore-defaults.reg
docs/GUIDE.md
docs/FAQ.md

## Usage

powershell as admin

```
.\scripts\master.ps1
```

add -Restore to revert. skip modules with -SkipNIC -SkipRegistry -SkipPerformance.

for manual registry, open apply-tcp-tweaks.reg, replace YOUR_NIC_GUID with your adapter guid.

## License

MIT
