#!/bin/bash

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
  less \
  lsblk \
  nodejs \
  perl \
  php \
  python \
  ripgrep \
  rust-analyzer \
  termux-api \
  tmux \
  vim \
;

cp -f termux_bashrc ~/.bashrc
curl -L https://github.com/LGUG2Z/helix-vim/raw/master/config.toml -O $HOME/.config/helix
tee << EOF >$HOME/.tmux.conf
set-window-option -g mode-keys vi
EOF

hx -g fetch
hx -g build