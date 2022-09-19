#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Docker
newgrp docker

# Auto remove
sudo apt autoremove

# KakaoTalk
sed -i 's/Exec=env WINEPREFIX/Exec=env LANG="ko_KR.UTF-8" WINEPREFIX/' \
  ~/.local/share/applications/wine/Programs/카카오톡/카카오톡.desktop

rm ~/Downloads/KakaoTalk_Setup.exe
rm -f \
  "$HOME/.local/share/applications/wine/Programs/카카오톡/카카오톡 제거.desktop" \
  "$HOME/.local/share/applications/wine/카카오톡.desktop" \
  ~/Desktop/카카오톡.desktop

sudo ln -s "$HOME/.local/share/gnome-shell/extensions/extensions-sync@elhan.io/schemas/org.gnome.shell.extensions.extensions-sync.gschema.xml" \
  /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

# gsettings
gsettings set org.gnome.shell.extensions.extensions-sync github-gist-id '664f4ff3d51321454848b469817d22b2'
gsettings set org.gnome.shell.extensions.extensions-sync github-user-token "'$(cat ~/secrets/github-gist-token.txt)'"
gsettings set org.gnome.shell favorite-apps "[
  'org.gnome.Nautilus.desktop',
  'org.gnome.Terminal.desktop',
  'org.gnome.gedit.desktop',
  'code.desktop',
  'google-chrome.desktop',
  'discord_discord.desktop',
  'wine-Programs-카카오톡-카카오톡.desktop'
]"

#
# Wine
#
WINEPREFIX=~/.wine wine wineboot
# Change Wine system font (NanumGothic.ttf)
sed -i 's/"MS Shell Dlg"="Tahoma"/"MS Shell Dlg"="NanumGothic"/' ~/.wine/system.reg
sed -i 's/"MS Shell Dlg 2"="Tahoma"/"MS Shell Dlg 2"="NanumGothic"/' ~/.wine/system.reg
# Setup font
mkdir -p ~/.wine/drive_c/windows/Fonts/
case $LINUX_NODENAME in
  "fedora")
    cp /usr/share/fonts/naver-nanum/NanumGothic.ttf ~/.wine/drive_c/windows/Fonts/
    ;;
  "debian" | 'ubuntu')
    cp /usr/share/fonts/truetype/nanum/NanumGothic.ttf ~/.wine/drive_c/windows/Fonts/
    ;;
esac

# ADB
sudo ln -s "$HOME/Android/Sdk/platform-tools/adb" /usr/bin/adb

# Android studio
sudo chown -R $USER:$USER android-studio/

# ssh
curl -L https://gitlab.com/lens0021/provision/-/blob/main/public_keys/id_rsa.pub -o "$HOME/.ssh/id_rsa.pub"

# GPG
curl -L https://gitlab.com/lens0021/provision/-/blob/main/public_keys/gpg.pub -o ~/Downloads/gpg.pub
gpg --import ~/Downloads/gpg.pub

# VS Code extension Settings Sync
json -I -f "$HOME/.config/Code/User/settings.json" -e "this['sync.gist']=\"d96773286d3d0b34c84581c5078d34ad\""
json -I -f "$HOME/.config/Code/User/syncLocalSettings.json" -e "this.token=\"$(cat ~/secrets/github-gist-token.txt)\""

# Purge
rm -rf ~/secrets
rm ~/Downloads/*
rm ~/Desktop/chrome-*-Default.desktop
rm ~/Desktop/steam.desktop
