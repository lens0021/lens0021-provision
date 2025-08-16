## Termux

```bash
curl https://gitlab.com/lens0021/provision/-/raw/main/termux.bash | bash
```

Or
```
PROVISION_BRANCH=some-feature-branch
export PROVISION_BRANCH
curl https://gitlab.com/lens0021/provision/-/raw/main/termux.bash | bash

## TODO

### git config
```sh
git config --global user.name "lens0021"
git config --global user.email "lorentz0021@gmail.com"
git config --global --add gitreview.username "lens0021"

git config --global color.status always
git config --global commit.gpgsign true
git config --global core.editor hx
git config --global credential.credentialStore secretservice
git config --global init.defaultBranch main
git config --global merge.conflictstyle diff3 true
git config --global pull.rebase true
git config --global rebase.autostash true
git config --global rerere.enabled true
git config --global submodule.recurse true

git config --global alias.graph 'log --graph --all --decorate --oneline --color'
```

### RPM packages

- mssh
- mysql-client-core-8.0
- tree
- flatpak
- baobab
- ruby-full
- sqlite3
- tracker-miner-fs
- python3-pip
- Keybase (https://prerelease.keybase.io/keybase_amd64.rpm)
- shfmt
- Codium
- GNOMEs
  - gnome-clocks
  - gnome-colors
  - gnome-session
  - gnome-shell
  - gnome-backgrounds
  - gnome-applets
  - gnome-control-center
  - mutter
  - gjs

### APT packages

- evolution-data-server
- python3-pip
- python3-venv
- Keybase (https://prerelease.keybase.io/keybase_amd64.deb)


### NPM packages

- prettier
- eslint
- stylelint

### PIP packages

- flake8
- pytest
- wheel
- pre-commit
- ec2instanceconnectcli (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html#ec2-instance-connect-install)

### flatpak packages

- GIMP
- Inkscape

### Ubuntu

```sh
# Change the background color of grub
if [ "$LINUX_NODENAME" = "debian" ]; then
  cat <<'EOF' >/boot/grub/custom.cfg
set color_normal=light-gray/black
set color_highlight=white/cyan
set menu_color_normal=white/black
set menu_color_highlight=black/white
EOF
fi
```

### What's this

- Slack
- Steam
- Standard Notes
- mwcli
- VS Code

```sh
# Android studio
https://developer.android.com/studio/install#64bit-libs
sudo apt install -y
  libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
curl https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.0.0.16/android-studio-ide-193.6514223-linux.tar.gz -Lo ~/Downloads/android-studio-ide.tar.xz
sudo tar -xzf ~/Downloads/android-studio-ide.tar.xz -C /usr/local
rm ~/Downloads/android-studio-ide.tar.xz

# KakaoTalk
if [ ! -d "$USER_HOME/.local/share/applications/wine/Programs/카카오톡" ]; then
  if [ ! -e ~/Downloads/KakaoTalk_Setup.exe ]; then
    echo "🚀 Install KakaoTalk ($0:$LINENO)"
    curl -L http://app.pc.kakao.com/talk/win32/KakaoTalk_Setup.exe -o ~/Downloads/KakaoTalk_Setup.exe
  fi
else
  echo 'Skip install KakaoTalk'
fi

if ! grep 'GPG_TTY' "$USER_HOME/.bashrc" >/dev/null; then
  # shellcheck disable=2016
  echo 'GPG_TTY=$(tty); export GPG_TTY' >>"$USER_HOME/.bashrc"
  mkdir -p "$USER_HOME/.gnupg"
  echo 'default-cache-ttl 3600' >>"$USER_HOME/.gnupg/gpg-agent.conf"
fi

# Debian
echo "🚀 Install Git Credential Manager Core ($0:$LINENO)"
curl -sSL https://packages.microsoft.com/config/ubuntu/21.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
sudo apt-get update
sudo apt-get install -y gcmcore
git-credential-manager-core configure
```
