#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

if ! command -v fish; then
  if [[ -n $TERMUX_VERSION ]]; then
    pkg upgrade -y
    pkg install -y fish
  else
    dnf install -y fish
  fi
fi

curl https://gitlab.com/lens0021/provision/-/raw/main/termux.fish | fish -d 3
