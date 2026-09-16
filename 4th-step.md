# Manual tasks

## import gpg

```sh
gpg --allow-secret-key-import --import ~/secrets/gpg
rm ~/Downloads/gpg.pub ~/secrets/gpg
```

## ssh

```sh
eval "$(ssh-agent -s)"
chmod go-rw "$HOME/.ssh/id_rsa"
chmod go-rw "$HOME/.ssh/id_ed25519_2019"
ssh-add ~/.ssh/id_ed25519_2019
```

## git clone

```sh
git clone "git@github.com:femiwiki/femiwiki.git" ~/git/fw/femiwiki
git clone "git@github.com:femiwiki/docker-mediawiki.git" ~/git/fw/mediawiki
git clone "git@github.com:femiwiki/FemiwikiSkin.git" ~/git/fw/skin
git clone "ssh://lens0021@gerrit.wikimedia.org:29418/mediawiki/skins/Vector" ~/git/wikimedia/vector
```

## Kakaotalk

`3rd-step.sh` installs and configures it; all that is left is to log in from
the app grid entry (카카오톡).
