# ================================================================
#  CLEAN UNUSED BOOT-START DRIVERS (Fixes 0xC1900101-0x20017)
#  Safe for systems without BitLocker, RAID, Hyper-V
# ================================================================

Write-Host "=== BOOT-START DRIVER CLEANUP ===" -ForegroundColor Cyan

$driversToDisable = @(
    "3ware","ADP80XX","amdsata","amdsbs","amdxata","arcsas","b06bdrv","ebdrv",
    "ItSas35i","LSI_SAS","LSI_SAS2i","LSI_SAS3i","LSI_SSS","megasas","megasas2i",
    "megasas35i","megasr","mvumis","nvraid","nvstor","percsas2i","percsas3i",
    "SiSRaid2","SiSRaid4","SmartSAMD","stexstor","vsmraid","VSTXRAID"
)

$undoScript = "$env:USERPROFILE\Desktop\Undo_BootDrivers.ps1"
"Write-Host '=== RESTORE ORIGINAL DRIVER START VALUES ==='" | Out-File $undoScript

foreach ($drv in $driversToDisable) {

    $svc = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Services\$drv" -ErrorAction SilentlyContinue
    if ($svc) {
        $startVal = (Get-ItemProperty $svc.PSPath).Start

        if ($startVal -eq 0) {
            Write-Host "Disabling boot-start driver: $drv" -ForegroundColor Yellow

            # Save undo entry
            "Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\$drv' -Name Start -Value $startVal" |
                Out-File $undoScript -Append

            # Apply fix
            Set-ItemProperty $svc.PSPath -Name Start -Value 3
        }
    }
}

Write-Host "`nDONE. A restore script was created on your Desktop:" -ForegroundColor Cyan
Write-Host $undoScript -ForegroundColor Green
Write-Host "`nNow reboot and retry the Windows 11 upgrade." -ForegroundColor Cyan
