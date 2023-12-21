# .fishrc

set PAGER 'less -r'
export PAGER

set GPG_TTY $(tty)
export GPG_TTY

set KUBE_EDITOR hx
export KUBE_EDITOR

# if test ! -f $HOME/.config/fish/conf.d/port.fish
#   ln -s /usr/local/git/port/user-leslie-snippets/rc/rc.fish $HOME/.config/fish/conf.d/port.fish
# end

# Update fish configurations

set -l src $HOME/git/lens/provision/config/fish/conf.d
set -l dist $HOME/.config/fish/conf.d

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
