Write-Host "=== DRIVER COMPATIBILITY CHECK ===" -ForegroundColor Cyan

# 1. Storage controllers
Write-Host "`n[1] Storage Controllers" -ForegroundColor Yellow
Get-WmiObject Win32_PnPSignedDriver |
 Where-Object { $_.DeviceClass -eq "SCSIAdapter" -or $_.DeviceName -match "VMD|RST|RAID|AHCI|NVMe" } |
 Select-Object DeviceName, DriverVersion, Manufacturer, DriverProviderName, InfName, IsBootCritical |
 Format-Table -AutoSize

# 2. Filter drivers
Write-Host "`n[2] Filter Drivers" -ForegroundColor Yellow
$regPaths = @(
 "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E967-E325-11CE-BFC1-08002BE10318}",
 "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}",
 "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}"
)

foreach ($p in $regPaths) {
 Write-Host "`nClass: $p" -ForegroundColor Green
 Get-ItemProperty $p -ErrorAction SilentlyContinue |
  Select-Object UpperFilters, LowerFilters |
  Format-List
}

# 3. ESET minifilters
Write-Host "`n[3] ESET Filter Drivers" -ForegroundColor Yellow
Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services" |
 Where-Object { $_.Name -match "ESET|eamon|ehdrv|edevmon|epfw" } |
 Select-Object Name, @{n="StartType";e={(Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue).Start}} |
 Format-Table -AutoSize

# 4. Boot-start drivers
Write-Host "`n[4] Boot-Start Drivers (Start=0)" -ForegroundColor Yellow
Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services" |
 ForEach-Object {
  $p = Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue
  if ($p -and $p.Start -eq 0) {
   [PSCustomObject]@{
    Name = $_.PSChildName
    DisplayName = $p.DisplayName
    ImagePath = $p.ImagePath
   }
  }
 } |
 Format-Table -AutoSize

# 5. Unsigned or invalid drivers
Write-Host "`n[5] Unsigned / Invalid Drivers" -ForegroundColor Yellow
Get-WmiObject Win32_PnPSignedDriver |
 Where-Object { $_.IsSigned -eq $false -or (-not $_.DriverVersion) } |
 Select-Object DeviceName, Manufacturer, DriverVersion, InfName |
 Format-Table -AutoSize

# 6. Intel RST / VMD specific
Write-Host "`n[6] Intel RST / VMD Drivers" -ForegroundColor Yellow
Get-WmiObject Win32_PnPSignedDriver |
 Where-Object { ($_.DriverName -match "iaStor|RST|VMD") -or ($_.DeviceName -match "VMD") -or ($_.InfName -match "iaStor|VMD") } |
 Select-Object DeviceName, DriverVersion, DriverProviderName, InfName, IsBootCritical |
 Format-Table -AutoSize

Write-Host "`n=== DONE ===" -ForegroundColor Cyan
