if ! string match --regex --quiet nemo "$(cat /etc/passwd)"
  adduser nemo
  passwd -d nemo
end

if ! -e /etc/sudeors.d
  echo 'nemo ALL=(ALL:ALL) ALL' > /etc/sudeors.d/nemo
end

if set -q TERMUX_VERSION
  # Termux X11 Desktop
  dnf install -y \
    dbus-x11 \
    gnome-shell \
    gnome-software \
    gnome-tweaks \
    nautilus \
    python-dbus \
  ;

  bash -c 'for file in $(find /usr -type f -iname "*login1*"); do rm -rf $file; done'
end

if ! command -v fisher >/dev/null
  fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
end

if [ ! -d /usr/local/git ]
  mkdir -p /usr/local/git
  chown nemo:nemo /usr/local/git
  cd /usr/local/git
  sudo mkdir \
    lens \
    fw \
    gerrit \
    port \
  ;
end

if [ ! -L "$HOME"/git ]
  ln -s /usr/local/git "$HOME"/git
end
