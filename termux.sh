#!/bin/bash

echo 'Hello Termux!'
pkg upgrade -y
pkg install -y \
  vim \
  tmux \
  fzf \
  gh \
  glab-cli \
  htop \
  php \
  python \
  less \
  ripgrep \
  git \
  curl \
  termux-api \
  helix \
  nodejs \
  golang \
  perl \
  file \
;

cp -f termux_bashrc ~/.bashrc