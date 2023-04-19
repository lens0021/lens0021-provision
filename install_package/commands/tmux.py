from command import Command

class tmux(Command):
  NAME = 'tmux-attach'

  SCRIPT = '''
# tmux-attach
if [ -z "$TMUX" ]; then
  if tmux has-session; then
    tmux -2 attach
  else
    tmux -2;
  fi
fi
'''
