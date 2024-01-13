if set -q TERMUX_VERSION
  if [ -z $TMUX ]
    tmux attach
  end
end
