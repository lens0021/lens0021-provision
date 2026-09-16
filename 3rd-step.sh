#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Rclone
systemctl --user enable rclone@dropbox

# KakaoTalk, in a Bottles bottle rather than a bare ~/.wine prefix
~/git/lens/provision/bin/kakaotalk-bottle

# gsettings
SCHEMADIR=~/.local/share/gnome-shell/extensions/extensions-sync@elhan.io/schemas
gsettings --schemadir $SCHEMADIR set org.gnome.shell.extensions.extensions-sync provider Gitlab
gsettings --schemadir $SCHEMADIR set org.gnome.shell.extensions.extensions-sync gitlab-snippet-id 2401246
gsettings --schemadir $SCHEMADIR set org.gnome.shell.extensions.extensions-sync gitlab-user-token "'$(bw get password f4de295d-c2bc-4d78-841d-af1500c7f2de)'"
gsettings set org.gnome.shell.extensions.extensions-sync gitlab-gist-id '2401246'
gsettings set org.gnome.shell.extensions.extensions-sync gitlab-user-token "'$(bw get password f4de295d-c2bc-4d78-841d-af1500c7f2de)'"

# GJS OSK: the split layout rides along in gsettings via extensions-sync, but
# the F/J homing marks live in the label cache and have to be redrawn.
~/git/lens/provision/bin/gjs-osk-homing-marks

# ADB
# sudo ln -s "$HOME/Android/Sdk/platform-tools/adb" /usr/bin/adb

# Android studio
# sudo chown -R $USER:$USER android-studio/

# ssh
mkdir -p $HOME/.ssh
curl -L https://gitlab.com/lens0021/provision/-/raw/main/public_keys/id_rsa.pub -o "$HOME/.ssh/id_rsa.pub"

# GPG
curl -L https://gitlab.com/lens0021/provision/-/raw/main/public_keys/gpg.pub -o ~/Downloads/gpg.pub
gpg --import ~/Downloads/gpg.pub

# VS Code extension Settings Sync
# json -I -f "$HOME/.config/Code/User/settings.json" -e "this['sync.gist']=\"d96773286d3d0b34c84581c5078d34ad\""
# json -I -f "$HOME/.config/Code/User/syncLocalSettings.json" -e "this.token=\"$(cat ~/secrets/github-gist-token.txt)\""

# Purge
rm ~/Desktop/chrome-*-Default.desktop || true
rm ~/Desktop/steam.desktop || true
