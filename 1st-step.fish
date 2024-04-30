if [ ! -d /usr/local/git ]
  mkdir -p /usr/local/git
  chown $USER:(id -g) git
  cd git
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
