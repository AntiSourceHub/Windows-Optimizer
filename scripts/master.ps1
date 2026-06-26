param(
    [switch]$Restore,
    [switch]$SkipNIC,
    [switch]$SkipRegistry,
    [switch]$SkipPerformance
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[FATAL] Administrator privileges required. Run as Administrator." -ForegroundColor Red
    exit 1
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "       Windows Optimizer v1.0.0" -ForegroundColor White
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
if (-not $adapter) {
    Write-Host "[FATAL] No active network adapter detected." -ForegroundColor Red
    exit 1
}

Write-Host "[SYSTEM] Adapter : $($adapter.Name)" -ForegroundColor Gray
Write-Host "[SYSTEM] Type    : $($adapter.InterfaceDescription)" -ForegroundColor Gray
Write-Host "[SYSTEM] OS      : $((Get-CimInstance Win32_OperatingSystem).Caption)" -ForegroundColor Gray

$cores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
Write-Host "[SYSTEM] CPU     : $cores cores" -ForegroundColor Gray
Write-Host "[SYSTEM] RAM     : $ram GB" -ForegroundColor Gray
Write-Host ""

$modules = 0
$errors = @()

if (-not $SkipNIC) {
    $modules++
    Write-Host "[MODULE $modules] NIC Tuning" -ForegroundColor Yellow
    try {
        & "$scriptDir\01-NIC-Tuning.ps1"
        Write-Host "[OK] NIC Tuning complete" -ForegroundColor Green
    } catch {
        $errors += "NIC Tuning: $($_.Exception.Message)"
        Write-Host "[ERROR] NIC Tuning failed" -ForegroundColor Red
    }
    Write-Host ""
}

if (-not $SkipRegistry) {
    $modules++
    Write-Host "[MODULE $modules] Registry Tweaks" -ForegroundColor Yellow
    try {
        & "$scriptDir\02-Registry-Tweaks.ps1"
        Write-Host "[OK] Registry Tweaks complete" -ForegroundColor Green
    } catch {
        $errors += "Registry Tweaks: $($_.Exception.Message)"
        Write-Host "[ERROR] Registry Tweaks failed" -ForegroundColor Red
    }
    Write-Host ""
}

if (-not $SkipPerformance) {
    $modules++
    Write-Host "[MODULE $modules] Performance Tuning" -ForegroundColor Yellow
    try {
        & "$scriptDir\03-Performance.ps1"
        Write-Host "[OK] Performance Tuning complete" -ForegroundColor Green
    } catch {
        $errors += "Performance Tuning: $($_.Exception.Message)"
        Write-Host "[ERROR] Performance Tuning failed" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "       Summary" -ForegroundColor White
Write-Host "================================================" -ForegroundColor Cyan

if ($errors.Count -eq 0) {
    Write-Host "[STATUS] All modules completed successfully." -ForegroundColor Green
} else {
    Write-Host "[STATUS] $($errors.Count) module(s) had errors:" -ForegroundColor Yellow
    foreach ($err in $errors) {
        Write-Host "  - $err" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[NEXT STEPS]" -ForegroundColor Magenta
Write-Host "  1. Restart your computer for all changes to take effect." -ForegroundColor White
Write-Host "  2. (Optional) Download TCP Optimizer from:" -ForegroundColor White
Write-Host "     https://www.speedguide.net/downloads.php" -ForegroundColor White
Write-Host "  3. (Optional) Configure AdGuard DNS (94.140.14.14 / 94.140.15.15)" -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
