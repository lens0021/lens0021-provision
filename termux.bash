#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

if ! command -v fish >/dev/null; then
  if [[ -n $TERMUX_VERSION ]]; then
    pkg upgrade -y
    pkg install -y fish
  else
    dnf install -y fish
  fi
fi

curl -L https://gitlab.com/lens0021/provision/-/raw/main/termux.fish | fish -d debug
