#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

export LINUX_NODENAME="$(uname -n)"
# export LINUX_ID="$(lsb_release --id --short)"

#
# Bluetooth
#
rfkill block bluetooth

# curl
# TODO: Do Ubuntu and Debian have curl?
if [ $LINUX_NODENAME != 'fedora' ]; then
  sudo apt install -y curl
fi

# Google Chrome
case $LINUX_NODENAME in
  "fedora")
    curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -o ~/Downloads/google-chrome.deb
    ;;
  "debian")
    curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o ~/Downloads/google-chrome.deb
    sudo dpkg -i ~/Downloads/google-chrome-stable_current_amd64.deb
    ;;
rm ~/Downloads/google-chrome.*


#
# Installs softwares
#
sudo apt update
case $LINUX_ID in
  "Fedora")
    sudo dnf install -y \
      fzf \
      xclip \
      htop \
      vim \
      git-review \
      ShellCheck \
      ImageMagick

      ;;
  "Debian"|"Ubuntu")
    sudo apt install -y \
      curl \
      fzf \
      xclip \
      htop \
      mssh \
      vim \
      git-review \
      php-xml \
      php-ast \
      php-curl \
      php-intl \
      php-mbstring \
      mysql-client-core-8.0 \
      shellcheck \
      tree \
      imagemagick \
      npm \
      flatpak \
      baobab \
      ruby-full \
      ssh-askpass \
      sqlite3

    # Ubuntu
    #  "$(check-language-support)" \
    #  "$(check-language-support -l ja)" \
    # https://developer.android.com/studio/install#64bit-libs
    sudo apt install -y
      libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
    # sudo apt install -y \
    #   evolution-data-server
      ;;
  *)
      ;;
esac

case $LINUX_ID in
  "Debian"|"Ubuntu")
    sudo apt install -y \
      ibus-hangul \
      fonts-unfonts-core
    ;;
esac

#
# Change the background color of grub
#
case $LINUX_ID in
  "Debian")
    cat <<EOF > /boot/grub/custom.cfg 
# set color_normal=light-gray/black
# set color_highlight=white/cyan

set menu_color_normal=white/black
set menu_color_highlight=black/white
    EOF
    ;;
esac

#
# Gnome
# Uses unstable because the version of Bullseye's gnome is 38
#
case $LINUX_ID in
  "Debian")
    sudo apt -t unstable install -y \
      gnome-clocks \
      gnome-tweaks \
      gnome-colors \
      gnome-session \
      gnome-shell \
      gnome-backgrounds \
      gnome-applets \
      gnome-control-center \
      mutter \
      gjs \
      tracker-miner-fs \
      ssh-askpass-gnome
  ;;
esac

#
# gsettings
#
# gsettings set org.gnome.desktop.background picture-options 'scaled'
# gsettings set org.gnome.desktop.background primary-color '#000'
# gsettings set org.gnome.desktop.interface enable-hot-corners true
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false
# gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
# gsettings set org.gnome.desktop.screensaver picture-options 'scaled'

# No such schema:
# gsettings set org.gnome.shell.extensions.desktop-icons show-home false

#
# BITWARDEN
#
BITWARDEN_VERSION=$(curl -s https://api.github.com/repos/bitwarden/clients/releases/latest | json tag_name | cut -dv -f2)
sudo curl -L https://github.com/bitwarden/clients/releases/download/desktop-v${BITWARDEN_VERSION}/Bitwarden-${BITWARDEN_VERSION}-x86_64.AppImage \
  -o ~/.local/bin/Bitwarden.AppImage
sudo chmod +x ~/.local/bin/Bitwarden.AppImage

curl -L https://github.com/bitwarden/brand/raw/master/icons/512x512.png -o ~/.icons/bitwarden.png
touch ~/.local/share/applications/Bitwarden.desktop
desktop-file-edit \
  --set-name=Bitwarden \
  --set-key=Type --set-value=Application \
  --set-key=Terminal --set-value=false \
  --set-key=Exec --set-value=$HOME/.local/bin/Bitwarden.AppImage \
  --set-key=Icon --set-value=bitwarden \
  ~/.local/share/applications/Bitwarden.desktop

desktop-file-install ~/.local/share/applications/Bitwarden.desktop

#
# Python
#
case $LINUX_ID in
  "Fedora")
    sudo dnf install -y \
      python3-pip \
    ;;
  "Ubuntu")
    sudo apt install -y \
      python3-pip \
      python3-venv \
    ;;
esac
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip || True
pip install -U \
  flake8 \
  pytest \
  wheel \
  pre-commit
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -

#
# Golang
#
GOLANG_VERSION="$(curl -sL https://golang.org/VERSION?m=text)"
curl -L https://golang.org/dl/${GOLANG_VERSION}.linux-amd64.tar.gz \
  -o ~/Downloads/go.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf ~/Downloads/go.linux-amd64.tar.gz
rm ~/Downloads/go.linux-amd64.tar.gz
echo 'export PATH="\$PATH:/usr/local/go/bin"' >> ~/.bashrc
echo 'export PATH="\$HOME/go/bin:/usr/local/go/bin"' >> ~/.bashrc
export PATH="$HOME/go/bin:$PATH"

#
# Rust
#
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
sudo apt-get install musl-tools

#
# Ruby
#
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc

#
# Fonts
#
sudo dnf -y install naver-nanum-gothic-fonts
sudo apt-get install -y fonts-nanum*

#
# Keybase
#

case $LINUX_NODENAME in
  "fedora")
    sudo dnf install -y https://prerelease.keybase.io/keybase_amd64.rpmgoogle-chrome.deb
    ;;
  "debian")
    curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb -o ~/Downloads/keybase_amd64.deb
    sudo apt install -y ~/Downloads/keybase_amd64.deb
    rm ~/Downloads/keybase_amd64.deb
  ;;
esac

#
# yarn
#
case $LINUX_NODENAME in
  "fedora")
    # TODO
    ;;
  "debian")
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install -y yarn
    echo 'export PATH="$PATH:$HOME/.yarn/bin"' >> ~/.bashrc
      ;;
esac

# JSON (npm package)
sudo yarn global add json

# jq
sudo apt install -y jq

#
# PHP & Composer
#
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/bin --filename=composer --quiet
rm composer-setup.php

composer global require mediawiki/mediawiki-codesniffer -W

#
# Github CLI
# require JSON
#
GITHUB_CLI_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | json tag_name | cut -dv -f2)
curl -L https://github.com/cli/cli/releases/download/v${GITHUB_CLI_VERSION}/gh_${GITHUB_CLI_VERSION}_linux_amd64.deb \
  -o ~/Downloads/gh_linux_amd64.deb
sudo dpkg -i ~/Downloads/gh_linux_amd64.deb
rm ~/Downloads/gh_linux_amd64.deb

#
# Git
#
git config --global user.name "lens0021"
git config --global user.email "lorentz0021@gmail.com"
git config --global core.editor "code --wait"
git config --global --add gitreview.username "lens0021"
git config --global commit.gpgsign true
git config --global core.excludesfile ~/.gitignore
git config --global pull.rebase true
git config --global credential.credentialStore secretservice
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
echo 'default-cache-ttl 3600' >> gpg-agent.conf
cat << EOF > ~/.gitignore
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace

# Local History for Visual Studio Code
.history/
EOF

#
# Git Credential Manager Core
#
curl -sSL https://packages.microsoft.com/config/ubuntu/21.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
sudo apt-get update
sudo apt-get install -y gcmcore
git-credential-manager-core configure

#
# ETC yarn packages
#
sudo yarn global add \
  prettier \
  eslint \
  stylelint stylelint-config-standard

#
# VS Code
#
curl -L https://update.code.visualstudio.com/latest/linux-deb-x64/stable -o ~/Downloads/code_amd64.deb
sudo dpkg -i ~/Downloads/code_amd64.deb
rm ~/Downloads/code_amd64.deb

#
# Wine
# Reference: https://wiki.winehq.org/Ubuntu
#
sudo dpkg --add-architecture i386
wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -

case $LINUX_ID in
  "Fedora")
    # TODO
    ;;
  "Ubuntu")
    CODE_NAME=$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d= -f2)
    sudo add-apt-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ ${CODE_NAME} main"
    ;;
  "Debian")
    sudo wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    CODE_NAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d= -f2)
    sudo wget -nc -P /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/debian/dists/${CODE_NAME}/winehq-${CODE_NAME}.sources"
    ;;
esac

sudo apt update

sudo apt install -y --install-recommends winehq-staging

WINEPREFIX=~/.wine wine wineboot
# Change Wine system font (NanumGothic.ttf)
sed -i 's/"MS Shell Dlg"="Tahoma"/"MS Shell Dlg"="NanumGothic"/' ~/.wine/system.reg
sed -i 's/"MS Shell Dlg 2"="Tahoma"/"MS Shell Dlg 2"="NanumGothic"/' ~/.wine/system.reg

# Setup font
mkdir -p ~/.wine/drive_c/windows/Fonts/
cp /usr/share/fonts/truetype/nanum/NanumGothic.ttf ~/.wine/drive_c/windows/Fonts/

#
# KakaoTalk
#
curl -L http://app.pc.kakao.com/talk/win32/KakaoTalk_Setup.exe -o ~/Downloads/KakaoTalk_Setup.exe

#
# AWS CLI
# Reference: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
#
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ~/Downloads/awscliv2.zip
unzip ~/Downloads/awscliv2.zip -d ~/Downloads
sudo ~/Downloads/aws/install
rm -rf ~/Downloads/awscliv2.zip ~/Downloads/aws/


#
# EC2 Instance Connect CLI
# Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html#ec2-instance-connect-install
#
pip3 install ec2instanceconnectcli

#
# Docker
# Require json
#
curl -fsSL https://get.docker.com | sh -
# https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
sudo groupadd docker || True
sudo usermod -aG docker "$USER"
newgrp docker
# Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | json tag_name | sed -e s/v//)
sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Docker buildx
# Reference: https://medium.com/@artur.klauser/building-multi-architecture-docker-images-with-buildx-27d80f7e2408
mkdir -p "$HOME/.docker/cli-plugins"
DOCKER_BUILDX_VERSION=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | json tag_name)
sudo curl -L "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-$(dpkg --print-architecture)" \
  -o "$HOME/.docker/cli-plugins/docker-buildx"
sudo chmod +x "$HOME/.docker/cli-plugins/docker-buildx"
sudo apt-get install -y \
  binfmt-support \
  qemu-user-static
sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx install

#
# Terraform
# Require json
#
TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | json current_version)
curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    -Lo "$HOME/Downloads/terraform_linux_amd64.zip"
unzip "$HOME/Downloads/terraform_linux_amd64.zip" -d ~/Downloads
sudo mv ~/Downloads/terraform /usr/local/bin/terraform
rm "$HOME/Downloads/terraform_linux_amd64.zip"
terraform -install-autocomplete

#
# Nomad
# Require json
#
NOMAD_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | json current_version)
curl "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" \
    -Lo "$HOME/Downloads/nomad_linux_amd64.zip"
unzip "$HOME/Downloads/nomad_linux_amd64.zip" -d ~/Downloads
sudo mv ~/Downloads/nomad /usr/local/bin/nomad
rm "$HOME/Downloads/nomad_linux_amd64.zip"
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad

#
# Consul
# Require json
#
# CONSUL_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | json current_version)
# curl "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    -Lo "$HOME/Downloads/consul_linux_amd64.zip"
# unzip "$HOME/Downloads/consul_linux_amd64.zip" -d ~/Downloads
# sudo mv ~/Downloads/consul /usr/local/bin/consul
# rm "$HOME/Downloads/consul_linux_amd64.zip"
# consul -autocomplete-install
# complete -C /usr/bin/consul consul

#
# Steam
#
sudo apt install -y libgl1-mesa-dri:i386 libgl1:i386 steam
# curl "https://steamcdn-a.akamaihd.net/client/installer/steam.deb" -Lo ~/Downloads/steam.deb
# sudo apt install ~/Downloads/steam.deb
# rm ~/Downloads/steam.deb
# rm ~/Desktop/steam.desktop || True

#
# Clone Github Repositories
#
mkdir -p ~/git/lens0021 ~/git/femiwiki ~/git/gerrit

#
# Caddy
#
# XCADDY_VERSION=$(curl -s https://api.github.com/repos/caddyserver/xcaddy/releases/latest | json tag_name | cut -dv -f2)
# curl -L https://github.com/caddyserver/xcaddy/releases/download/v${XCADDY_VERSION}/xcaddy_${XCADDY_VERSION}_linux_amd64.deb \
#   -o ~/Downloads/xcaddy_linux_amd64.deb
# sudo dpkg -i ~/Downloads/xcaddy_linux_amd64.deb
# rm ~/Downloads/xcaddy_linux_amd64.deb

#
# aws-mfa
#
sudo curl -fsSL https://raw.githubusercontent.com/simnalamburt/snippets/fa7c39e01c00e7394edf22f4e9a24fe171969b9b/sh/aws-mfa -o /usr/local/bin/aws-mfa
chmod +x /usr/local/bin/
cat << EOF > ~/aws-connect
#!/bin/bash

aws-mfa

export AWS_DEFAULT_REGION=ap-northeast-1
export AWS_PROFILE=default-mfa
INSTANCE_ID=\$(aws --profile femiwiki-mfa \\
    ec2 describe-instances \\
    --filters Name=instance-state-code,Values=16 \\
    --query Reservations[*].Instances[*].[InstanceId] \\
    --output text)

mssh "\$INSTANCE_ID"
EOF
chmod +x aws-connect
sudo mv ~/aws-connect /usr/local/bin/

update-desktop-database ~/.local/share/applications

#
# Standard Notes
#

STANDARD_NOTES_VERSION=$(curl -s https://api.github.com/repos/standardnotes/app/releases/latest | json tag_name | cut -d@ -f3)
sudo curl -L https://github.com/standardnotes/app/releases/download/%40standardnotes%2Fdesktop%40${STANDARD_NOTES_VERSION}/standard-notes-${STANDARD_NOTES_VERSION}-linux-x86_64.AppImage \
  -o ~/.local/bin/standard-notes.AppImage
sudo chmod +x ~/.local/bin/standard-notes.AppImage

curl -L https://github.com/standardnotes/app/raw/main/packages/web/src/favicon/android-chrome-512x512.png -o ~/.icons/standard-notes.png
touch ~/.local/share/applications/standard-notes.desktop
desktop-file-edit \
  --set-name=Standard\ Notes \
  --set-key=Type --set-value=Application \
  --set-key=Terminal --set-value=false \
  --set-key=Exec --set-value=$HOME/.local/bin/standard-notes.AppImage \
  --set-key=Icon --set-value=standard-notes \
  ~/.local/share/applications/standard-notes.desktop
sudo desktop-file-install ~/.local/share/applications/standard-notes.desktop

#
# Android studio
#
# curl https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.0.0.16/android-studio-ide-193.6514223-linux.tar.gz -Lo ~/Downloads/android-studio-ide.tar.xz
# sudo tar -xzf ~/Downloads/android-studio-ide.tar.xz -C /usr/local
# rm ~/Downloads/android-studio-ide.tar.xz

#
# Wallpapers
#
mkdir ~/Wallpapers

#
# GIMP
#

sudo flatpak install -y https://flathub.org/repo/appstream/org.gimp.GIMP.flatpakref

################################################################################
# Removed
################################################################################

# #
# # Blender
# #
# curl https://www.blender.org/download/Blender2.82/blender-2.82a-linux64.tar.xz/ -Lo ~/Downloads/blender.tar.xz
# sudo tar -xvf blender.tar.xz -C /usr/local/blender
# rm ~/Downloads/blender.tar.xz
# mkdir -p ~/github
# git clone https://github.com/sugiany/blender_mmd_tools.git ~/github/
# cd ~/github/blender_mmd_tools && git checkout v0.4.5
# mkdir ~/.config/blender/2.82/scripts/addons
# ln -s ~/github/blender_mmd_tools/mmd_tools ~/.config/blender/2.82/scripts/addons/mmd_tools
## TODO make a .desktop file

# #
# # K3S
# #
# cat << EOF > ~/k3s-install
# #!/bin/bash
# curl -sfL https://get.k3s.io | sh -
# sudo chown -R $USER /etc/rancher/k3s
# EOF
# chmod +x k3s-install
# sudo mv ~/k3s-install /usr/local/bin/

# #
# # Howdy (Removed)
# #
# sudo add-apt-repository -y ppa:boltgolt/howdy
# sudo apt update
