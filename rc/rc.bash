# .bashrc

# Reentry guard: this file is in ~/.bashrc.d but also loops over ~/.bashrc.d
# itself, so on OSes (e.g. Fedora) where ~/.bashrc already does that loop,
# fragments would be sourced twice.
[ -n "${_LENS_RC_LOADED:-}" ] && return
_LENS_RC_LOADED=1

# Source global definitions
if [ -f /etc/bashrc ]; then
	source /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ $HOME/.local/bin: ]]; then
	PATH="$HOME/.local/bin:$PATH"
fi
if ! [[ "$PATH" =~ $HOME/bin: ]]; then
	PATH="$HOME/bin:$PATH"
fi
if ! [[ "$PATH" =~ $HOME/.krew/bin: ]]; then
  PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi
if ! [[ "$PATH" =~ ${ASDF_DATA_DIR:-$HOME/.asdf}/shims: ]]; then
  PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
fi
export PATH

PAGER='less -r'
LESS='--mouse --wheel-lines=3'
export PAGER LESS

HELM_DIFF_COLOR=true
HELM_DIFF_OUTPUT=dyff
HELM_DIFF_USE_UPGRADE_DRY_RUN=true
export HELM_DIFF_COLOR HELM_DIFF_OUTPUT HELM_DIFF_USE_UPGRADE_DRY_RUN

TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
export TF_PLUGIN_CACHE_DIR

# Fish-style history: very large size + erasedups means re-used commands
# lose their old entry and move to the end (LRU-like), nothing drops by age.
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignorespace:erasedups
shopt -s histappend
# Append each command to history immediately so it's shared across sessions.
# PROMPT_COMMAND may be an array (bash 5.1+, used by /etc/profile.d/vte.sh).
if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" =~ "declare -a" ]]; then
	PROMPT_COMMAND+=('history -a')
else
	PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi
shopt -s autocd
shopt -s globstar
shopt -s cdspell

GPG_TTY=$(tty)
export GPG_TTY

EDITOR=hx
VISUAL=hx
KUBE_EDITOR=hx
export EDITOR VISUAL KUBE_EDITOR

# Load ~/.bashrc.d fragments, skipping this file to prevent recursion on OSes
# (e.g. Fedora) that already loop over ~/.bashrc.d from their default ~/.bashrc.
if [ -d ~/.bashrc.d ]; then
	_self="$(realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"
	for rc in ~/.bashrc.d/*; do
		[ -f "$rc" ] || continue
		[ "$(realpath "$rc" 2>/dev/null || echo "$rc")" = "$_self" ] && continue
		source "$rc"
	done
	unset _self rc
fi

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# User specific aliases
alias pbcopy='wl-copy'
alias pbpaste='wl-paste'

# Completions
if command -v asdf >/dev/null; then
	source <(asdf completion bash)
fi
if command -v terraform >/dev/null ; then
	complete -C /usr/bin/terraform terraform
fi


complete -C /usr/bin/tofu tofu

# fzf bash integration: Ctrl+R (history), Alt+C (cd-into-dir), **<Tab> trigger.
# Options for the Ctrl+R widget are customised via FZF_CTRL_R_OPTS instead of
# a hand-rolled bind -x widget. Dedup is already handled by HISTCONTROL=erasedups.
export FZF_CTRL_R_OPTS="
    --height=90% --layout=reverse --border --cycle
    --prompt='History> '
    --scheme=history --no-sort --tiebreak=index
    --bind=ctrl-r:toggle-sort
    --preview='printf %s {}'
    --preview-window=bottom:3:wrap"

if [[ $- == *i* ]]; then
# `bind` errors out in non-interactive shells with "line editing not enabled",
# so the fzf eval and all bind calls are gated to interactive sessions.
eval "$(fzf --bash)"
# fzf rebinds Ctrl+T to its file widget; restore readline's transpose-chars
# because the Ctrl+V file picker below already covers that need.
bind '"\C-t": transpose-chars'

# Ctrl+V — file picker, inserts path at cursor. fd + bat (fallback find/cat).
__lens_fzf_files__() {
    local preview cmd selected
    if command -v bat >/dev/null; then
        preview='bat --style=numbers --color=always --line-range :200 {}'
    else
        preview='cat {}'
    fi
    if command -v fd >/dev/null; then
        cmd='fd --hidden --exclude .git --type f'
    else
        cmd='find . -type f -not -path "*/.git/*"'
    fi
    selected=$(eval "$cmd" | fzf \
        --height 90% --layout=reverse --border --cycle \
        --prompt="Files> " \
        --preview="$preview" \
        --preview-window=right:60%:wrap) || return
    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}$selected${READLINE_LINE:READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
}
# Ctrl+V: stty's lnext (default ^V) intercepts at the terminal driver
# layer before bash readline sees it, so `bind -x` alone can't override.
# Disable lnext so the keypress reaches readline, then point it at our fn.
stty lnext undef 2>/dev/null
bind -r '"\C-v"' 2>/dev/null
bind -x '"\C-v": __lens_fzf_files__'
fi  # interactive

# Plugin manager — loads bash-abbrev-alias and any future plugins.
# Skip on Windows (Git Bash): windows/bootstrap.ps1 sources bash-abbrev-alias
# directly, and sheldon 0.8.5 fails to lock its config dir under MSYS.
if [[ "$OSTYPE" != msys* && "$OSTYPE" != cygwin* ]] && command -v sheldon >/dev/null; then
    eval "$(sheldon source)"
fi

# carapace: fish-style completions with descriptions for hundreds of CLIs.
if command -v carapace >/dev/null; then
    source <(carapace _carapace bash)
fi

# fzf-tab-completion + carapace: route Tab through fzf, with descriptions
# from carapace export JSON for any of its 700+ known CLIs. Falls back to
# fzf_bash_completion (bash's native compspec) for everything else.
_lens_carapace_tab() {
    local before="${READLINE_LINE:0:READLINE_POINT}"
    local after="${READLINE_LINE:READLINE_POINT}"
    local words cmd cur trailing_space=0
    read -ra words <<< "$before"
    cmd="${words[0]}"

    if [ -z "$cmd" ] || ! command -v carapace >/dev/null; then
        fzf_bash_completion; return
    fi
    if [ -z "$_LENS_CARAPACE_CMDS_LOADED" ]; then
        declare -gA _LENS_CARAPACE_CMDS=()
        local _c
        while IFS= read -r _c; do _LENS_CARAPACE_CMDS["$_c"]=1; done \
            < <(carapace --list 2>/dev/null | jq -r 'keys[]' 2>/dev/null)
        _LENS_CARAPACE_CMDS_LOADED=1
    fi
    if [ -z "${_LENS_CARAPACE_CMDS[$cmd]}" ]; then
        fzf_bash_completion; return
    fi

    if [[ "${before: -1}" == " " ]]; then
        trailing_space=1
        words+=("")
    else
        cur="${words[-1]}"
    fi

    local items
    items=$(carapace "$cmd" export "${words[@]}" 2>/dev/null \
        | jq -r '.values[]? | [.value, (.description // "")] | @tsv')
    [ -z "$items" ] && return

    local sel
    sel=$(printf '%s\n' "$items" \
        | fzf --height=40% --layout=reverse --border --cycle --ansi \
              --delimiter=$'\t' --with-nth=1 --nth=1 \
              --preview='printf %s {2}' \
              --preview-window=bottom:3:wrap \
              --query="$cur" --prompt="$cmd> ") || return
    local val="${sel%%$'\t'*}"
    [ -z "$val" ] && return

    local new_before
    if [ "$trailing_space" -eq 1 ]; then
        new_before="$before$val"
    else
        new_before="${before:0:${#before}-${#cur}}$val"
    fi
    READLINE_LINE="$new_before$after"
    READLINE_POINT=${#new_before}
}
if [[ $- == *i* ]] && type fzf_bash_completion >/dev/null 2>&1; then
    if command -v carapace >/dev/null && command -v jq >/dev/null; then
        bind -x '"\t": _lens_carapace_tab'
    else
        bind -x '"\t": fzf_bash_completion'
    fi
fi

# fish-style abbreviations via bash-abbrev-alias (loaded by sheldon above).
if [[ $- == *i* ]] && type abbrev-alias >/dev/null 2>&1; then
    abbrev-alias zz 'z $(zoxide query -i)'
    abbrev-alias gitgraph 'git log --graph --all --decorate --oneline --color'
    abbrev-alias kc 'kubectl'
    abbrev-alias tf 'terraform'
    # abbrev-alias --set-cursor --command git switchor 'cd '\$'(git switch % 2>&1 | awk '\''{print $NF}'\'' | tr -d '\"\'\"')'
    abbrev-alias gitdelta "git -c 'core.pager=delta -s'"
    # The fish-clone CLI has no expansion-time eval (the old -e), so the
    # subshell runs when the expanded line is executed: typing `awsctx`
    # and pressing Enter pops the fzf profile picker, then exports the
    # pick. On fzf cancel, falls back to the current profile.
    abbrev-alias awsctx 'export AWS_PROFILE=$(aws configure list-profiles 2>/dev/null | fzf || echo "${AWS_PROFILE:-default}")'
    abbrev-alias fw-aws-sso 'echo https://femiwiki.awsapps.com/start/# ap-northeast-2; aws --profile fw configure sso'
    abbrev-alias fw-ec2 'aws --profile fw --region ap-northeast-1 ec2 describe-instances --query "Reservations[*].Instances[*].[to_string(Tags), State.Name, InstanceId, PrivateIpAddress, LaunchTime]" --output table'
    abbrev-alias y 'tmp=$(mktemp -t yazi-cwd.XXXXXX) && yazi --cwd-file="$tmp"; cwd=$(<"$tmp"); rm -f "$tmp"; [[ -n $cwd && $cwd != "$PWD" ]] && cd "$cwd"'
    abbrev-alias prefer-light 'gsettings set org.gnome.desktop.interface color-scheme prefer-light'
    abbrev-alias prefer-dark 'gsettings set org.gnome.desktop.interface color-scheme prefer-dark'
fi

if command -v starship >/dev/null; then
    eval "$(starship init bash)"
fi

# zoxide must be initialized last so nothing overwrites its cd hook.
if command -v zoxide >/dev/null; then
    eval "$(zoxide init bash)"
fi
