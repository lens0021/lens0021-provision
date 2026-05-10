# Windows provision bootstrap.
# Run via:
#   irm https://raw.githubusercontent.com/lens0021/lens0021-provision/main/windows/bootstrap.ps1 | iex
# Idempotent: re-runs are safe, each section skips work that's already done.
#
# Sections, in order:
#   A. winget packages + Nalgaeset MSI + Claude Code + DebugView + bash-abbrev-alias
#   B. Keyboard / IME / PowerToys keymap (Korean + en-US Dvorak + CapsLock remap)
#   C. Cosmetic / debloat / privacy / IME default / WT default / .bashrc generation
#   D. Config deploy (hardlinks repo/config/* into runtime locations)
#   E. Host-specific drivers (only on this MSI GE62 2QL — gated by Win32_ComputerSystem)
#
# Manual steps not automated (see README):
#   - PowerToys first run (start it from Start menu before relying on its keymap)
#   - gh auth login (browser auth)
#   - SSH key restore / generation
#   - Sign out / sign in (or reboot) at the end

$ErrorActionPreference = 'Stop'

# ============================================================================
# Section A — packages
# ============================================================================
# winget runs that warn about no real console under iex/bg shouldn't abort us.
$ErrorActionPreference = 'Continue'

$packages = @(
    'Microsoft.WindowsTerminal'
    'Microsoft.PowerShell'
    'Microsoft.PowerToys'
    'Starship.Starship'            # cross-shell prompt
    'AltSnap.AltSnap'              # Super+drag to move windows (GNOME-style)
    'AutoHotkey.AutoHotkey'        # keyboard scripting (Win-key shortcuts)
    'rsteube.Carapace'             # multi-shell completion engine (bash menu)
    'GitHub.cli'
    'GLab.GLab'
    'Helix.Helix'
    'JesseDuffield.lazygit'
    'sxyazi.yazi'
    'GnuCash.GnuCash'
    # yazi recommended deps (also useful standalone)
    'ajeetdsouza.zoxide'
    'BurntSushi.ripgrep.MSVC'
    'sharkdp.fd'
    'junegunn.fzf'
    'jqlang.jq'
    '7zip.7zip'
    'Gyan.FFmpeg'
    'Byron.dua-cli'                # disk usage TUI

    'Zellij.Zellij'
    'Amazon.AWSCLI'
    'Versent.saml2aws'
    'Mozilla.Firefox'
    'Google.Chrome'
    'Git.Git'
    # Dev toolchains
    'OpenJS.NodeJS.LTS'
    'Rustlang.Rustup'
    'zig.zig'
    # Python tooling (astral-sh stack)
    'astral-sh.uv'                 # package/project manager
    'astral-sh.ruff'               # linter / formatter
    'astral-sh.ty'                 # type checker
    # Cloud / infra tooling
    'Kubernetes.kubectl'
    'Helm.Helm'
    'Hashicorp.Terraform'
    'Hashicorp.Vault'
    'ahmetb.kubectx'               # kubectx + kubens
    'Derailed.k9s'                 # k8s TUI (broken inside zellij — use bare WT tab)
    'stern.stern'                  # multi-pod log tail
    'Istio.Istio'                  # ships istioctl
    'Gravitational.Teleport'       # tsh CLI
    'Tailscale.Tailscale'
    'SlackTechnologies.Slack'
)

function Test-WingetInstalled {
    param([string]$Id)
    $list = winget list --id $Id --source winget --accept-source-agreements 2>&1 | Out-String
    return $list -match [regex]::Escape($Id)
}

function Install-WingetPackage {
    param([string]$Id)
    if (Test-WingetInstalled -Id $Id) {
        Write-Host "[skip]    $Id"
        return
    }
    Write-Host "[install] $Id"
    winget install --exact --id $Id --source winget `
        --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "winget install '$Id' exited with $LASTEXITCODE"
    }
}

foreach ($id in $packages) { Install-WingetPackage -Id $id }

# Microsoft Visual Studio 2022 Build Tools — Rust msvc toolchain link.exe.
# winget ID is the same but --override is needed for VC++ workload + Win11 SDK.
# Without the workload, BuildTools is installed but cargo build fails with
# 'linker `link.exe` not found'.
function Test-VSBuildToolsInstalled {
    return Test-Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
}

if (Test-VSBuildToolsInstalled) {
    Write-Host '[skip]    Microsoft.VisualStudio.2022.BuildTools'
} else {
    Write-Host '[install] Microsoft.VisualStudio.2022.BuildTools'
    $vsOverride = '--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --includeRecommended'
    winget install --exact --id Microsoft.VisualStudio.2022.BuildTools --source winget `
        --accept-source-agreements --accept-package-agreements --silent --override $vsOverride
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "VS BuildTools install exited with $LASTEXITCODE"
    }
}

# Rust default toolchain — winget Rustlang.Rustup only ships rustup-init.
# For cargo install / cargo build to work, we need a stable toolchain selected.
$rustup = Join-Path $env:USERPROFILE '.cargo\bin\rustup.exe'
if (Test-Path $rustup) {
    $toolchains = & $rustup toolchain list 2>&1 | Out-String
    if ($toolchains -notmatch 'stable-') {
        Write-Host '[install] rust stable toolchain'
        & $rustup default stable
        if ($LASTEXITCODE -ne 0) { Write-Warning "rustup default stable exited $LASTEXITCODE" }
    } else {
        Write-Host '[skip]    rust stable toolchain'
    }
}

# rumdl — Markdown linter (Rust). Only available via cargo.
function Test-RumdlInstalled {
    return Test-Path (Join-Path $env:USERPROFILE '.cargo\bin\rumdl.exe')
}

if (Test-RumdlInstalled) {
    Write-Host '[skip]    rumdl'
} else {
    $cargo = Join-Path $env:USERPROFILE '.cargo\bin\cargo.exe'
    if (-not (Test-Path $cargo)) {
        Write-Warning 'cargo not found; skip rumdl. Re-run after Rust toolchain ready.'
    } else {
        Write-Host '[install] rumdl (cargo install — ~10min compile)'
        & $cargo install rumdl
        if ($LASTEXITCODE -ne 0) { Write-Warning "rumdl install exited $LASTEXITCODE" }
    }
}

# bash-abbrev-alias — fish-style abbreviation expansion for Git Bash.
$abbrDir = Join-Path $env:USERPROFILE '.local\share\bash-abbrev-alias'
if (Test-Path "$abbrDir\abbrev-alias.plugin.bash") {
    Write-Host '[skip]    bash-abbrev-alias'
} else {
    Write-Host '[install] bash-abbrev-alias'
    $parent = Split-Path -Parent $abbrDir
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    & git clone https://github.com/momo-lab/bash-abbrev-alias.git $abbrDir
}

# fzf-tab-completion — replaces bash's plain Tab menu with an fzf picker.
# Pairs with carapace below: carapace generates rich candidate data,
# fzf-tab-completion renders the menu UI.
$fzfTabDir = Join-Path $env:USERPROFILE '.local\share\fzf-tab-completion'
if (Test-Path "$fzfTabDir\bash\fzf-bash-completion.sh") {
    Write-Host '[skip]    fzf-tab-completion'
} else {
    Write-Host '[install] fzf-tab-completion'
    $parent = Split-Path -Parent $fzfTabDir
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    & git clone --depth 1 https://github.com/lincheney/fzf-tab-completion.git $fzfTabDir
}

# DebugView (Sysinternals) — winget manifest is broken (no installer URL),
# fetch the official zip from Sysinternals and drop in %LOCALAPPDATA%.
$dvDir = "$env:LOCALAPPDATA\Programs\DebugView"
$dvExe = "$dvDir\Dbgview64a.exe"
if (Test-Path $dvExe) {
    Write-Host '[skip]    DebugView'
} else {
    Write-Host '[install] DebugView'
    $zip = "$env:TEMP\DebugView.zip"
    Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/DebugView.zip' -OutFile $zip -UseBasicParsing
    if (-not (Test-Path $dvDir)) { New-Item -ItemType Directory -Path $dvDir -Force | Out-Null }
    Expand-Archive -Path $zip -DestinationPath $dvDir -Force
    Remove-Item $zip -Force
    $lnk = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\DebugView.lnk"
    $wsh = New-Object -ComObject WScript.Shell
    $s = $wsh.CreateShortcut($lnk)
    $s.TargetPath = $dvExe
    $s.WorkingDirectory = $dvDir
    $s.Save()
}

# marcosnils/bin — Effortless binary manager (Go binary, not on winget).
# Used on Windows for GitHub-release CLIs that aren't in winget (e.g. kaf).
# The Linux clone of provision shares config/bin.config; on Windows we
# bootstrap a fresh, Windows-pathed config so the two clones don't collide.
$binExe = Join-Path $env:USERPROFILE '.local\bin\bin.exe'
if (Test-Path $binExe) {
    Write-Host '[skip]    marcosnils/bin'
} else {
    Write-Host '[install] marcosnils/bin'
    $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/marcosnils/bin/releases/latest' -Headers @{ 'User-Agent' = 'provision-script' }
    $asset = $rel.assets | Where-Object { $_.name -match 'windows.*amd64' } | Select-Object -First 1
    $tmp = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tmp -UseBasicParsing
    $dest = Split-Path -Parent $binExe
    if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
    Copy-Item $tmp $binExe -Force
    Remove-Item $tmp -Force
}
$binCfg = Join-Path $env:USERPROFILE '.config\bin\config.json'
if (-not (Test-Path $binCfg)) {
    $binCfgDir = Split-Path -Parent $binCfg
    if (-not (Test-Path $binCfgDir)) { New-Item -ItemType Directory -Path $binCfgDir -Force | Out-Null }
    $defaultPath = ($env:USERPROFILE -replace '\\','/') + '/.local/bin'
    @{ default_path = $defaultPath; bins = @{} } | ConvertTo-Json -Depth 5 | Set-Content -Path $binCfg -Encoding utf8
    Write-Host '[ok]      bin Windows config bootstrapped'
}

# kaf — Kafka CLI client. Not on winget; install via marcosnils/bin.
$kafExe = Join-Path $env:USERPROFILE '.local\bin\kaf.exe'
if (Test-Path $kafExe) {
    Write-Host '[skip]    kaf'
} elseif (Test-Path $binExe) {
    Write-Host '[install] kaf (via bin)'
    & $binExe install github.com/birdayz/kaf $kafExe
}

# Nalgaeset Korean IME (not on winget; download MSI directly).
# Detection key: Publisher = 'YmSoft' (ASCII).
function Test-NgsInstalled {
    $keys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    foreach ($k in $keys) {
        $items = Get-ChildItem $k -ErrorAction SilentlyContinue
        foreach ($it in $items) {
            $p = Get-ItemProperty $it.PSPath -ErrorAction SilentlyContinue
            if ($p.Publisher -eq 'YmSoft') { return $true }
        }
    }
    return $false
}

if (Test-NgsInstalled) {
    Write-Host '[skip]    Nalgaeset'
} else {
    $url = 'http://moogi.new21.org/bin/Ngs1085Setup_x64.msi'
    $msi = Join-Path $env:TEMP 'Ngs1085Setup_x64.msi'
    Write-Host "[download] $url"
    Invoke-WebRequest -Uri $url -OutFile $msi -UseBasicParsing
    Write-Host '[install] Nalgaeset'
    $proc = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /passive /norestart" -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Warning "Nalgaeset MSI install exited with $($proc.ExitCode)"
    }
}

# Claude Code (native installer via Git Bash; depends on Git.Git above).
function Test-ClaudeInstalled {
    return Test-Path (Join-Path $env:USERPROFILE '.local\bin\claude.exe')
}

if (Test-ClaudeInstalled) {
    Write-Host '[skip]    Claude Code'
} else {
    $bash = 'C:\Program Files\Git\bin\bash.exe'
    if (-not (Test-Path $bash)) {
        Write-Warning 'Git Bash not found; skipping Claude Code (install Git first).'
    } else {
        Write-Host '[install] Claude Code'
        & $bash -lc 'curl -fsSL https://claude.ai/install.sh | bash'
        if ($LASTEXITCODE -ne 0) { Write-Warning "Claude Code install exited $LASTEXITCODE" }
    }
}

$ErrorActionPreference = 'Stop'

# ============================================================================
# Section B — keyboard / IME / PowerToys
# ============================================================================

# 1. Language list: ensure en-US Dvorak; append Nalgaeset to Korean.
# Reason for en-US Dvorak as a *system* layout: Nalgaeset doesn't translate
# shortcuts to its mapped layout, so Alt+P etc. arrive at QWERTY positions.
# Having en-US Dvorak as the system layout makes the OS handle shortcut
# translation. Nalgaeset stays for Korean. Switch input modes via Win+Space.
$ngsTip    = '0412:{5CC2EDB1-F5F4-456C-A871-CF6B62415CD9}{36207E64-3175-433E-A713-2D0F7473273A}'
$dvorakTip = '0409:00010409'

$ll = Get-WinUserLanguageList

$en = $ll | Where-Object { $_.LanguageTag -eq 'en-US' }
if ($null -eq $en) {
    $tmp = New-WinUserLanguageList -Language en-US
    $ll.Add($tmp[0])
    $en = $ll | Where-Object { $_.LanguageTag -eq 'en-US' }
}
$en.InputMethodTips.Clear()
$en.InputMethodTips.Add($dvorakTip)

$ko = $ll | Where-Object { $_.LanguageTag -eq 'ko' }
if ($null -ne $ko -and $ko.InputMethodTips -notcontains $ngsTip) {
    $ko.InputMethodTips.Add($ngsTip)
}

Set-WinUserLanguageList -LanguageList $ll -Force
Write-Host '[ok] Language list updated (en-US Dvorak + Korean MS IME + Nalgaeset)'

# 2. PowerToys Keyboard Manager: CapsLock -> Right Alt, Shift+CapsLock -> CapsLock
$ptDir = "$env:LOCALAPPDATA\Microsoft\PowerToys\Keyboard Manager"
New-Item -ItemType Directory -Path $ptDir -Force | Out-Null
$ptConfig = [ordered]@{
    remapKeys = [ordered]@{
        inProcess = @(
            [ordered]@{ originalKeys = '20'; newRemapKeys = '165' }
        )
    }
    remapShortcuts = [ordered]@{
        global = @(
            [ordered]@{ originalKeys = '16;20'; newRemapKeys = '20' }
        )
    }
}
$json = $ptConfig | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText("$ptDir\default.json", $json, [System.Text.UTF8Encoding]::new($false))
Write-Host "[ok] PowerToys keymap written: $ptDir\default.json"

# 3. PATH: ensure ~/.local/bin is on user PATH (Claude Code installer puts claude.exe there).
$localBin = Join-Path $env:USERPROFILE '.local\bin'
if (Test-Path $localBin) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = ($userPath -split ';') | Where-Object { $_ }
    if ($entries -notcontains $localBin) {
        $newPath = (@($entries) + $localBin) -join ';'
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Host "[ok] Added to user PATH: $localBin"
    } else {
        Write-Host "[skip] Already on user PATH: $localBin"
    }
}

# ============================================================================
# Section C — cosmetic / debloat / privacy / IME default / WT default / .bashrc
# ============================================================================

# Visual Effects: 0 = "Let Windows choose what's best for my computer".
# (Tried "best performance" first but smooth scrolling regression isn't worth
# it on this hardware — GTX 950M handles animations fine.)
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' `
    -Name 'VisualFXSetting' -Value 0 -Type DWord -Force
Write-Host '[ok] Visual effects: Windows default (smooth scrolling preserved)'

# Display scaling: clamp to recommended (DpiValue offset = 0) if above.
# On a 15.6" 1080p panel recommended = 100%, so this enforces "<= 100%".
# Each PerMonitorSettings subkey is one monitor; DpiValue is offset from
# recommended in 25% steps (positive = larger). We don't go negative.
$pmKey = 'HKCU:\Control Panel\Desktop\PerMonitorSettings'
if (Test-Path $pmKey) {
    Get-ChildItem $pmKey | ForEach-Object {
        $raw = (Get-ItemProperty -Path $_.PSPath -Name 'DpiValue' -ErrorAction SilentlyContinue).DpiValue
        if ($null -eq $raw) { return }
        # DWORD is unsigned in PowerShell's view; cast to Int32 for sign.
        $dpi = [int32]$raw
        if ($dpi -gt 0) {
            Set-ItemProperty -Path $_.PSPath -Name 'DpiValue' -Value 0 -Type DWord -Force
            Write-Host "[ok] DPI: $($_.PSChildName) offset $dpi -> 0 (recommended)"
        }
    }
}

# 24-hour clock (HH:mm rather than h:mm tt).
Set-ItemProperty 'HKCU:\Control Panel\International' -Name 'sShortTime'  -Value 'HH:mm'
Set-ItemProperty 'HKCU:\Control Panel\International' -Name 'sTimeFormat' -Value 'HH:mm:ss'
Write-Host '[ok] Clock: 24-hour format'

# Helper: set a registry value, creating the key if missing.
# Wrapped in try/catch because some HKCU policy subkeys ship with restricted
# ACLs (e.g. via group policy / MDM) and refuse user writes; we don't want
# one such key to abort the whole script.
function Set-Reg {
    param([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord')
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force -ErrorAction Stop | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
    } catch {
        Write-Warning "Set-Reg failed for ${Path}\${Name}: $($_.Exception.Message)"
    }
}

# Helper: HKLM policy writes are best-effort (non-admin runs skip with warning).
function Set-RegHKLM {
    param([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord', [string]$Label)
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force -ErrorAction Stop | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
        return $true
    } catch {
        Write-Warning "HKLM write skipped ($Label) - non-admin? per-user setting still applied."
        return $false
    }
}

# Taskbar: News and interests (weather + news feed) off.
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds' 'ShellFeedsTaskbarViewMode' 2
Set-RegHKLM 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds' 'EnableFeeds' 0 'DWord' 'News feed' | Out-Null
Write-Host '[ok] Taskbar: News and interests disabled'

# Taskbar: Search box hidden (0=hidden, 1=icon, 2=box). Win key + type still works.
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0
# Cortana button hidden.
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCortanaButton' 0
# People button hidden.
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' 'PeopleBand' 0
# Task View button: kept (GNOME Activities equivalent — useful with virtual desktops).
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowTaskViewButton' 1
Write-Host '[ok] Taskbar: search box / Cortana / people hidden; task view kept'

# Bing/web search in Start menu off.
# HKCU\Software\Policies\* is system-restricted (user can't write); use HKLM policy.
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'CortanaConsent' 0
Set-RegHKLM 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1 'DWord' 'Search suggestions' | Out-Null
Set-RegHKLM 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 0 'DWord' 'Cortana' | Out-Null
Write-Host '[ok] Start menu: Bing/web search and Cortana off'

# Content Delivery Manager: Start menu suggestions, lock screen ads,
# tips/tricks notifications, auto-installed promoted apps, "Suggested" sections.
$cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
$cdmKeys = @(
    'ContentDeliveryAllowed',
    'OemPreInstalledAppsEnabled',
    'PreInstalledAppsEnabled',
    'PreInstalledAppsEverEnabled',
    'SilentInstalledAppsEnabled',
    'SoftLandingEnabled',
    'SystemPaneSuggestionsEnabled',
    'SubscribedContentEnabled',
    'SubscribedContent-310093Enabled', # Welcome experience after updates
    'SubscribedContent-314559Enabled',
    'SubscribedContent-338387Enabled',
    'SubscribedContent-338388Enabled', # Start menu suggestions
    'SubscribedContent-338389Enabled', # Tips/tricks for Windows
    'SubscribedContent-338393Enabled', # Settings app suggestions
    'SubscribedContent-353694Enabled', # Settings app
    'SubscribedContent-353696Enabled', # Settings app
    'SubscribedContent-280815Enabled', # Lock screen suggestions
    'SubscribedContent-280817Enabled', # Lock screen tips
    'RotatingLockScreenEnabled',
    'RotatingLockScreenOverlayEnabled'
)
foreach ($n in $cdmKeys) { Set-Reg $cdm $n 0 }
Write-Host '[ok] Start menu / lock screen / settings: suggestions and ads off'

# Advertising ID off.
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
# Tailored experiences (telemetry-personalised tips/ads) off.
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0
Write-Host '[ok] Privacy: advertising ID / tailored experiences off'

# System tray: show ALL background app icons (no collapsed overflow arrow).
# EnableAutoTray=0 disables Windows 10's per-app hide-by-default behaviour.
# Clearing IconStreams forces Windows to rebuild the per-icon visibility
# preferences from scratch — without this, prior "Hide" settings persist.
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'EnableAutoTray' 0
$tray = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify'
foreach ($v in @('IconStreams','PastIconsStream')) {
    Remove-ItemProperty -Path $tray -Name $v -Force -ErrorAction SilentlyContinue
}
Write-Host '[ok] System tray: all icons always visible (IconStreams reset)'

# File Explorer Quick Access: hide recent files and frequent folders.
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowRecent' 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowFrequent' 0
Write-Host '[ok] File Explorer: recent/frequent off'

# Copilot system button (separate from pinned shortcuts).
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' 0
Write-Host '[ok] Taskbar: Copilot button hidden'

# Unpin Edge / Outlook / Copilot from taskbar via Shell COM.
# AppsFolder includes UWP/PWA system-pinned apps that don't appear in
# %APPDATA%\...\User Pinned\TaskBar. Verb label is locale-dependent:
# KO "작업 표시줄에서 제거", EN "Unpin from taskbar".
$shellApp = New-Object -ComObject Shell.Application
$appsNs   = $shellApp.NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}')
function Invoke-UnpinTaskbar {
    param([string]$Pattern)
    if (-not $appsNs) { return }
    $items = @($appsNs.Items() | Where-Object { $_.Name -match $Pattern })
    if ($items.Count -eq 0) { Write-Host "[skip] no app matching '$Pattern'"; return }
    foreach ($item in $items) {
        $verb = $item.Verbs() | Where-Object {
            $n = $_.Name -replace '&', ''
            $n -match '작업 표시줄에서 제거|Unpin from taskbar'
        } | Select-Object -First 1
        if ($verb) {
            $verb.DoIt()
            Write-Host "[ok] unpinned: $($item.Name)"
        } else {
            Write-Host "[skip] not pinned: $($item.Name)"
        }
    }
}
Invoke-UnpinTaskbar 'Edge'
Invoke-UnpinTaskbar 'Outlook'
Invoke-UnpinTaskbar 'Copilot'
Invoke-UnpinTaskbar 'Microsoft Store|^Store$'

# System tray "Meet Now" (지금 모임 시작) button hidden.
$ok = Set-RegHKLM 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'HideSCAMeetNow' 1 'DWord' 'Meet Now'
if ($ok) { Write-Host '[ok] System tray: Meet Now button hidden' }

# Debloat: remove unwanted UWP apps from Start menu.
# Per-user only (no admin needed); provisioned packages stay so new Windows
# users on this machine still get them — that's fine for a single-user box.
# PS7 Appx module needs the Windows PowerShell compat shim.
if ($PSVersionTable.PSEdition -eq 'Core') {
    Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
}
$debloat = @(
    '7EE7776C.LinkedInforWindows',            # LinkedIn
    'Microsoft.MicrosoftOfficeHub',           # Office stub ("Get Office")
    'Microsoft.Todos',                        # Microsoft To Do
    'Microsoft.ZuneVideo',                    # 영화 및 TV
    'Microsoft.MicrosoftSolitaireCollection', # Solitaire / Play
    'Microsoft.GamingApp',                    # Xbox app
    'Microsoft.XboxGamingOverlay',            # Xbox Game Bar (Win+G)
    'Microsoft.BingSearch',                   # Bing Search
    'Microsoft.BingWeather',                  # 날씨
    'Microsoft.GetHelp',                      # 도움말 보기
    'Microsoft.Microsoft3DViewer',            # 3D Viewer
    'Microsoft.MixedReality.Portal',          # MR Portal
    'Microsoft.Office.OneNote',               # OneNote (UWP)
    'Microsoft.People',                       # 사람
    'Microsoft.Windows.PeopleExperienceHost', # People host
    'Microsoft.SkypeApp',                     # Skype
    'Microsoft.Wallet',                       # Wallet
    'Microsoft.WindowsFeedbackHub',           # Feedback Hub
    'Microsoft.WindowsMaps',                  # 지도
    'Microsoft.Xbox.TCUI',                    # Xbox TCUI
    'Microsoft.XboxApp',                      # Xbox app (legacy)
    'Microsoft.XboxGameCallableUI',           # Xbox callable UI
    'Microsoft.XboxGameOverlay',              # Xbox overlay
    'Microsoft.XboxIdentityProvider',         # Xbox auth
    'Microsoft.XboxSpeechToTextOverlay'       # Xbox STT
    # Keep: Microsoft.ScreenSketch (Win+Shift+S — useful)
)
foreach ($p in $debloat) {
    $pkg = Get-AppxPackage -Name $p -ErrorAction SilentlyContinue
    if ($pkg) {
        try {
            $pkg | Remove-AppxPackage -ErrorAction Stop
            Write-Host "[ok] uninstalled: $p"
        } catch {
            Write-Warning "failed to uninstall ${p}: $($_.Exception.Message)"
        }
    } else {
        Write-Host "[skip] not installed: $p"
    }
}

# OneDrive autostart disabled (don't run on login). Doesn't uninstall OneDrive.
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
if (Get-ItemProperty -Path $runKey -Name 'OneDrive' -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path $runKey -Name 'OneDrive' -Force
    Write-Host '[ok] OneDrive autostart removed'
} else {
    Write-Host '[skip] OneDrive autostart already absent'
}
Get-Process -Name OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Default IME for Korean = Nalgaeset (날개셋), and active at login.
# Three pieces:
#  1. ko-KR InputMethodTips: Nalgaeset must be FIRST (per-language default).
#  2. InputMethodOverride: system-wide default IME at sign-in / per-app reset.
#  3. ko-KR profile key may not exist yet — create it.
$msTip  = '0412:{A028AE76-01B1-46C2-99C4-ACD9858AE02F}{B5FE1F02-D5F2-4445-9C03-C568F23C99A1}'

$kor = 'HKCU:\Control Panel\International\User Profile\ko-KR'
if (-not (Test-Path $kor)) { New-Item -Path $kor -Force | Out-Null }
$existing = (Get-ItemProperty -Path $kor -Name 'InputMethodTips' -ErrorAction SilentlyContinue).InputMethodTips
$rest = @($existing | Where-Object { $_ -ne $ngsTip -and $_ })
if ($rest -notcontains $msTip) { $rest += $msTip }
$newTips = ,$ngsTip + $rest
Set-ItemProperty -Path $kor -Name 'InputMethodTips' -Value ([string[]]$newTips) -Type MultiString -Force
Write-Host '[ok] ko-KR InputMethodTips: Nalgaeset first'

# System-wide default IME override (active at login).
Set-ItemProperty -Path 'HKCU:\Control Panel\International\User Profile' `
    -Name 'InputMethodOverride' -Value $ngsTip -Type String -Force
Write-Host '[ok] InputMethodOverride = Nalgaeset (default at login)'

# CTF (TSF) Assemblies: this is the *actually active* IME selection for the
# keyboard category. Without this, Windows boots with MS IME even though
# InputMethodOverride says Nalgaeset.
$ngsClsid    = '{5CC2EDB1-F5F4-456C-A871-CF6B62415CD9}'
$ngsProfile  = '{36207E64-3175-433E-A713-2D0F7473273A}'
$asmKey      = 'HKCU:\Software\Microsoft\CTF\Assemblies\0x00000412\{34745C63-B2F0-4784-8B67-5E12C8701A31}'
if (Test-Path $asmKey) {
    Set-ItemProperty -Path $asmKey -Name 'Default' -Value $ngsClsid   -Type String -Force
    Set-ItemProperty -Path $asmKey -Name 'Profile' -Value $ngsProfile -Type String -Force
    Write-Host '[ok] CTF Assemblies (ko-KR) default = Nalgaeset'
} else {
    Write-Warning 'CTF Assemblies key for ko-KR missing — sign in once with Korean IME first.'
}

# Disable Alt+Shift / Ctrl+Shift / Win+Space input language toggle hotkeys.
# Keyboard Layout\Toggle: 3 = disabled, 1 = Alt+Shift (default), 2 = Ctrl+Shift.
$tog = 'HKCU:\Keyboard Layout\Toggle'
if (-not (Test-Path $tog)) { New-Item -Path $tog -Force | Out-Null }
Set-ItemProperty -Path $tog -Name 'Hotkey'          -Value '3' -Type String -Force
Set-ItemProperty -Path $tog -Name 'Language Hotkey' -Value '3' -Type String -Force
Set-ItemProperty -Path $tog -Name 'Layout Hotkey'   -Value '3' -Type String -Force
Write-Host '[ok] Alt+Shift / Ctrl+Shift language toggle disabled'

# Disable accessibility shortcuts:
#   StickyKeys: Shift x5  (Flags 510 -> 506 clears SKF_HOTKEYACTIVE bit 0x4)
#   FilterKeys: Right Shift held 8s
#   ToggleKeys: NumLock held 5s
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' `
    -Name 'Flags' -Value '506' -Type String -Force
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\Keyboard Response' `
    -Name 'Flags' -Value '122' -Type String -Force
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\ToggleKeys' `
    -Name 'Flags' -Value '58' -Type String -Force
Write-Host '[ok] Accessibility shortcuts (Shift x5 / Right-Shift hold / NumLock hold) disabled'

# pwsh PROFILE: register zoxide (z command) for new shells.
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
$profileBody = (Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue)
if (-not $profileBody) { $profileBody = '' }
if ($profileBody -notmatch 'zoxide init') {
    Add-Content -Path $PROFILE -Value 'Invoke-Expression (& { (zoxide init powershell | Out-String) })'
    Write-Host '[ok] zoxide init added to $PROFILE'
} else {
    Write-Host '[skip] zoxide init already in $PROFILE'
}

# SHELL env var: zellij and other unix-y tools fall back to $SHELL when
# their config doesn't pin a shell. Pin to Git Bash — matches WT default
# profile so zellij `Alt+n` (new pane) opens bash too.
$shellTarget = 'C:\Program Files\Git\bin\bash.exe'
$shell = [Environment]::GetEnvironmentVariable('SHELL', 'User')
if ((Test-Path $shellTarget) -and $shell -ne $shellTarget) {
    [Environment]::SetEnvironmentVariable('SHELL', $shellTarget, 'User')
    Write-Host "[ok] SHELL=$shellTarget (user env, applies to new shells)"
} else {
    Write-Host '[skip] SHELL=Git Bash already (or bash missing)'
}

# Default browser: Firefox (http/https only; .htm/.html stays manual — OS hash protection)
$ff = 'C:\Program Files\Mozilla Firefox\firefox.exe'
if (Test-Path $ff) {
    $httpProg = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice' -Name 'ProgId' -ErrorAction SilentlyContinue).ProgId
    if ($httpProg -like 'FirefoxURL*') {
        Write-Host '[skip]    Default browser: Firefox already'
    } else {
        & $ff -SilentlySetAsDefaultBrowser
        Write-Host '[ok] Default browser: Firefox (http/https)'
    }
} else {
    Write-Warning 'Firefox not found; skipping default browser set.'
}

# Default terminal: Windows Terminal. Routes Win+X / right-click "Open in
# Terminal" / external launches through WT instead of legacy conhost.
$startupKey = 'HKCU:\Console\%%Startup'
if (-not (Test-Path $startupKey)) { New-Item -Path $startupKey -Force | Out-Null }
Set-ItemProperty -Path $startupKey -Name 'DelegationConsole'  -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -Type String -Force
Set-ItemProperty -Path $startupKey -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -Type String -Force
Write-Host '[ok] Default terminal: Windows Terminal'

# Windows Terminal default profile: Git Bash. Reasoning: bash readline
# interprets Ctrl-key bytes directly so all line-edit shortcuts (Ctrl+A/E/W/U/...)
# survive zellij's ConPTY forwarding on Windows. pwsh's PSReadLine relies on
# Win32 ConsoleKeyInfo modifier flags which zellij strips, so Ctrl-keys break
# inside zellij. pwsh remains available via `pwsh` command from any bash pane.
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$gitBashGuid = '{00000000-0000-0000-ba54-000000000002}'
$gitBashExe  = 'C:\Program Files\Git\bin\bash.exe'
if ((Test-Path $wtSettings) -and (Test-Path $gitBashExe)) {
    $cfg = Get-Content $wtSettings -Raw | ConvertFrom-Json
    $existing = $cfg.profiles.list | Where-Object { $_.guid -eq $gitBashGuid -or $_.name -eq 'Git Bash' }
    if (-not $existing) {
        $newProfile = [PSCustomObject]@{
            guid              = $gitBashGuid
            name              = 'Git Bash'
            commandline       = "$gitBashExe -l -i"
            icon              = 'C:\Program Files\Git\mingw64\share\git\git-for-windows.ico'
            startingDirectory = '%USERPROFILE%'
        }
        $cfg.profiles.list = @($cfg.profiles.list) + $newProfile
        Write-Host '[ok] WT: Git Bash profile added'
    }
    $gb = $cfg.profiles.list | Where-Object { $_.guid -eq $gitBashGuid -or $_.name -eq 'Git Bash' } | Select-Object -First 1
    $cfg.defaultProfile = $gb.guid
    $cfg | ConvertTo-Json -Depth 32 | Set-Content -Path $wtSettings -Encoding utf8
    Write-Host "[ok] WT defaultProfile = Git Bash"
} else {
    Write-Warning "Skipping WT default profile change (settings.json or Git Bash missing)."
}

# .bashrc / .bash_profile for Git Bash: starship prompt + zoxide.
# Idempotent: only append when our marker line isn't found.
$bashProfile = Join-Path $env:USERPROFILE '.bash_profile'
$bashLoader  = '[ -f ~/.bashrc ] && . ~/.bashrc'
if (-not (Test-Path $bashProfile)) {
    Set-Content -Path $bashProfile -Value $bashLoader -Encoding utf8
    Write-Host '[ok] .bash_profile created'
} else {
    $bp = (Get-Content $bashProfile -Raw -ErrorAction SilentlyContinue)
    if (-not $bp) { $bp = '' }
    if ($bp -notmatch '\.bashrc') {
        Add-Content -Path $bashProfile -Value $bashLoader
        Write-Host '[ok] .bashrc loader appended to .bash_profile'
    }
}

$bashrc = Join-Path $env:USERPROFILE '.bashrc'
$bashrcSnippet = @'
# starship prompt
command -v starship >/dev/null && eval "$(starship init bash)"

# zoxide (z command)
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# editor
export EDITOR=hx
export VISUAL=hx

# Windows Terminal supports 24-bit color but Git Bash doesn't set COLORTERM,
# so helix falls back to 256-color and mangles the theme palette. Force it.
export COLORTERM=truecolor

# fish-style abbreviation expansion (bash-abbrev-alias).
# Guarded with `*i*` (interactive shell) check because the plugin uses `bind`
# which spams "line editing not enabled" warnings in non-interactive shells.
[[ $- == *i* && -f ~/.local/share/bash-abbrev-alias/abbrev-alias.plugin.bash ]] && \
    source ~/.local/share/bash-abbrev-alias/abbrev-alias.plugin.bash

# carapace: rich completion data (icons + descriptions + flag hints across
# hundreds of CLIs). The data is consumed by bash's complete -F machinery.
[[ $- == *i* ]] && command -v carapace >/dev/null && source <(carapace _carapace bash)

# fzf-tab-completion: replaces bash's "Display all 45 possibilities?"
# prompt with an fzf picker. Pairs with carapace — carapace populates
# the candidate list, fzf-tab-completion renders the menu.
#
# FZF_TMUX_HEIGHT skips the cursor-position DSR query (\e[6n) that
# fzf-bash-completion.sh otherwise issues; the response isn't forwarded
# through Git Bash's MSYS PTY and bash hangs waiting for it on Windows.
if [[ $- == *i* ]] && [ -f ~/.local/share/fzf-tab-completion/bash/fzf-bash-completion.sh ]; then
    export FZF_TMUX_HEIGHT="${FZF_TMUX_HEIGHT:-40%}"
    source ~/.local/share/fzf-tab-completion/bash/fzf-bash-completion.sh
    bind -x '"\t": fzf_bash_completion'
fi

# yazi: y wrapper that cds into yazi-exited dir.
# winpty wraps native Windows TUIs in Git Bash so they get a proper PTY —
# without it, terminal capability query responses get parsed as keystrokes
# (yazi was auto-entering its zoxide picker on launch in plain bash).
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    winpty yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Direct yazi invocation also needs winpty (same PTY query bug as the y wrapper).
# helix and lazygit do NOT take winpty — winpty either strips their truecolor
# (helix) or fails to fix the symptom (lazygit double-key).
alias yazi="winpty yazi"
'@
if (-not (Test-Path $bashrc)) {
    Set-Content -Path $bashrc -Value $bashrcSnippet -Encoding utf8
    Write-Host '[ok] .bashrc created with starship + zoxide'
} else {
    $rc = (Get-Content $bashrc -Raw -ErrorAction SilentlyContinue)
    if (-not $rc) { $rc = '' }
    if ($rc -notmatch 'starship init') {
        Add-Content -Path $bashrc -Value $bashrcSnippet
        Write-Host '[ok] .bashrc updated (starship + zoxide added)'
    } else {
        Write-Host '[skip] .bashrc already has starship'
    }
}

# AltSnap: rebind hotkey from default Alt (A4 A5) to Win keys (5B 5C) so
# Win+drag-anywhere moves a window (GNOME's Super-drag equivalent).
# Also add a startup shortcut so AltSnap runs at login.
$altsnapDir = "$env:APPDATA\AltSnap"
$altsnapExe = "$altsnapDir\AltSnap.exe"
if (Test-Path $altsnapExe) {
    $dni = "$altsnapDir\AltSnap.dni"
    $ini = "$altsnapDir\AltSnap.ini"
    if (-not (Test-Path $ini) -and (Test-Path $dni)) {
        $content = Get-Content $dni -Raw
        $content = $content -replace 'Hotkeys=A4 A5','Hotkeys=5B 5C'
        Set-Content -Path $ini -Value $content -Encoding utf8
        Write-Host '[ok] AltSnap.ini created with Win-key hotkey'
    } elseif (Test-Path $ini) {
        $rc = Get-Content $ini -Raw
        if ($rc -match 'Hotkeys=A4 A5') {
            $rc = $rc -replace 'Hotkeys=A4 A5','Hotkeys=5B 5C'
            Set-Content -Path $ini -Value $rc -Encoding utf8
            Write-Host '[ok] AltSnap.ini Hotkeys updated to Win keys'
        } else {
            Write-Host '[skip] AltSnap.ini already customised'
        }
    }
    $startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\AltSnap.lnk"
    if (-not (Test-Path $startup)) {
        $wsh = New-Object -ComObject WScript.Shell
        $lnk = $wsh.CreateShortcut($startup)
        $lnk.TargetPath = $altsnapExe
        $lnk.WorkingDirectory = $altsnapDir
        $lnk.Save()
        Write-Host '[ok] AltSnap added to user Startup'
    } else {
        Write-Host '[skip] AltSnap startup shortcut already present'
    }
} else {
    Write-Warning 'AltSnap not installed yet (Section A).'
}

# AutoHotkey: register keys.ahk at user Startup so global shortcuts
# (Ctrl+Win+Up/Down for volume etc.) load on login. The .ahk itself is
# deployed in Section D below from config/ahk/keys.ahk.
$ahkExe = "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe"
$ahkScript = "$env:USERPROFILE\.config\ahk\keys.ahk"
if (Test-Path $ahkExe) {
    $ahkLnk = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotkey-keys.lnk"
    if (-not (Test-Path $ahkLnk)) {
        $wsh = New-Object -ComObject WScript.Shell
        $s = $wsh.CreateShortcut($ahkLnk)
        $s.TargetPath = $ahkExe
        $s.Arguments = "`"$ahkScript`""
        $s.WorkingDirectory = (Split-Path $ahkScript)
        $s.Save()
        Write-Host '[ok] AutoHotkey keys.ahk added to user Startup'
    } else {
        Write-Host '[skip] AutoHotkey startup shortcut already present'
    }
} else {
    Write-Warning 'AutoHotkey not installed yet (Section A).'
}

# ============================================================================
# Section D — config deploy (hardlinks repo/config/* into runtime locations)
# ============================================================================
# Editing the repo file applies to the live config immediately because of
# NTFS hard links. For files where Link is omitted we fall back to copy.
#
# Source format note for Nalgaeset: config/nalgaeset.set is NgsEdit's
# editable form; config/imeconf.dat is the byte-different runtime form
# (output of "외부 모듈에 변경 사항 반영"). We deploy the .dat directly.

$repoRoot = $null
if ($MyInvocation.MyCommand.Path) {
    $repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}
if (-not $repoRoot -and (Test-Path "$env:USERPROFILE\git\lens\provision")) {
    $repoRoot = "$env:USERPROFILE\git\lens\provision"
}
$rawBase = 'https://raw.githubusercontent.com/lens0021/lens0021-provision/main'

$configs = @(
    @{ Repo = 'config/imeconf.dat';  Dest = "$env:APPDATA\YmSoft\NgsLib\imeconf.dat" }
    @{ Repo = 'config/zellij.kdl';   Dest = "$env:APPDATA\Zellij\config\config.kdl" }
    # Link = $true uses NTFS hard link so edits to the repo file apply
    # immediately. Only valid when source resolves to a local file (not the
    # downloaded cache from the irm|iex flow).
    @{ Repo = 'config/starship.toml';        Dest = "$env:USERPROFILE\.config\starship.toml"; Link = $true }
    @{ Repo = 'config/helix/config.toml';    Dest = "$env:APPDATA\helix\config.toml";         Link = $true }
    @{ Repo = 'config/helix/languages.toml'; Dest = "$env:APPDATA\helix\languages.toml";      Link = $true }
    @{ Repo = 'config/yazi/yazi.toml';       Dest = "$env:APPDATA\yazi\config\yazi.toml";    Link = $true }
    @{ Repo = 'config/ahk/keys.ahk';         Dest = "$env:USERPROFILE\.config\ahk\keys.ahk"; Link = $true }
    @{ Repo = 'config/powershell/profile.ps1';
       Dest = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1";
       Link = $true }
    # k9s uses %APPDATA%\k9s on Windows (not ~/.config/k9s; XDG_CONFIG_HOME
    # is not set globally, and k9s falls back to os.UserConfigDir there).
    @{ Repo = 'config/k9s/config.yaml';      Dest = "$env:APPDATA\k9s\config.yaml"; Link = $true }
    @{ Repo = 'config/k9s/views.yaml';       Dest = "$env:APPDATA\k9s\views.yaml";  Link = $true }
)

function Resolve-Source {
    param([string]$RepoPath)
    if ($repoRoot) {
        $local = Join-Path $repoRoot ($RepoPath -replace '/', '\')
        if (Test-Path $local) { return $local }
    }
    $cached = Join-Path $env:TEMP ([System.IO.Path]::GetFileName($RepoPath))
    Write-Host "[download] $RepoPath"
    Invoke-WebRequest -Uri "$rawBase/$RepoPath" -OutFile $cached -UseBasicParsing
    return $cached
}

foreach ($cfg in $configs) {
    $src = Resolve-Source -RepoPath $cfg.Repo
    $dst = $cfg.Dest
    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    $wantLink = [bool]$cfg.Link -and -not ($src -like "$env:TEMP\*")  # cache is throwaway, copy only
    if ($wantLink) {
        if (Test-Path $dst) {
            $existing = Get-Item $dst -Force
            if ($existing.LinkType -eq 'HardLink' -and (Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) {
                Write-Host "[skip]   $($cfg.Repo) -> $dst (hardlink)"
                continue
            }
            Remove-Item $dst -Force
        }
        New-Item -ItemType HardLink -Path $dst -Target $src | Out-Null
        Write-Host "[link]   $($cfg.Repo) <-> $dst (hardlink)"
        continue
    }
    if ((Test-Path $dst) -and (Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) {
        Write-Host "[skip]   $($cfg.Repo) -> $dst (already matches)"
        continue
    }
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "[ok]     $($cfg.Repo) -> $dst"
}

# ============================================================================
# Section E — host-specific drivers (gated)
# ============================================================================
# Only runs on the MSI GE62 2QL (2015) which has Intel HD 5600 + GTX 950M.
# Other machines fall through with a [skip] message.

function Test-IsMsiGe62 {
    $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
    if (-not $cs) { return $false }
    $manuMatch  = $cs.Manufacturer -match 'Micro-Star|MSI'
    $modelMatch = $cs.Model -match 'GE62.*2QL|MS-16J2'
    return ($manuMatch -and $modelMatch)
}

if (-not (Test-IsMsiGe62)) {
    Write-Host '[skip]    Section E (drivers): not running on MSI GE62 2QL'
} else {
    Write-Host '[run]     Section E (drivers): host is MSI GE62 2QL'

    $drivers = @(
        @{
            # MSI OEM bundle for Intel HD Graphics 5600 (Broadwell). Microsoft DDI
            # version 20.19.15.4404 = Intel 15.40 series, ~215MB ZIP.
            # Intel DSA / Windows Update do NOT serve drivers for Broadwell anymore
            # (EOL), so MSI OEM is the practical path on this laptop.
            Name        = 'Intel HD 5600 (MSI OEM, 15.40 / DDI 20.19.15.4404)'
            HwIdPattern = 'VEN_8086&DEV_1612'
            Url         = 'https://download.msi.com/nb_drivers/vga/VGA_win64_20.19.15.4404_0xc3fa6128.zip'
            # Intel setup.exe switches: -s (silent), -overwrite (replace existing
            # without prompt). -noreboot is NOT a valid Intel switch.
            SilentArgs  = @('-s', '-overwrite')
        },
        @{
            # NVIDIA GTX 950M (Maxwell). Generic NVIDIA installer (474.30) rejects
            # this laptop with "not compatible with Windows" — likely an MSI OEM
            # branding gate. After removing the failed device in Device Manager,
            # Windows Update auto-installs an older signed driver (382.05) which
            # is sufficient. MSI's HDA(353.74) bundle is a fallback.
            Name        = 'NVIDIA GTX 950M (Windows Update auto / MSI OEM 353.74 fallback)'
            HwIdPattern = 'VEN_10DE&DEV_139A'
            Url         = 'https://download.msi.com/nb_drivers/vga/Win10_x64_HDA(353.74)_10.18.13.5374.zip'
            SilentArgs  = @('-s', '-noreboot')
        }
    )

    $utilities = @(
        @{
            Name               = 'MSI Dragon Gaming Center'
            DisplayNamePattern = 'Dragon Gaming Center'
            Url                = 'https://download.msi.com/uti_exe/nb/Dragon%20Gaming%20Centerv2.0.1701.0601.zip'
            SilentArgs         = @('-s')
        }
    )

    function Test-DriverHealthy {
        param([string]$HwIdPattern)
        $dev = Get-PnpDevice -ErrorAction SilentlyContinue |
            Where-Object { $_.HardwareID -match $HwIdPattern }
        if (-not $dev) { return $true }
        $okStatus    = $dev.Status -eq 'OK'
        $okErrCode   = $dev.ConfigManagerErrorCode -eq 'CM_PROB_NONE' -or `
                       $dev.ConfigManagerErrorCode -eq 0
        $notFallback = $dev.FriendlyName -notmatch 'Basic Display|기본 디스플레이|3D 비디오 컨트롤러|3D Video'
        return ($okStatus -and $okErrCode -and $notFallback)
    }

    function Install-DriverPackage {
        param([string]$Url, [string]$Name, [string[]]$SilentArgs)
        # Some URLs (e.g. Intel DSA) have no extension. Force .exe so Windows
        # actually executes the file.
        $leaf = [System.IO.Path]::GetFileName($Url)
        if (-not [System.IO.Path]::GetExtension($leaf)) { $leaf = "$leaf.exe" }
        $file = Join-Path $env:TEMP $leaf
        if (-not (Test-Path $file)) {
            Write-Host "[download] $Name"
            Write-Host "           $Url"
            Invoke-WebRequest -Uri $Url -OutFile $file -UseBasicParsing
        } else {
            Write-Host "[cached]   $Name -> $file"
        }
        if ($file -like '*.zip') {
            $extractDir = Join-Path $env:TEMP ([System.IO.Path]::GetFileNameWithoutExtension($leaf))
            if (-not (Test-Path $extractDir) -or @(Get-ChildItem $extractDir -ErrorAction SilentlyContinue).Count -eq 0) {
                Write-Host "[extract]  -> $extractDir"
                Expand-Archive -Path $file -DestinationPath $extractDir -Force
            }
            $setup = Get-ChildItem $extractDir -Recurse -Filter 'setup.exe' -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $setup) {
                Write-Warning "${Name}: setup.exe not found under $extractDir"
                return
            }
            $target = $setup.FullName
        } else {
            $target = $file
        }
        Write-Host "[install]  $Name (UAC may prompt; silent install)"
        $proc = Start-Process -FilePath $target -ArgumentList $SilentArgs -Wait -PassThru
        if ($proc.ExitCode -ne 0) {
            Write-Warning "$Name installer exited with $($proc.ExitCode)"
        } else {
            Write-Host "[ok]       $Name installed"
        }
    }

    function Test-UtilityInstalled {
        param([string]$DisplayNamePattern)
        $keys = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
        )
        foreach ($k in $keys) {
            $items = Get-ChildItem $k -ErrorAction SilentlyContinue
            foreach ($it in $items) {
                $p = Get-ItemProperty $it.PSPath -ErrorAction SilentlyContinue
                if ($p.DisplayName -match $DisplayNamePattern) { return $true }
            }
        }
        return $false
    }

    foreach ($d in $drivers) {
        if (Test-DriverHealthy -HwIdPattern $d.HwIdPattern) {
            Write-Host "[skip]     $($d.Name) (already healthy or not present)"
            continue
        }
        Install-DriverPackage -Url $d.Url -Name $d.Name -SilentArgs $d.SilentArgs
    }

    foreach ($u in $utilities) {
        if (Test-UtilityInstalled -DisplayNamePattern $u.DisplayNamePattern) {
            Write-Host "[skip]     $($u.Name) (already installed)"
            continue
        }
        Install-DriverPackage -Url $u.Url -Name $u.Name -SilentArgs $u.SilentArgs
    }
}

Write-Host ''
Write-Host '============================================================'
Write-Host 'Bootstrap done. Manual follow-up:'
Write-Host '  - Open PowerToys once from Start menu (loads keymap).'
Write-Host '  - gh auth login (browser auth).'
Write-Host '  - Restore or generate SSH keys.'
Write-Host '  - Sign out / sign in (or reboot if drivers ran in Section E).'
Write-Host '============================================================'
