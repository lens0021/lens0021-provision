# Run as Administrator.
# Minimize Microsoft Defender (MsMpEng.exe) CPU/IO impact without uninstalling.
# Tamper Protection must be OFF for these to stick. Check with: Get-MpComputerStatus

$ErrorActionPreference = 'Continue'

function Try-Step($label, [scriptblock]$action) {
    try {
        & $action
        Write-Host "OK   : $label" -ForegroundColor Green
    } catch {
        Write-Host "FAIL : $label -> $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "=== Before ===" -ForegroundColor Cyan
Get-MpComputerStatus | Select-Object AMRunningMode, RealTimeProtectionEnabled, IsTamperProtected | Format-List

# 1. Defender excludes itself (biggest single CPU win)
Try-Step "ExclusionProcess MsMpEng.exe"    { Add-MpPreference -ExclusionProcess 'MsMpEng.exe' -ErrorAction Stop }
Try-Step "ExclusionProcess NisSrv.exe"     { Add-MpPreference -ExclusionProcess 'NisSrv.exe'  -ErrorAction Stop }

# 2. Throttle scans
Try-Step "ScanAvgCPULoadFactor=5"          { Set-MpPreference -ScanAvgCPULoadFactor 5 -ErrorAction Stop }
Try-Step "DisableCpuThrottleOnIdleScans=false" { Set-MpPreference -DisableCpuThrottleOnIdleScans $false -ErrorAction Stop }
Try-Step "ScanOnlyIfIdleEnabled=true"      { Set-MpPreference -ScanOnlyIfIdleEnabled $true -ErrorAction Stop }
Try-Step "ScanScheduleDay=Sunday"          { Set-MpPreference -ScanScheduleDay 7 -ErrorAction Stop }
Try-Step "ScanParameters=QuickScan"        { Set-MpPreference -ScanParameters 1 -ErrorAction Stop }
Try-Step "DisableScanningMappedNetworkDrivesForFullScan=true" { Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $true -ErrorAction Stop }
Try-Step "DisableScanningNetworkFiles=true" { Set-MpPreference -DisableScanningNetworkFiles $true -ErrorAction Stop }
Try-Step "DisableArchiveScanning=true"     { Set-MpPreference -DisableArchiveScanning $true -ErrorAction Stop }
Try-Step "DisableEmailScanning=true"       { Set-MpPreference -DisableEmailScanning $true -ErrorAction Stop }
Try-Step "DisableRemovableDriveScanning=true" { Set-MpPreference -DisableRemovableDriveScanning $true -ErrorAction Stop }
Try-Step "DisableCatchupQuickScan=true"    { Set-MpPreference -DisableCatchupQuickScan $true -ErrorAction Stop }
Try-Step "DisableCatchupFullScan=true"     { Set-MpPreference -DisableCatchupFullScan $true -ErrorAction Stop }
Try-Step "MAPSReporting=Disabled"          { Set-MpPreference -MAPSReporting Disabled -ErrorAction Stop }
Try-Step "SubmitSamplesConsent=NeverSend"  { Set-MpPreference -SubmitSamplesConsent NeverSend -ErrorAction Stop }

# 3. Exclude heavy dev paths (edit as needed)
$paths = @(
    'C:\Users\loren\git',
    'C:\Users\loren\.claude',
    'C:\Users\loren\AppData\Local\npm-cache',
    'C:\Users\loren\AppData\Roaming\npm',
    'C:\Users\loren\AppData\Local\pip\Cache',
    'C:\Users\loren\.cargo',
    'C:\Users\loren\go'
)
foreach ($p in $paths) {
    if (Test-Path $p) {
        Try-Step "ExclusionPath $p" { Add-MpPreference -ExclusionPath $p -ErrorAction Stop }
    } else {
        Write-Host "SKIP : $p (not found)" -ForegroundColor DarkGray
    }
}

# 4. Schedule the maintenance tasks to idle-only
$tasks = @(
    '\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance',
    '\Microsoft\Windows\Windows Defender\Windows Defender Cleanup',
    '\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan',
    '\Microsoft\Windows\Windows Defender\Windows Defender Verification'
)
foreach ($t in $tasks) {
    Try-Step "Task idle-only: $t" {
        $task = Get-ScheduledTask -TaskPath (Split-Path $t -Parent).Replace('\','\') + '\' -TaskName (Split-Path $t -Leaf) -ErrorAction Stop
        $settings = $task.Settings
        $settings.RunOnlyIfIdle = $true
        $settings.IdleSettings.IdleDuration = 'PT10M'
        $settings.IdleSettings.WaitTimeout  = 'PT1H'
        Set-ScheduledTask -TaskPath $task.TaskPath -TaskName $task.TaskName -Settings $settings -ErrorAction Stop | Out-Null
    }
}

Write-Host "`n=== After ===" -ForegroundColor Cyan
$p = Get-MpPreference
$p | Select-Object ScanAvgCPULoadFactor, ScanOnlyIfIdleEnabled, ScanScheduleDay, ScanParameters,
    DisableArchiveScanning, DisableEmailScanning, DisableRemovableDriveScanning,
    DisableScanningNetworkFiles, MAPSReporting, SubmitSamplesConsent | Format-List
Write-Host "ExclusionPath:"    -ForegroundColor Cyan; $p.ExclusionPath
Write-Host "ExclusionProcess:" -ForegroundColor Cyan; $p.ExclusionProcess
