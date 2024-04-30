if set -q TERMUX_VERSION
  pkg install -y \
    tur-repo \
    x11-repo \
  ;

  pkg install -y \
    fzf \
    git \
    helix \
    man \
    proot \
    proot-distro \
    pulseaudio \
    termux-api \
    termux-x11-nightly \
    tur-repo \
    wget \
    x11-repo \
  ;

  proot-distro install fedora
else
  if ! command -v git
    dnf install -y \
      git \
    ;
  end

  cd
  if ! -d provision
    git clone https://gitlab.com/lens0021/provision.git
  end
  fish -d provision/1st-step.fish
end
