# PowerShell 7 user profile.
# Hardlinked into $PROFILE by 6th-step.ps1.

# Editor for visual line edit (Ctrl+X Ctrl+E) and external tools.
$env:EDITOR = 'hx'
$env:VISUAL = 'hx'

# zoxide (z command).
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# starship prompt.
Invoke-Expression (&starship init powershell)

# PSReadLine: bash readline parity. Key bindings are always safe to set,
# even in non-interactive hosts. Only the prediction *options* require a
# real VT and get guarded to avoid noisy errors under `pwsh -c` etc.
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -WordDelimiters " /\:.,;|()[]{}<>'`""
Set-PSReadLineOption -BellStyle None  # bash sets bell-style none too

# Comprehensive bash readline (Emacs mode) keymap. One Set-... per binding,
# matching `bind -P` defaults from a stock bash. PSReadLine fns chosen for
# semantic equivalence (Kill* preserves the kill-ring so Ctrl+Y yanks).
$bashKeys = @{
    # Cursor motion
    'Ctrl+a'    = 'BeginningOfLine'
    'Ctrl+e'    = 'EndOfLine'
    'Ctrl+b'    = 'BackwardChar'
    'Alt+b'     = 'BackwardWord'
    'Alt+f'     = 'ForwardWord'

    # Editing / kill ring
    'Ctrl+h'    = 'BackwardDeleteChar'
    'Ctrl+d'    = 'DeleteCharOrExit'
    'Ctrl+k'    = 'KillLine'          # cut to end of line
    'Ctrl+u'    = 'BackwardKillLine'  # cut from start to cursor
    'Ctrl+w'    = 'BackwardKillWord'  # cut prev word (whitespace-bounded)
    'Alt+d'     = 'KillWord'          # cut next word
    'Alt+Backspace' = 'BackwardKillWord'
    'Ctrl+y'    = 'Yank'              # paste from kill ring
    'Ctrl+t'    = 'SwapCharacters'    # bash's transpose-chars
    'Alt+u'     = 'UpcaseWord'
    'Alt+l'     = 'DowncaseWord'
    'Alt+c'     = 'CapitalizeWord'

    # Control flow
    'Ctrl+c'    = 'CancelLine'        # abort current input, blank prompt
    'Ctrl+g'    = 'Abort'             # abort an in-progress operation
    'Ctrl+l'    = 'ClearScreen'

    # History
    'Ctrl+r'    = 'ReverseSearchHistory'
    'Ctrl+s'    = 'ForwardSearchHistory'
    'Ctrl+p'    = 'PreviousHistory'
    'Ctrl+n'    = 'NextHistory'
    'Alt+.'     = 'YankLastArg'
    'Alt+_'     = 'YankLastArg'

    # Misc
    'Alt+r'     = 'RevertLine'
    'Ctrl+_'    = 'Undo'

    # Inline-prediction acceptance (fish-style; not in bash but useful)
    'Ctrl+f'    = 'AcceptNextSuggestionWord'
    'Ctrl+RightArrow' = 'AcceptNextSuggestionWord'
}
foreach ($key in $bashKeys.Keys) {
    Set-PSReadLineKeyHandler -Key $key -Function $bashKeys[$key]
}

# Chord bindings (multi-key sequences).
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+e' -Function ViEditVisually  # edit line in $EDITOR
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+u' -Function Undo

# Prediction view requires VT — guard so non-interactive hosts stay quiet.
if ($Host.UI.SupportsVirtualTerminal -and -not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle InlineView
}

# Coreutils: shadow built-in pwsh aliases (Get-ChildItem etc.) so
# `ls`/`cat`/`mv`/`cp` invoke the GNU coreutils bundled with Git Bash.
# Hardcoded path because Get-Command scans the whole PATH and is ~70ms
# slower per shell startup at this scale.
$gnuBin = 'C:\Program Files\Git\usr\bin'
if (Test-Path $gnuBin) {
    $coreutils = @(
        'ls', 'cat', 'cp', 'mv', 'rm', 'rmdir', 'mkdir', 'ln', 'touch',
        'head', 'tail', 'wc', 'sort', 'uniq', 'cut', 'tr', 'tee',
        'echo', 'printf', 'true', 'false', 'test', 'yes', 'sleep', 'seq',
        'basename', 'dirname', 'realpath', 'readlink',
        'date', 'whoami', 'id', 'uname', 'env', 'printenv',
        'df', 'du', 'stat', 'find', 'which',
        'md5sum', 'sha1sum', 'sha256sum', 'base64', 'tac'
    )
    foreach ($b in $coreutils) {
        $exe = "$gnuBin\$b.exe"
        if (Test-Path $exe) {
            Remove-Item -Path "Alias:$b" -Force -ErrorAction SilentlyContinue
            Set-Alias -Name $b -Value $exe -Scope Global -Force
        }
    }
}

# Useful bash-isms.
function which { param([string]$cmd) (Get-Command $cmd -ErrorAction SilentlyContinue).Source }
