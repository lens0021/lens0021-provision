#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


echo 'Hello Termux!'
pkg upgrade -y
pkg install -y \
  fish \
;

curl https://gitlab.com/lens0021/provision/-/raw/main/termux.fish | fish
