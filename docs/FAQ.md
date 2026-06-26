# FAQ

## scripts wont run

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

## access denied

run powershell as admin.

## restart needed

yes. most changes need a reboot.

## ping still high

could be your router or isp. the scripts only change your local machine.

## cant connect after running

.\scripts\master.ps1 -Restore
netsh int ip reset
netsh winsock reset
reboot

## what does nagles algorithm do

buffers small packets. adds latency. disabling helps gaming and calls.

## what is ecn

tells the network to slow down before packets drop. reduces loss.

## what is mmcss

prioritizes foreground apps over background tasks.
