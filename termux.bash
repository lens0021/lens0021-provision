#!/bin/bash
set -duxo pipefail
IFS=$'\n\t'

if ! command -v fish; then
  pkg upgrade -y
  pkg install -y \
    fish \
  ;
fi

curl https://gitlab.com/lens0021/provision/-/raw/main/termux.fish | fish -d 3
