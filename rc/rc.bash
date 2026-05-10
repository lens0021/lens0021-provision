# .bashrc

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
export PATH

PAGER='less -r'
export PAGER

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
alias kc='kubectl'

y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Completions
[ -f "$HOME/.asdf/asdf.sh" ] && source "$HOME/.asdf/asdf.sh"
[ -f "$HOME/.asdf/completions/asdf.bash" ] && source "$HOME/.asdf/completions/asdf.bash"
if command -v terraform >/dev/null ; then
	complete -C /usr/bin/terraform terraform
fi

complete -C /home/nemo/.terraform.versions/terraform_1.6.5 terraform

complete -C /usr/bin/tofu tofu

# fzf.fish-style key bindings (interactive only — `bind` errors out
# in non-interactive shells with "line editing not enabled").

# Ctrl+R — history search. Sorted by recency, dedup, toggle-sort with Ctrl+R.
__lens_fzf_history__() {
    local out
    out=$(
        builtin history | sed 's/^[ ]*[0-9]\+[ ]*//' | awk '!seen[$0]++' | tac \
        | fzf --height 90% --layout=reverse --border --cycle \
              --prompt="History> " \
              --scheme=history --no-sort --tiebreak=index \
              --bind=ctrl-r:toggle-sort \
              --preview='printf %s {}' \
              --preview-window=bottom:3:wrap \
              --query="$READLINE_LINE"
    ) || return
    READLINE_LINE="$out"
    READLINE_POINT=${#out}
}
if [[ $- == *i* ]]; then
bind -x '"\C-r": __lens_fzf_history__'

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
if command -v sheldon >/dev/null; then
    eval "$(sheldon source)"
fi

# fish-style abbreviations via bash-abbrev-alias (loaded by sheldon above).
if [[ $- == *i* ]] && type abbrev-alias >/dev/null 2>&1; then
    abbrev-alias zz='z $(zoxide query -i)'
fi

if command -v starship >/dev/null; then
    eval "$(starship init bash)"
fi

# zoxide must be initialized last so nothing overwrites its cd hook.
if command -v zoxide >/dev/null; then
    eval "$(zoxide init bash)"
fi
