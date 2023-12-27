function create-symlink
  set -l src (realpath $argv[1])
  set -l dist $argv[2]

  if test ! -f $dist
    mkdir -p (dirname $dist)
    ln -s $src $dist
  end
end

set -l pr_dir $HOME/git/lens/provision

create-symlink $pr_dir/config/tmux.conf $HOME/.config/tmux/tmux.conf
create-symlink $pr_dir/config/helix/config.toml $HOME/.config/helix/config.toml
create-symlink $HOME/.asdf/completions/asdf.fish $HOME/.config/fish/completions/asdf.fish

