param(
    [switch]$Restore
)

$ErrorActionPreference = "Stop"
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1

if (-not $adapter) {
    Write-Host "[ERROR] No active network adapter found." -ForegroundColor Red
    exit 1
}

$guid = $adapter.InterfaceGuid
$tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
$mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"

if ($Restore) {
    Write-Host "[RESTORE] Removing TCP registry tweaks..." -ForegroundColor Yellow
    Remove-ItemProperty -Path $tcpPath -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $tcpPath -Name "TCPNoDelay" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $tcpPath -Name "TcpDelAckTicks" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $mmcssPath -Name "NetworkThrottlingIndex" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $mmcssPath -Name "SystemResponsiveness" -ErrorAction SilentlyContinue
    netsh int tcp set global ecncapability=disabled | Out-Null
    netsh int tcp set global autotuninglevel=normal | Out-Null
    Write-Host "[OK] Defaults restored. Restart required." -ForegroundColor Green
    exit 0
}

Write-Host "[INFO] Active adapter GUID: $guid" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Nagle's Algorithm & Delayed ACK" -ForegroundColor Yellow
New-ItemProperty -Path $tcpPath -Name "TcpAckFrequency" -PropertyType DWord -Value 1 -Force | Out-Null
Write-Host "  [OK] TcpAckFrequency = 1" -ForegroundColor Green

New-ItemProperty -Path $tcpPath -Name "TCPNoDelay" -PropertyType DWord -Value 1 -Force | Out-Null
Write-Host "  [OK] TCPNoDelay = 1" -ForegroundColor Green

New-ItemProperty -Path $tcpPath -Name "TcpDelAckTicks" -PropertyType DWord -Value 0 -Force | Out-Null
Write-Host "  [OK] TcpDelAckTicks = 0" -ForegroundColor Green

Write-Host "[2/3] MMCSS Prioritization" -ForegroundColor Yellow
New-ItemProperty -Path $mmcssPath -Name "NetworkThrottlingIndex" -PropertyType DWord -Value 10 -Force | Out-Null
Write-Host "  [OK] NetworkThrottlingIndex = 10" -ForegroundColor Green

New-ItemProperty -Path $mmcssPath -Name "SystemResponsiveness" -PropertyType DWord -Value 10 -Force | Out-Null
Write-Host "  [OK] SystemResponsiveness = 10" -ForegroundColor Green

Write-Host "[3/3] TCP/IP Stack" -ForegroundColor Yellow
netsh int tcp set global ecncapability=enabled | Out-Null
Write-Host "  [OK] ECN = Enabled" -ForegroundColor Green

netsh int tcp set global autotuninglevel=normal | Out-Null
Write-Host "  [OK] TCP Auto-Tuning = Normal" -ForegroundColor Green

Write-Host ""
Write-Host "[COMPLETE] All registry tweaks applied." -ForegroundColor Cyan
Write-Host "[INFO] Restart required." -ForegroundColor Yellow
