if set -q TERMUX_VERSION
  if [ -z $TMUX ]
    tmux attach || tmux
  end
end
