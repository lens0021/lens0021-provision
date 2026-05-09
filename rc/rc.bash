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

KUBE_EDITOR=hx
export KUBE_EDITOR

# User specific functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			source "$rc"
		fi
	done
fi
unset rc

[ -f ~/git/port/leslie-kit/rc/rc.bash ] && source ~/git/port/leslie-kit/rc/rc.bash
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# User specific aliases
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
alias kc='kubectl'

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
        | fzf --height 100% --reverse \
              --prompt="History> " \
              --scheme=history --no-sort --tiebreak=index \
              --bind=ctrl-r:toggle-sort \
              --preview='printf %s {}' \
              --preview-window=down:3:wrap \
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
        --height 100% --reverse \
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

# fish-style abbreviations (relies on abbrev-alias plugin sourced earlier).
if [[ $- == *i* ]] && type abbrev-alias >/dev/null 2>&1; then
    abbrev-alias zz='z $(zoxide query -i)'
fi
