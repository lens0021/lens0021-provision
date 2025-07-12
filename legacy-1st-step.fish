set -q PROVISION_BRANCH || set PROVISION_BRANCH main

if ! string match --regex --quiet nemo "$(cat /etc/passwd)"
  adduser nemo
  passwd -d nemo
end

if [ ! -e /etc/sudoersh.d/nemo ]
  mkdir -p /etc/sudoersh.d
  echo 'nemo ALL=(ALL:ALL) ALL' > /etc/sudoersh.d/nemo
  chmod u+s /usr/bin/sudo
end

dnf install -y \
  yq \
;

if set -q ANDROID_ROOT
  # Termux X11 Desktop
  dnf install -y \
    dbus-x11 \
    python-dbus \
  ;

  bash -c 'for file in $(find /usr -type f -iname "*login1*"); do rm -rf $file; done'
end

if ! command -v fisher >/dev/null
  sudo -u nemo fish -c 'curl -L https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
end
curl -L "https://gitlab.com/lens0021/provision/-/raw/$PROVISION_BRANCH/fish_plugins" -o /home/nemo/.config/fish/fish_plugins
chsh -s (which fish) nemo
sudo -u nemo fish -c 'fisher update'

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

if [ ! -L /home/nemo/git ]
  mkdir -p /home/nemo/
  ln -s /usr/local/git /home/nemo/git
end
