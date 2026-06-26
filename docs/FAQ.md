# Windows Optimizer -- FAQ & Troubleshooting

## General

### Will these scripts slow down my computer?

No. The scripts optimize network performance and reduce unnecessary background
processing. System responsiveness should improve, not degrade.

### Will this affect my Wi-Fi speed?

The scripts disable power-saving features that can cause disconnections, but
they do not reduce Wi-Fi throughput. In most cases, connection stability
improves.

### Do I need to restart after running the scripts?

Yes. Registry changes and NIC property modifications require a system restart
to take effect.

### Can I run these on a laptop?

Yes. The scripts are designed for both desktops and laptops. Note that
disabling NIC power management may reduce battery life by approximately 2-5%.

### Will this void my warranty?

No. These are software-only configuration changes. They do not modify firmware,
BIOS, or hardware components.

## Installation & Execution

### Execution Policy Error

PowerShell's default execution policy may block script execution.

**Solution:**

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Run this command before executing any optimization script.

### Access Denied Error

All scripts require Administrator privileges.

**Solution:**
1. Press **Win + X**
2. Select **Windows Terminal (Admin)** or **PowerShell (Admin)**
3. Confirm the UAC prompt
4. Re-run the script

### No Active Network Adapter Found

The scripts require at least one active (connected) network adapter.

**Solution:**
1. Verify your Wi-Fi or Ethernet connection is active
2. Run `Get-NetAdapter` to list all adapters
3. Ensure at least one adapter shows `Status: Up`

## Network Issues

### Ping Remains High After Optimization

High latency is not always caused by local configuration. Possible causes:

- **Distance from router** -- move closer to the access point
- **Channel congestion** -- switch to a less congested Wi-Fi channel
- **ISP throttling or routing** -- contact your Internet service provider
- **Background applications** -- check Task Manager for network-intensive processes
- **Router limitations** -- older routers may introduce latency regardless of client settings

### Wi-Fi Disconnects Frequently

The scripts set roaming aggressiveness to Lowest, which minimizes unnecessary
access point switching. If disconnections persist:

1. Update Wi-Fi drivers from the manufacturer's website
2. Verify 5 GHz band is enabled on your router
3. Reduce physical distance to the access point
4. Check for interference from other electronic devices

### Cannot Connect to the Internet After Changes

Restore defaults immediately:

```powershell
.\scripts\master.ps1 -Restore
```

If connectivity does not return after a restart, reset the TCP/IP stack and
Winsock:

```powershell
netsh int ip reset
netsh winsock reset
Restart-Computer
```

## Registry

### Can I Edit the Registry Files?

Yes. The `.reg` files in the `registry\` directory are plain text. Replace
`YOUR_NIC_GUID` with your adapter's GUID before applying:

```powershell
Get-NetAdapter | Select-Object Name, InterfaceGuid
```

### How Do I Find My Adapter GUID?

```powershell
Get-NetAdapter | Select-Object Name, InterfaceGuid
```

The output will display each adapter's GUID in the format `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}`.

### I Made a Mistake in the Registry

Use the restore script or restore registry file:

```powershell
.\scripts\02-Registry-Tweaks.ps1 -Restore
```

Or double-click `registry\restore-defaults.reg` (after replacing `YOUR_NIC_GUID`).

## Performance

### How Do I Verify the Changes Were Applied?

```powershell
# Check NIC settings
Get-NetAdapterAdvancedProperty -Name "Wi-Fi" | Format-Table DisplayName, DisplayValue

# Check registry values
$guid = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).InterfaceGuid
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"

# Check TCP/IP global parameters
netsh int tcp show global

# Test latency
ping -t 8.8.8.4
```

### Can I Apply These to Multiple Computers?

Yes. Copy the `Windows-Optimizer` directory to each target machine and run
`master.ps1` as Administrator on each system.

### Does This Work on Windows Server?

Partially. The scripts target Windows 10 and Windows 11 consumer editions.
Some settings may not apply or may behave differently on Windows Server.

## DNS

### Should I Use AdGuard DNS?

AdGuard DNS blocks ads, trackers, and malware at the network level. It is
optional but recommended if you do not already have a network-level ad blocker.

| Setting | Value |
|---------|-------|
| Primary DNS | 94.140.14.14 |
| Secondary DNS | 94.140.15.15 |
| Encryption | DNS over HTTPS (DoH) |

### Does AdGuard DNS Slow Down My Internet?

The latency overhead is minimal (typically 1-2 ms). This is negligible compared
to the benefit of blocking unwanted content at the network level.

## Uninstalling

### How Do I Remove All Changes?

```powershell
# Restore all settings to Windows defaults
.\scripts\master.ps1 -Restore

# Restart the system
Restart-Computer
```

### Can I Delete the Project Folder?

Deleting the folder does not undo any changes. The scripts modify system
settings directly; the folder contains only the scripts and documentation.
Always run the restore command before deleting.

## Technical Reference

### What Is Nagle's Algorithm?

Nagle's Algorithm buffers small TCP packets and sends them together to reduce
network overhead. This improves bulk throughput but can add up to 200 ms of
latency. Disabling it (TCPNoDelay=1) reduces latency for interactive
applications such as gaming and video conferencing.

### What Is Delayed ACK?

Delayed ACK postpones TCP acknowledgment transmission by up to 200 ms to allow
piggybacking on outgoing data packets. Disabling it (TcpAckFrequency=1) reduces
round-trip latency at the cost of slightly increased ACK overhead.

### What Is RSS?

Receive Side Scaling (RSS) distributes network interrupt processing across
multiple CPU cores. This prevents a single core from becoming a bottleneck
during high-throughput network activity.

### What Is MMCSS?

Multimedia Class Scheduler Service (MMCSS) prioritizes multimedia and gaming
threads over background tasks. The scripts reduce the CPU time reserved for
background tasks from 20% to 10%, allocating more processing power to
foreground applications.

### What Is ECN?

Explicit Congestion Notification (ECN) allows the network stack to signal
congestion and reduce transmission speed before packets are dropped. This
reduces packet loss under congested conditions.
