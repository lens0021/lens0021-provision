# Manual tasks

## ssh

```sh
eval "$(ssh-agent -s)"
chmod go-rw "$HOME/.ssh/id_rsa"
chmod go-rw "$HOME/.ssh/id_ed25519"
ssh-add ~/.ssh/id_rsa
```

## git clone

```sh
git clone "git@github.com:femiwiki/femiwiki.git" ~/git/femiwiki/femiwiki
git clone "git@github.com:femiwiki/docker-mediawiki.git" ~/git/femiwiki/mediawiki
git clone "git@github.com:femiwiki/FemiwikiSkin.git" ~/git/femiwiki/skin
git clone "ssh://lens0021@gerrit.wikimedia.org:29418/mediawiki/skins/Vector" ~/git/wikimedia/vector
```
