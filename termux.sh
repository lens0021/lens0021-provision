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
curl -L https://github.com/LGUG2Z/helix-vim/raw/master/config.toml -O $HOME/.config/helix
