set -q PROVISION_BRANCH || set PROVISION_BRANCH main

if set -q TERMUX_VERSION
  curl -L https://gitlab.com/lens0021/provision/-/raw/$PROVISION_BRANCH/config/termux.properties \
    -o ~/.termux/termux.properties
  pkg install -y \
    tur-repo \
    x11-repo \
  ;

  pkg install -y \
    file \
    fzf \
    git \
    helix \
    man \
    proot \
    proot-distro \
    termux-api \
    which \
  ;

  # X11 Desktop
  pkg install -y \
    pulseaudio \
    termux-x11-nightly \
  ;

  if [ ! -d /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/fedora ]
    proot-distro install fedora
  end
  proot-distro login fedora -- /bin/bash -c "export PROVISION_BRANCH=$PROVISION_BRANCH; curl -L https://gitlab.com/lens0021/provision/-/raw/$PROVISION_BRANCH/termux.bash | bash"
  if [ ! -e ~/.bashrc ]
    echo 'proot-distro login --user nemo fedora' > ~/.bashrc
  end

  if [ ! -d ~/storage ]
    termux-setup-storage
  end
else
  for cmd in fish git
    if ! command -v $cmd >/dev/null
      dnf install -y $cmd
    end
  end

  if [ ! -d /home/nemo/provision/.git ]
    mkdir -p /home/nemo
    git clone https://gitlab.com/lens0021/provision.git /home/nemo/provision
  end
  git -C /home/nemo/provision fetch
  git -C /home/nemo/provision checkout $PROVISION_BRANCH
  fish -d debug /home/nemo/provision/1st-step.fish
  mv /home/nemo/provision /home/nemo/git/provision
end
