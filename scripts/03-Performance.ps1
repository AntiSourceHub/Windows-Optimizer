param(
    [switch]$Restore
)

$ErrorActionPreference = "Stop"
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1

if (-not $adapter) {
    Write-Host "[ERROR] No active network adapter found." -ForegroundColor Red
    exit 1
}

$name = $adapter.Name

if ($Restore) {
    Write-Host "[RESTORE] Reverting performance tweaks..." -ForegroundColor Yellow
    Enable-NetAdapterPowerManagement -Name $name -ErrorAction SilentlyContinue
    Write-Host "[OK] Power Management re-enabled." -ForegroundColor Green
    exit 0
}

Write-Host "[INFO] Active adapter: $name" -ForegroundColor Cyan

Write-Host "[1/3] RSS (Receive Side Scaling)" -ForegroundColor Yellow
try {
    $rss = Get-NetAdapterRss -Name $name -ErrorAction Stop
    $cores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
    if ($cores -ge 4) {
        $base = 2
        if ($rss.BaseProcessorNumber -ne $base) {
            Set-NetAdapterRss -Name $name -BaseProcessorNumber $base -ErrorAction Stop
            Write-Host "  [OK] RSS BaseProcessorNumber set to $base" -ForegroundColor Green
        } else {
            Write-Host "  [OK] RSS already optimized" -ForegroundColor Green
        }
    } else {
        Write-Host "  [SKIP] Insufficient CPU cores for RSS tuning" -ForegroundColor DarkYellow
    }
} catch {
    Write-Host "  [SKIP] RSS not supported on this adapter" -ForegroundColor DarkYellow
}

Write-Host "[2/3] Power Management" -ForegroundColor Yellow
try {
    Disable-NetAdapterPowerManagement -Name $name -ErrorAction Stop
    Write-Host "  [OK] Power Management disabled" -ForegroundColor Green
} catch {
    Write-Host "  [SKIP] Could not disable power management" -ForegroundColor DarkYellow
}

Write-Host "[3/3] NetBIOS over TCP/IP" -ForegroundColor Yellow
try {
    $index = $adapter.ifIndex
    Set-CimInstance -Query "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE Index=$index" -Property @{TcpipNetbiosOptions=2} -ErrorAction Stop
    Write-Host "  [OK] NetBIOS disabled" -ForegroundColor Green
} catch {
    Write-Host "  [SKIP] Could not disable NetBIOS" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "[COMPLETE] Performance tweaks applied." -ForegroundColor Cyan
Write-Host "[INFO] RSS and Power Management take effect immediately." -ForegroundColor Yellow
Write-Host "[INFO] NetBIOS requires a restart." -ForegroundColor Yellow
