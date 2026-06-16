#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

if ! command -v fish >/dev/null; then
  if [[ -n $TERMUX_VERSION ]]; then
    DEBIAN_FRONTEND=noninteractive
    export DEBIAN_FRONTEND
    pkg upgrade -y
    pkg install -y fish
  else
    dnf install -y fish
  fi
fi

# Install Termux launchers (Claude Code via Alpine proot, with the fd-limit
# startup fix; see termux/bin/claude). Needs a local checkout of the repo.
PROVISION_DIR="${PROVISION_DIR:-$HOME/git/lens/provision}"
if [ ! -d "$PROVISION_DIR/.git" ]; then
  command -v git >/dev/null || pkg install -y git
  git clone "https://gitlab.com/lens0021/provision.git" "$PROVISION_DIR"
fi
bash "$PROVISION_DIR/termux/install.bash"

curl -L "https://gitlab.com/lens0021/provision/-/raw/${PROVISION_BRANCH:-main}/termux.fish" | fish -d debug
