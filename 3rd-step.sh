#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Rclone
systemctl --user enable rclone@dropbox

# systemd-oomd, which the Fedora preset enables but this machine had switched
# off. Swap is zram-only, so a memory pressure spike livelocks the whole desktop
# instead of costing one app.
sudo systemctl enable --now systemd-oomd.service

# Compositor freeze recovery. gnome-shell wedges here every day or two with the
# kernel still healthy, and every manual escape is blocked: Ctrl+Alt+F3 never
# reaches logind because mutter holds the keyboard, the power key is swallowed
# by gsd-media-keys' block inhibitor, and SysRq cannot be typed because PrtScr
# is Fn+F10 and the EC suppresses other keys while Fn is held. The watchdog
# pings the shell over D-Bus and restarts gdm when it stops answering, takes a
# triple power-button press as an immediate trigger, and suspends on lid close
# since GNOME declines to while the dock's monitor is attached.
#
# These are copied rather than declared as `sym` entries in
# config/declair.json. SELinux labels everything under /home user_home_t, and
# init_t may not execute that, so systemd fails the unit with a bare
# "Permission denied" if ExecStart points into the checkout. /home is also its
# own btrfs subvolume, and systemd-sysctl and systemd's unit scan both run
# around the time it is mounted, so a symlink into $HOME can dangle at boot and
# drop the setting silently.
sudo install -m 0755 ~/git/lens/provision/bin/gnome-shell-watchdog /usr/local/bin/
sudo install -m 0644 ~/git/lens/provision/config/sysrq.conf /etc/sysctl.d/99-sysrq.conf
sudo sysctl --system >/dev/null
sudo install -m 0644 ~/git/lens/provision/systemd/gnome-shell-watchdog.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now gnome-shell-watchdog.service

# KakaoTalk. Lives in its own repo now: the setup is long, most of it is
# knowledge about Wine and GNOME rather than anything personal, and it is of
# no use to anyone buried in here.
KAKAOTALK=~/git/chaotic-ground/kakaotalk-on-wine
if [ ! -d "$KAKAOTALK" ]; then
  git clone https://github.com/chaotic-ground/kakaotalk-on-wine "$KAKAOTALK"
fi
"$KAKAOTALK/bin/kakaotalk-bottle"

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
