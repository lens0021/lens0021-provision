#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo 'Hello Termux!'
pkg upgrade -y
pkg install -y \
  curl \
  file \
  fzf \
  gh \
  git \
  glab-cli \
  golang \
  helix \
  htop \
  kubectl \
  less \
  lsblk \
  nodejs \
  perl \
  php \
  python \
  ripgrep \
  rust-analyzer \
  teleport-tsh \
  termux-api \
  tmux \
  vim \
;

cp -f config/termux_bashrc ~/.bashrc
cp -f config/.tmux.conf "$HOME"/

hx -g fetch
hx -g build
