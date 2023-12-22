if set -q TERMUX
  if [ -z $TMUX ]
    tmux attach || tmux
  end
end
