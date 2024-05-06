# if test ! -f $HOME/.config/fish/conf.d/port.fish
#   ln -s /usr/local/git/port/user-leslie-snippets/rc/rc.fish $HOME/.config/fish/conf.d/port.fish
# end

# Change key bindings for fzf.fish
# https://github.com/PatrickF1/fzf.fish/blob/main/functions/fzf_configure_bindings.fish
fzf_configure_bindings --variables= --directory=\cv --history=\e\cr

# External sources
if test -e ~/.asdf/asdf.fish
    source ~/.asdf/asdf.fish
end

if status is-interactive && functions -q declair
    declair update_rc
end
