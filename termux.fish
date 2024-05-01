if set -q TERMUX_VERSION
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
  ;

  # X11 Desktop
  pkg install -y \
    pulseaudio \
    termux-x11-nightly \
  ;

  proot-distro install fedora
  proot-distro login fedora -- /bin/bash -c 'curl https://gitlab.com/lens0021/provision/-/raw/main/termux.bash | bash'

  if [ ! -d ~/storage ]
    termux-setup-storage
  end
else
  if ! command -v git >/dev/null
    dnf install -y \
      git \
    ;
  end

  if [ ! -d /home/nemo/provision ]
    mkdir -p /home/nemo
    git clone https://gitlab.com/lens0021/provision.git /home/nemo/
  end
  fish -d provision/1st-step.fish
end
