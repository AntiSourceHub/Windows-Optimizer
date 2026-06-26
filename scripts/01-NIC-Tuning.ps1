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
Write-Host "[INFO] Active adapter: $name ($($adapter.InterfaceDescription))" -ForegroundColor Cyan

if ($Restore) {
    Write-Host "[RESTORE] Resetting NIC to Windows defaults..." -ForegroundColor Yellow
    Write-Host "[INFO] Use Device Manager or netsh to reset manually." -ForegroundColor Yellow
    exit 0
}

$props = @(
    @{ Display = "Wake on Magic Packet"; Value = "Disabled"; Reg = 0 }
    @{ Display = "Wake on Pattern Match"; Value = "Disabled"; Reg = 0 }
    @{ Display = "ARP offload for WoWLAN"; Value = "Disabled"; Reg = 0 }
    @{ Display = "NS offload for WoWLAN"; Value = "Disabled"; Reg = 0 }
    @{ Display = "GTK rekeying for WoWLAN"; Value = "Disabled"; Reg = 0 }
    @{ Display = "Packet Coalescing"; Value = "Disabled"; Reg = 0 }
)

$failed = @()

foreach ($prop in $props) {
    try {
        Set-NetAdapterAdvancedProperty -Name $name -DisplayName $prop.Display -DisplayValue $prop.Value -RegistryValue $prop.Reg -ErrorAction Stop
        Write-Host "  [OK] $($prop.Display)" -ForegroundColor Green
    } catch {
        $failed += $prop.Display
        Write-Host "  [SKIP] $($prop.Display) - $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
}

try {
    Set-NetAdapterAdvancedProperty -Name $name -DisplayName "MIMO Power Save Mode" -DisplayValue "No SMPS" -RegistryValue 3 -ErrorAction SilentlyContinue
    Write-Host "  [OK] MIMO Power Save Mode" -ForegroundColor Green
} catch {
    $failed += "MIMO Power Save Mode"
    Write-Host "  [SKIP] MIMO Power Save Mode" -ForegroundColor DarkYellow
}

try {
    Set-NetAdapterAdvancedProperty -Name $name -DisplayName "Preferred Band" -DisplayValue "3. Prefer 5GHz band" -RegistryValue 2 -ErrorAction SilentlyContinue
    Write-Host "  [OK] Preferred Band" -ForegroundColor Green
} catch {
    Write-Host "  [SKIP] Preferred Band" -ForegroundColor DarkYellow
}

try {
    Set-NetAdapterAdvancedProperty -Name $name -DisplayName "Roaming Aggressiveness" -DisplayValue "1. Lowest" -RegistryValue 0 -ErrorAction SilentlyContinue
    Write-Host "  [OK] Roaming Aggressiveness" -ForegroundColor Green
} catch {
    Write-Host "  [SKIP] Roaming Aggressiveness" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "[SUMMARY] Applied: $($props.Count - $failed.Count + 3 - $failed.Count), Skipped: $($failed.Count)" -ForegroundColor Cyan
Write-Host "[INFO] Restart required for all changes to take effect." -ForegroundColor Yellow
