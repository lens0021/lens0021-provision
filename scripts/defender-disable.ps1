# Run as Administrator.
# Disables Microsoft Defender real-time + adjacent protections, and registers
# a SYSTEM-level boot-time scheduled task that re-applies the disable on every
# reboot (since Defender resets these flags on boot).
#
# Tamper Protection MUST be OFF. Confirm with: Get-MpComputerStatus

$ErrorActionPreference = 'Continue'

function Try-Step($label, [scriptblock]$action) {
    try { & $action; Write-Host "OK   : $label" -ForegroundColor Green }
    catch { Write-Host "FAIL : $label -> $($_.Exception.Message)" -ForegroundColor Yellow }
}

Write-Host "=== Tamper Protection check ===" -ForegroundColor Cyan
$status = Get-MpComputerStatus
$status | Select-Object IsTamperProtected, RealTimeProtectionEnabled, AntivirusEnabled | Format-List
if ($status.IsTamperProtected) {
    Write-Host "Tamper Protection is ON. Turn it OFF in Windows Security UI first, then re-run." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# 1. Apply disable now
Try-Step "DisableRealtimeMonitoring"   { Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop }
Try-Step "DisableBehaviorMonitoring"   { Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction Stop }
Try-Step "DisableBlockAtFirstSeen"     { Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction Stop }
Try-Step "DisableIOAVProtection"       { Set-MpPreference -DisableIOAVProtection $true -ErrorAction Stop }
Try-Step "DisableScriptScanning"       { Set-MpPreference -DisableScriptScanning $true -ErrorAction Stop }
Try-Step "PUAProtection=Disabled"      { Set-MpPreference -PUAProtection Disabled -ErrorAction Stop }
Try-Step "MAPSReporting=Disabled"      { Set-MpPreference -MAPSReporting Disabled -ErrorAction Stop }
Try-Step "SubmitSamplesConsent=NeverSend" { Set-MpPreference -SubmitSamplesConsent NeverSend -ErrorAction Stop }
Try-Step "HighThreatDefaultAction=Allow"   { Set-MpPreference -HighThreatDefaultAction Allow -ErrorAction Stop }
Try-Step "ModerateThreatDefaultAction=Allow" { Set-MpPreference -ModerateThreatDefaultAction Allow -ErrorAction Stop }
Try-Step "LowThreatDefaultAction=Allow" { Set-MpPreference -LowThreatDefaultAction Allow -ErrorAction Stop }
Try-Step "SevereThreatDefaultAction=Allow" { Set-MpPreference -SevereThreatDefaultAction Allow -ErrorAction Stop }

# 2. Disable Defender's scheduled tasks entirely
$dtasks = @(
    'Windows Defender Cache Maintenance',
    'Windows Defender Cleanup',
    'Windows Defender Scheduled Scan',
    'Windows Defender Verification'
)
foreach ($n in $dtasks) {
    Try-Step "Disable task: $n" {
        Disable-ScheduledTask -TaskPath '\Microsoft\Windows\Windows Defender\' -TaskName $n -ErrorAction Stop | Out-Null
    }
}

# 3. Try to disable the WinDefend service start (usually blocked by TrustedInstaller ACL)
Try-Step "sc.exe config WinDefend start=disabled" {
    $r = & sc.exe config WinDefend start= disabled 2>&1
    if ($LASTEXITCODE -ne 0) { throw ($r -join ' ') }
}

# 4. Register boot-time scheduled task that re-applies the disable as SYSTEM
$taskName = 'DefenderForceDisableOnBoot'
$taskPath = '\'
$script = @'
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableBlockAtFirstSeen $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableScriptScanning $true
Set-MpPreference -PUAProtection Disabled
Set-MpPreference -MAPSReporting Disabled
Set-MpPreference -SubmitSamplesConsent NeverSend
'@
$scriptPath = "$env:ProgramData\DefenderForceDisable.ps1"
Set-Content -Path $scriptPath -Value $script -Encoding UTF8 -Force
Write-Host "OK   : wrote $scriptPath" -ForegroundColor Green

Try-Step "Register boot task '$taskName'" {
    # Remove if exists
    Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false -ErrorAction SilentlyContinue

    $action = New-ScheduledTaskAction `
        -Execute 'powershell.exe' `
        -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""

    # Two triggers: at startup, and at user logon (belt and suspenders)
    $t1 = New-ScheduledTaskTrigger -AtStartup
    $t2 = New-ScheduledTaskTrigger -AtLogOn

    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
    $settings  = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
        -MultipleInstances IgnoreNew

    Register-ScheduledTask `
        -TaskName $taskName -TaskPath $taskPath `
        -Action $action -Trigger @($t1, $t2) -Principal $principal -Settings $settings `
        -Description 'Re-disables Microsoft Defender protections after every boot/logon.' `
        -ErrorAction Stop | Out-Null
}

Try-Step "Run boot task once now" {
    Start-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction Stop
}

Write-Host "`n=== After ===" -ForegroundColor Cyan
Start-Sleep -Seconds 2
Get-MpComputerStatus | Select-Object `
    AMRunningMode, RealTimeProtectionEnabled, BehaviorMonitorEnabled, `
    OnAccessProtectionEnabled, IoavProtectionEnabled, AntispywareEnabled, `
    IsTamperProtected | Format-List

Write-Host "Boot task:" -ForegroundColor Cyan
Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath | Select-Object TaskName, State | Format-List

Write-Host "`nDone. Reboot to verify the boot task keeps Defender disabled." -ForegroundColor Cyan
Read-Host "Press Enter to close"
