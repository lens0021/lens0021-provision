#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

LINUX_NODENAME="$(uname -n)"
expoch LINUX_NODENAME

# curl
# TODO: Do Ubuntu and Debian have curl?
if [ $LINUX_NODENAME != 'fedora' ]; then
  sudo apt install -y curl
fi

#
# Bitwarden
#
BITWARDEN_VERSION=$(curl -s https://api.github.com/repos/bitwarden/clients/releases/latest | jq -r .tag_name | cut -dv -f2)
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

sudo desktop-file-install ~/.local/share/applications/Bitwarden.desktop

#
# 1Password
#
case $LINUX_NODENAME in
  "fedora")
    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
    sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
    sudo dnf install -y 1password 1password-cli
    ;;
  "debian") ;;
    # TODO
esac

# Google Chrome
case $LINUX_NODENAME in
  "fedora")
    sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    ;;
  "debian")
    curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o ~/Downloads/google-chrome.deb
    sudo dpkg -i ~/Downloads/google-chrome-stable_current_amd64.deb
    rm ~/Downloads/google-chrome.deb
    ;;
esac

#
# Installs softwares
#
sudo apt update
case $LINUX_NODENAME in
  "fedora")
    # openssh → kdeconnect
    sudo dnf install -y \
      xclip \
      htop \
      vim \
      git-review \
      ShellCheck \
      ImageMagick \
      openssh \
      openfortivpn

    ;;
  "debian" | "ubuntu")
    sudo apt install -y \
      curl \
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
      sqlite3 \
      jq \
      ibus-hangul \
      openfortivpn

    # Ubuntu
    #  "$(check-language-support)" \
    #  "$(check-language-support -l ja)" \
    # sudo apt install -y \
    #   evolution-data-server
    ;;
esac

#
# fzf
#
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

#
# Change the background color of grub
#
if [ "$LINUX_NODENAME" = "debian" ]; then
  cat << EOF > /boot/grub/custom.cfg
# set color_normal=light-gray/black
# set color_highlight=white/cyan

set menu_color_normal=white/black
set menu_color_highlight=black/white
EOF
fi

#
# Gnome
# Uses unstable because the version of Bullseye's gnome is 38
#
# case $LINUX_NODENAME in
#   "debian")
#     sudo apt -t unstable install -y \
#       gnome-clocks \
#       gnome-tweaks \
#       gnome-colors \
#       gnome-session \
#       gnome-shell \
#       gnome-backgrounds \
#       gnome-applets \
#       gnome-control-center \
#       mutter \
#       gjs \
#       tracker-miner-fs \
#       ssh-askpass-gnome
#   ;;
# esac

#
# Python
#
case $LINUX_NODENAME in
  'fedora')
    sudo dnf install -y \
      python3-pip
    ;;
  'ubuntu' | 'debian')
    sudo apt install -y \
      python3-pip \
      python3-venv
    ;;
esac
sudo ln -s /usr/bin/python3 /usr/bin/python || True
sudo ln -s /usr/bin/pip3 /usr/bin/pip || True
pip install -U \
  flake8 \
  pytest \
  wheel \
  pre-commit
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -

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
case $LINUX_NODENAME in
  "fedora")
    sudo dnf -y install naver-nanum-gothic-fonts
    ;;
  "debian")
    sudo apt-get install -y fonts-nanum* fonts-unfonts-core
    ;;
esac

#
# Keybase
#
case $LINUX_NODENAME in
  "fedora")
    sudo dnf install -y https://prerelease.keybase.io/keybase_amd64.rpm
    ;;
  "debian")
    curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb -o ~/Downloads/keybase_amd64.deb
    sudo apt install -y ~/Downloads/keybase_amd64.deb
    rm ~/Downloads/keybase_amd64.deb
    ;;
esac

#
# asdf
#
ASDF_VERSION=$(curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r .tag_name)
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch "$ASDF_VERSION"
echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
. $HOME/.asdf/asdf.sh
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest

# Yarn
asdf plugin add yarn
asdf install yarn latest
asdf global yarn latest

# PHP
asdf plugin add php https://github.com/asdf-community/asdf-php.git
case $LINUX_NODENAME in
  "fedora")
    sudo dnf install -y \
      autoconf \
      gcc \
      gcc-c++ \
      gd-devel \
      libcurl-devel \
      libxml2-devel \
      re2c \
      sqlite-devel \
      oniguruma-devel \
      postgresql-devel \
      readline-devel \
      libzip-devel \
      ;
    ;;
  "ubuntu" | "debian")
    sudo apt-get install -y \
      autoconf \
      bison \
      build-essential \
      curl \
      gettext \
      git \
      libcurl4-openssl-dev \
      libedit-dev \
      libgd-dev \
      libicu-dev \
      libjpeg-dev \
      libmysqlclient-dev \
      libonig-dev \
      libpng-dev \
      libpq-dev \
      libreadline-dev \
      libsqlite3-dev \
      libssl-dev \
      libxml2-dev \
      libzip-dev \
      openssl \
      pkg-config \
      re2c \
      zlib1g-dev \
      ;
    ;;
esac
asdf install php latest
asdf global php latest

# Golang
asdf plugin add golang https://github.com/kennyp/asdf-golang.git
asdf install golang latest
asdf global golang latest

# Rust
asdf plugin add rust https://github.com/code-lever/asdf-rust.git
# TODO?

#
# ETC yarn packages
#
sudo yarn global add \
  prettier \
  @prettier/plugin-xml \
  eslint \
  stylelint stylelint-config-standard

#
# Git
#
git config --global init.defaultBranch main
git config --global user.name "lens0021"
git config --global user.email "lorentz0021@gmail.com"
git config --global core.editor "code --wait"
git config --global --add gitreview.username "lens0021"
git config --global commit.gpgsign true
git config --global pull.rebase true
git config --global rerere.enabled true
git config --global merge.conflictstyle diff3 true
git config --global credential.credentialStore secretservice
# shellcheck disable=2016
echo 'GPG_TTY=$(tty); export GPG_TTY' >> ~/.bashrc
echo 'default-cache-ttl 3600' >> gpg-agent.conf

#
# Github CLI
#
GITHUB_CLI_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | jq -r .tag_name | cut -dv -f2)
case $LINUX_NODENAME in
  "fedora")
    sudo dnf install -y https://github.com/cli/cli/releases/download/v${GITHUB_CLI_VERSION}/gh_${GITHUB_CLI_VERSION}_linux_amd64.rpm
    ;;
  "debian")
    curl -L https://github.com/cli/cli/releases/download/v${GITHUB_CLI_VERSION}/gh_${GITHUB_CLI_VERSION}_linux_amd64.deb \
      -o ~/Downloads/gh_linux_amd64.deb
    sudo dpkg -i ~/Downloads/gh_linux_amd64.deb
    rm ~/Downloads/gh_linux_amd64.deb
    ;;
esac

#
# GitLab CLI
#
GLAB_VERSION=$(curl -s https://gitlab.com/api/v4/projects/34675721/repository/tags | jq -r .[0].name)
git clone https://gitlab.com/gitlab-org/cli.git ~/git/glab --branch "$GLAB_VERSION"
cd ~/git/glab
make
sudo cp bin/glab /usr/local/bin/glab

#
# Git Credential Manager Core
#
curl -sSL https://packages.microsoft.com/config/ubuntu/21.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
sudo apt-get update
sudo apt-get install -y gcmcore
git-credential-manager-core configure

#
# VS Code
#
case $LINUX_NODENAME in
  "fedora")
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
    sudo dnf install -y code

    # VSCodium
    # sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    # printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
    # sudo dnf install -y codium
    ;;
  "debian" | "ubuntu")
    curl -L https://update.code.visualstudio.com/latest/linux-deb-x64/stable -o ~/Downloads/code_amd64.deb
    sudo dpkg -i ~/Downloads/code_amd64.deb
    rm ~/Downloads/code_amd64.deb
    ;;
esac
mkdir -p ~/code-workspaces

# BloomRPC
BLOOMRPC_VERSION=$(curl -s https://api.github.com/repos/bloomrpc/bloomrpc/releases/latest | jq -r .tag_name | cut -dv -f2)
sudo curl -L https://github.com/bloomrpc/bloomrpc/releases/download/${BLOOMRPC_VERSION}/BloomRPC-${BLOOMRPC_VERSION}.AppImage \
  -o ~/.local/bin/BloomRPC.AppImage
sudo chmod +x ~/.local/bin/BloomRPC.AppImage

curl -L https://github.com/bloomrpc/bloomrpc/raw/master/resources/logo.png -o ~/.icons/bloomrpc.png
touch ~/.local/share/applications/BloomRPC.desktop
desktop-file-edit \
  --set-name=BloomRPC \
  --set-key=Type --set-value=Application \
  --set-key=Terminal --set-value=false \
  --set-key=Exec --set-value=$HOME/.local/bin/BloomRPC.AppImage \
  --set-key=Icon --set-value=bloomrpc \
  ~/.local/share/applications/BloomRPC.desktop

sudo desktop-file-install ~/.local/share/applications/BloomRPC.desktop

#
# Wine
#
case $LINUX_NODENAME in
  "fedora")
    # https://wiki.winehq.org/Fedora
    VERSION_ID=$(rpm -E %fedora)
    sudo dnf config-manager --add-repo "https://dl.winehq.org/wine-builds/fedora/${VERSION_ID}/winehq.repo"
    ;;
  "ubuntu")
    # https://wiki.winehq.org/Ubuntu
    sudo dpkg --add-architecture i386
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
    CODE_NAME=$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d= -f2)
    sudo add-apt-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ ${CODE_NAME} main"
    ;;
  "debian")
    sudo wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    CODE_NAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d= -f2)
    sudo wget -nc -P /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/debian/dists/${CODE_NAME}/winehq-${CODE_NAME}.sources"
    ;;
esac

case $LINUX_NODENAME in
  "fedora")
    sudo dnf install -y winehq-staging
    ;;
  "debian" | 'ubuntu')
    sudo apt update
    sudo apt install -y --install-recommends winehq-staging
    ;;
esac

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
#
case $LINUX_NODENAME in
  'fedora')
    # https://docs.docker.com/engine/install/fedora/
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager \
      --add-repo \
      https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-compose-plugin
    sudo systemctl start docker

    # https://phabricator.wikimedia.org/T283484
    sudo dnf install -y docker-compose

    # DOCKER_DESKTOP_URL=$(curl -sL https://docs.docker.com/desktop/install/linux-install/ | grep -oE 'https://desktop\.docker\.com/linux/main/amd64/docker-desktop-.+-x86_64\.rpm')
    # sudo dnf install -y "$DOCKER_DESKTOP_URL"
    ;;
  'ubuntu') #TODO
    ;;

  'debian') #TODO
    ;;
esac
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo sh -c "echo 'docker compose \"\$@\"' > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

# Docker buildx
# Reference: https://medium.com/@artur.klauser/building-multi-architecture-docker-images-with-buildx-27d80f7e2408
# mkdir -p "$HOME/.docker/cli-plugins"
# DOCKER_BUILDX_VERSION=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | jq -r .tag_name)
# sudo curl -L "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-$(dpkg --print-architecture)" \
#   -o "$HOME/.docker/cli-plugins/docker-buildx"
# sudo chmod +x "$HOME/.docker/cli-plugins/docker-buildx"
# sudo apt-get install -y \
#   binfmt-support \
#   qemu-user-static
# sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
# docker buildx install

#
# Terraform
#
TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  -Lo "$HOME/Downloads/terraform_linux_amd64.zip"
unzip "$HOME/Downloads/terraform_linux_amd64.zip" -d ~/Downloads
sudo mv ~/Downloads/terraform /usr/local/bin/terraform
rm "$HOME/Downloads/terraform_linux_amd64.zip"
terraform -install-autocomplete

#
# Nomad
#
NOMAD_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | jq -r .current_version)
curl "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" \
  -Lo "$HOME/Downloads/nomad_linux_amd64.zip"
unzip "$HOME/Downloads/nomad_linux_amd64.zip" -d ~/Downloads
sudo mv ~/Downloads/nomad /usr/local/bin/nomad
rm "$HOME/Downloads/nomad_linux_amd64.zip"
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad

#
# Consul
#
# CONSUL_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq -r .current_version)
# curl "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
#   -Lo "$HOME/Downloads/consul_linux_amd64.zip"
# unzip "$HOME/Downloads/consul_linux_amd64.zip" -d ~/Downloads
# sudo mv ~/Downloads/consul /usr/local/bin/consul
# rm "$HOME/Downloads/consul_linux_amd64.zip"
# consul -autocomplete-install
# complete -C /usr/bin/consul consul

#
# Steam
#
case $LINUX_NODENAME in
  "fedora")
    sudo dnf install -y \
      https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y steam
    ;;
  "debian" | 'ubuntu')
    sudo apt install -y libgl1-mesa-dri:i386 libgl1:i386 steam
    ;;
esac
# curl "https://steamcdn-a.akamaihd.net/client/installer/steam.deb" -Lo ~/Downloads/steam.deb
# sudo apt install ~/Downloads/steam.deb
# rm ~/Downloads/steam.deb
# rm ~/Desktop/steam.desktop || True

#
# Discord
#
sudo dnf install -y discord

#
# mwcli
#
mkdir -p ~/go/src/gitlab.wikimedia.org/repos/releng
cd ~/go/src/gitlab.wikimedia.org/repos/releng/
git clone https://gitlab.wikimedia.org/repos/releng/cli.git
cd cli
go install github.com/bwplotka/bingo@latest
asdf reshim golang
bingo get
make build
echo "alias mwdev='~/go/src/gitlab.wikimedia.org/repos/releng/cli/bin/mw'" >> ~/.bashrc

#
# Clone Github Repositories
#
mkdir -p ~/git/lens0021 ~/git/femiwiki ~/git/gerrit

#
# Caddy
#
# XCADDY_VERSION=$(curl -s https://api.github.com/repos/caddyserver/xcaddy/releases/latest | jq -r .tag_name | cut -dv -f2)
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
sudo chmod +x aws-connect
sudo mv ~/aws-connect /usr/local/bin/

update-desktop-database ~/.local/share/applications

#
# Standard Notes
#

STANDARD_NOTES_VERSION=$(curl -s https://api.github.com/repos/standardnotes/app/releases/latest | jq -r .tag_name | cut -d@ -f3)
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
# https://developer.android.com/studio/install#64bit-libs
# sudo apt install -y
#   libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
# curl https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.0.0.16/android-studio-ide-193.6514223-linux.tar.gz -Lo ~/Downloads/android-studio-ide.tar.xz
# sudo tar -xzf ~/Downloads/android-studio-ide.tar.xz -C /usr/local
# rm ~/Downloads/android-studio-ide.tar.xz

#
# Wallpapers
#
mkdir ~/Wallpapers

#
# Slack
#
SLACK_URL=$(curl -sL https://slack.com/downloads/instructions/fedora | grep -oE 'https://downloads.slack-edge.com/releases/linux/.+/prod/x64/slack-.+\.x86_64\.rpm')
sudo dnf install -y "$SLACK_URL"

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

#
# Howdy (Removed)
#
case $LINUX_NODENAME in
  "fedora")
    sudo dnf copr enable -y principis/howdy
    sudo dnf --refresh install -y howdy
    ;;
  "debian")
    sudo add-apt-repository -y ppa:boltgolt/howdy
    sudo apt update
    ;;
esac
