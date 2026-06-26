# FAQ

**PowerShell says scripts are blocked**

```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Run this before executing any of the scripts.

**Access denied**

The scripts need administrator privileges. Open PowerShell as admin.

**Do I need to restart**

Yes. Registry changes and NIC properties need a reboot.

**Will this affect battery life**

Disabling power management on the network adapter might reduce battery life slightly. Around 2-5% depending on usage.

**Ping is still high after running**

The scripts optimize the local machine only. High ping can come from the router, ISP, distance, or congestion on the network.

**Wi-Fi keeps disconnecting**

Update your Wi-Fi drivers from the manufacturers website. Make sure 5 GHz is enabled on the router.

**Lost internet access after running**

```
.\scripts\master.ps1 -Restore
netsh int ip reset
netsh winsock reset
```

Reboot.

**How to find the adapter GUID**

```
Get-NetAdapter | Select-Object Name, InterfaceGuid
```

**Can this run on multiple computers**

Copy the folder to each machine and run master.ps1 as admin.

**Does it work on Windows Server**

It targets Windows 10 and 11 consumer editions. Server editions are not tested.

**What does disabling Nagles Algorithm do**

Reduces latency by not waiting to bundle small packets. Helps with gaming, VoIP, and anything real-time.

**What is ECN**

A mechanism that tells the sender to slow down before packets are dropped. Reduces packet loss under load.

**What is MMCSS**

A Windows service that prioritizes multimedia and foreground applications over background tasks. The script adjusts how much CPU is reserved for background work.

**What is RSS**

Receive Side Scaling distributes network processing across multiple CPU cores. Helps when the adapter and system support it.

**What is NetBIOS**

An older networking protocol used for local name resolution. Disabling it reduces broadcast traffic and attack surface.
