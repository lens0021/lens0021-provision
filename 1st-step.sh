#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

USER_HOME=$(sudo -u#1000 bash -c 'echo $HOME')

DNF_INSTALLED="$(dnf list --installed)"
dnf-install-package() {
  PACKAGE=$1

  if ! echo "$DNF_INSTALLED" | grep "$PACKAGE" >/dev/null; then
    echo "🚀 install $PACKAGE"
    sudo dnf -y install "$PACKAGE"
  else
    echo "Skip install $PACKAGE"
  fi
}

sudo -v

LINUX_NODENAME="$(uname -n)"
echo "LINUX_NODENAME: $LINUX_NODENAME"

./1st-step

#
# Installs softwares
#
case $LINUX_NODENAME in
  "fedora")
    ;;
  "debian" | "ubuntu")
    sudo apt update
    sudo apt install -y \
      mssh \
      mysql-client-core-8.0 \
      tree \
      flatpak \
      baobab \
      ruby-full \
      sqlite3 \

    # Ubuntu
    #  "$(check-language-support)" \
    #  "$(check-language-support -l ja)" \
    # sudo apt install -y \
    #   evolution-data-server
    ;;
esac

#
# Change the background color of grub
#
if [ "$LINUX_NODENAME" = "debian" ]; then
  cat <<EOF >/boot/grub/custom.cfg
# set color_normal=light-gray/black
# set color_highlight=white/cyan

set menu_color_normal=white/black
set menu_color_highlight=black/white
EOF
fi

#
# Gnome
#
case $LINUX_NODENAME in
  "fedora")
    ;;
  "debian")
    echo "🚀 Install Gnome stuff ($0:$LINENO)"
    sudo apt -t unstable install -y \
      gnome-clocks \
      gnome-colors \
      gnome-session \
      gnome-shell \
      gnome-backgrounds \
      gnome-applets \
      gnome-control-center \
      mutter \
      gjs \
      tracker-miner-fs \
      ;
    ;;
esac

#
# Python
#
# case $LINUX_NODENAME in
#   'fedora')
#     sudo dnf install -y \
#       python3-pip
#     ;;
#   'ubuntu' | 'debian')
#     sudo apt install -y \
#       python3-pip \
#       python3-venv
#     ;;
# esac
# sudo ln -s /usr/bin/python3 /usr/bin/python || true
# sudo ln -s /usr/bin/pip3 /usr/bin/pip || true
# pip install -U \
#   flake8 \
#   pytest \
#   wheel \
#   pre-commit
# curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -

#
# Ruby
# TODO: asdf
#
# echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
# echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
# echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc

#
# Keybase
#
if ! command -v keybase >/dev/null; then
  echo "🚀 Install Keybase ($0:$LINENO)"
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
else
  echo 'Skip install keybase'
fi

# shfmt
if ! command -v shfmt >/dev/null; then
  case $LINUX_NODENAME in
    "fedora")
      dnf-install-package shfmt
      ;;
    "debian")
      # TODO
      ;;
  esac
fi

#
# ETC yarn packages
#
YARN_INSTALLED=$(yarn global list)
yarn-add() {
  PACKAGE=$1

  if ! echo "$YARN_INSTALLED" | grep "$PACKAGE"; then
    echo "🚀 Install npm packages ($0:$LINENO)"
    yarn global add "$PACKAGE"
  fi
}
yarn-add prettier
yarn-add eslint
yarn-add stylelint

#
# Git
#
git config --global user.name "lens0021"
git config --global user.email "lorentz0021@gmail.com"
git config --global core.editor "code --wait"
git config --global --add gitreview.username "lens0021"

git config --global color.status always
git config --global commit.gpgsign true
git config --global credential.credentialStore secretservice
git config --global init.defaultBranch main
git config --global merge.conflictstyle diff3 true
git config --global pull.rebase true
git config --global rebase.autostash true
git config --global rerere.enabled true

git config --global alias.graph 'log --graph --all --decorate --oneline --color'

if ! grep 'GPG_TTY' "$USER_HOME/.bashrc" >/dev/null; then
  # shellcheck disable=2016
  echo 'GPG_TTY=$(tty); export GPG_TTY' >>"$USER_HOME/.bashrc"
  mkdir -p "$USER_HOME/.gnupg"
  echo 'default-cache-ttl 3600' >>"$USER_HOME/.gnupg/gpg-agent.conf"
fi

#
# Git Credential Manager Core
#
case $LINUX_NODENAME in
  "fedora")
    #TODO
    ;;
  "debian")
    echo "🚀 Install Git Credential Manager Core ($0:$LINENO)"
    curl -sSL https://packages.microsoft.com/config/ubuntu/21.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
    sudo apt-get update
    sudo apt-get install -y gcmcore
    git-credential-manager-core configure
    ;;
esac

#
# VS Code
#
if ! command -v code >/dev/null; then
  case $LINUX_NODENAME in
    "fedora")
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
      dnf check-update
      sudo dnf install -y code
      ;;
    "debian" | "ubuntu")
      curl -L https://update.code.visualstudio.com/latest/linux-deb-x64/stable -o ~/Downloads/code_amd64.deb
      sudo dpkg -i ~/Downloads/code_amd64.deb
      rm ~/Downloads/code_amd64.deb
      ;;
  esac
fi

#
# Teleport
#
# https://goteleport.com/download/
curl https://goteleport.com/static/install.sh | bash -s 13.0.0

#
# Starship
#
# sudo dnf copr enable -y atim/starship
# dnf-install-package starship

#
# Codium
#
# if ! command -v codium >/dev/null; then
#   echo "🚀 Install Codium ($0:$LINENO)"
#   case $LINUX_NODENAME in
#     "fedora")
#       # VSCodium
#       sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
#       printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
#       sudo dnf install -y codium

#   if ! echo ~/.bashrc | grep codium >/dev/null; then
#   echo 'alias code=codium' >> ~/.bashrc
#   fi

#       ;;
#     "debian" | "ubuntu")
#       # TODO
#       ;;
#   esac
# fi

#
# KakaoTalk
#
if [ ! -d "$USER_HOME/.local/share/applications/wine/Programs/카카오톡" ]; then
  if [ ! -e ~/Downloads/KakaoTalk_Setup.exe ]; then
    echo "🚀 Install KakaoTalk ($0:$LINENO)"
    curl -L http://app.pc.kakao.com/talk/win32/KakaoTalk_Setup.exe -o ~/Downloads/KakaoTalk_Setup.exe
  fi
else
  echo 'Skip install KakaoTalk'
fi

#
# AWS CLI
# Reference: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
#
if ! command -v aws >/dev/null; then
  echo "🚀 Install AWS CLI ($0:$LINENO)"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ~/Downloads/awscliv2.zip
  unzip ~/Downloads/awscliv2.zip -d ~/Downloads
  sudo ~/Downloads/aws/install
  rm -rf ~/Downloads/awscliv2.zip ~/Downloads/aws/
else
  echo 'Skip install aws'
fi

#
# EC2 Instance Connect CLI
# Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html#ec2-instance-connect-install
#
if ! python -m pip list | grep ec2instanceconnectcli >/dev/null; then
  echo "🚀 Install EC2 Instance Connect CLI ($0:$LINENO)"
  python -m pip install ec2instanceconnectcli
else
  echo 'Skip install instance connect CLI'
fi

#
# Snap
#
if ! command -v snap >/dev/null; then
  echo "🚀 Install Snap ($0:$LINENO)"
  sudo dnf install -y snapd
  sudo ln -s /var/lib/snapd/snap /snap
  while ! snap --version >/dev/null; do
    sleep 1
  done
else
  echo 'Skip install Snap'
fi

#
# Authy
#
if ! snap list | grep authy >/dev/null; then
  echo "🚀 Install Authy ($0:$LINENO)"
  sudo snap install authy
else
  echo 'Skip install Authy'
fi

#
# Terraform
#
if ! command -v terraform >/dev/null; then
  echo "🚀 Install Terraform ($0:$LINENO)"
  TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
  curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    -Lo "$HOME/Downloads/terraform_linux_amd64.zip"
  unzip "$HOME/Downloads/terraform_linux_amd64.zip" -d ~/Downloads
  sudo mv ~/Downloads/terraform /usr/local/bin/terraform
  rm "$HOME/Downloads/terraform_linux_amd64.zip"
  terraform -install-autocomplete
else
  echo 'Skip install Terraform'
fi

#
# Nomad
#
# NOMAD_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | jq -r .current_version)
# curl "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" \
#   -Lo "$HOME/Downloads/nomad_linux_amd64.zip"
# unzip "$HOME/Downloads/nomad_linux_amd64.zip" -d ~/Downloads
# sudo mv ~/Downloads/nomad /usr/local/bin/nomad
# rm "$HOME/Downloads/nomad_linux_amd64.zip"
# nomad -autocomplete-install
# complete -C /usr/local/bin/nomad nomad

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
if ! command -v steam >/dev/null; then
  echo "🚀 Install Steam ($0:$LINENO)"
  case $LINUX_NODENAME in
    "fedora")
      sudo dnf install -y \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
      sudo dnf install -y steam
      ;;
    "debian" | 'ubuntu')
      sudo apt install -y libgl1-mesa-dri:i386 libgl1:i386 steam
      ;;
  esac
else
  echo 'Skip install Steam'
fi
# curl "https://steamcdn-a.akamaihd.net/client/installer/steam.deb" -Lo ~/Downloads/steam.deb
# sudo apt install ~/Downloads/steam.deb
# rm ~/Downloads/steam.deb
# rm ~/Desktop/steam.desktop || True

#
# Discord
#
# sudo dnf install -y discord

#
# mwcli
#
if [ ! -x ~/go/src/gitlab.wikimedia.org/repos/releng/cli/bin/mw ]; then
  echo "🚀 Install mwcli ($0:$LINENO)"
  mkdir -p ~/go/src/gitlab.wikimedia.org/repos/releng
  cd ~/go/src/gitlab.wikimedia.org/repos/releng/
  if [ ! -d cli ]; then
    git clone https://gitlab.wikimedia.org/repos/releng/cli.git
  fi
  cd cli
  go install github.com/bwplotka/bingo@latest
  asdf reshim golang
  bingo get
  make build
  echo "alias mwdev='~/go/src/gitlab.wikimedia.org/repos/releng/cli/bin/mw'" >>~/.bashrc
else
  echo 'Skip install mwdev'
fi

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
if ! command -v aws-connect >/dev/null; then
  echo "🚀 Install aws-connect ($0:$LINENO)"
  sudo curl -fsSL https://raw.githubusercontent.com/simnalamburt/snippets/fa7c39e01c00e7394edf22f4e9a24fe171969b9b/sh/aws-mfa -o /usr/local/bin/aws-mfa
  cat <<EOF >~/aws-connect
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
  sudo mv ~/aws-connect /usr/local/bin/
  sudo chmod +x /usr/local/bin/aws-mfa
else
  echo 'Skip install aws-connect'
fi

update-desktop-database ~/.local/share/applications

#
# Standard Notes
#

# STANDARD_NOTES_VERSION=$(curl -s https://api.github.com/repos/standardnotes/app/releases/latest | jq -r .tag_name | cut -d@ -f3)
# sudo curl -L https://github.com/standardnotes/app/releases/download/%40standardnotes%2Fdesktop%40${STANDARD_NOTES_VERSION}/standard-notes-${STANDARD_NOTES_VERSION}-linux-x86_64.AppImage \
#   -o ~/.local/bin/standard-notes.AppImage
# sudo chmod +x ~/.local/bin/standard-notes.AppImage

# curl -L https://github.com/standardnotes/app/raw/main/packages/web/src/favicon/android-chrome-512x512.png -o ~/.icons/standard-notes.png
# touch ~/.local/share/applications/standard-notes.desktop
# desktop-file-edit \
#   --set-name=Standard\ Notes \
#   --set-key=Type --set-value=Application \
#   --set-key=Terminal --set-value=false \
#   --set-key=Exec --set-value=$HOME/.local/bin/standard-notes.AppImage \
#   --set-key=Icon --set-value=standard-notes \
#   ~/.local/share/applications/standard-notes.desktop

# sudo desktop-file-install ~/.local/share/applications/standard-notes.desktop

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
# Slack
#
# SLACK_URL=$(curl -sL https://slack.com/downloads/instructions/fedora | grep -oE 'https://downloads.slack-edge.com/releases/linux/.+/prod/x64/slack-.+\.x86_64\.rpm')
# sudo dnf install -y "$SLACK_URL"

#
# GIMP
#
# sudo flatpak install -y https://flathub.org/repo/appstream/org.gimp.GIMP.flatpakref

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

echo "🎉 Done installing"
