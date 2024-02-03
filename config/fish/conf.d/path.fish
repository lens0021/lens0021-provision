if status is-login
  set -gx PATH $PATH $HOME/.local/bin
  set -gx PATH $PATH $HOME/go/bin
  set -gx PATH $PATH $HOME/.composer/vendor/bin
  set -gx PATH $PATH $HOME/bin
  if set -q KREW_ROOT
    set -gx PATH $PATH $KREW_ROOT/bin
  else if test -d $HOME/.krew/bin
    set -gx PATH $PATH $HOME/.krew/bin
  end
end
