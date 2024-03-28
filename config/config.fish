# .fishrc

set -x PAGER 'less -r'
set -x GPG_TTY $(tty)
set -x KUBE_EDITOR hx
set -x EDITOR hx

# if test ! -f $HOME/.config/fish/conf.d/port.fish
#   ln -s /usr/local/git/port/user-leslie-snippets/rc/rc.fish $HOME/.config/fish/conf.d/port.fish
# end

# Update fish configurations

set -l src $HOME/git/lens/provision/config/fish/conf.d
set -l dist $HOME/.config/fish/conf.d

# Use Ctrl+F instead of Ctrl+Alt+F for directory
# https://github.com/PatrickF1/fzf.fish/blob/main/functions/fzf_configure_bindings.fish
fzf_configure_bindings --directory=\cf

# Remove lens- prefixed files do not exist on the source directory
for conf in $dist/lens-*
    set -l name (string replace -a 'lens-' '' (basename $conf))
    if test ! -f $src/$conf
        rm $dist/lens-$name
    end
end

# Create symlinks if not exists
for conf in $src/*
    set -l name $(basename $conf)
    if test ! -f $dist/lens-$name
        ln -s $src/$name $dist/lens-$name
    end
end

# External sources
if test -e ~/.asdf/asdf.fish
    source ~/.asdf/asdf.fish
end

if status is-interactive && functions -q declair
    declair update_rc
end
