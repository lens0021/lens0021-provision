if set -q TERMUX_VERSION
  if [ -z $TMUX ]
    tmux attach
    if test $status -ne 0
      tmux
    end
  end
end
