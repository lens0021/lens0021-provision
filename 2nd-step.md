# Manual tasks

Login to

- Google
- Microsoft

on `gnome-control-center online-accounts`.

TODO

<details>
<summary>Ubuntu</summary>

Login to

- Ubuntu SSO

also install below from the console:

```sh
snap install \
  discord \
  libreoffice \
  inkscape
```

## Bitwarden

## 1Password

## Login gh cli

```sh
gh auth login
```

## Login glab cli

TODO: Read token from bitwarden
```sh
glab auth login
```

## Login Snap store

TODO: is required?

```sh
sudo snap login lorentz0021@gmail.com
```

</details>

Please re-login.

## rclone

```bash
rclone config
```

## Steam

Steam &rarr; Settings &rarr; Downloads &rarr; STEAM LIBRARY FOLDERS &rarr; ??? &rarr; Make Default

## Keybase

```sh
run_keybase
```

turn off Settings &rarr; Advanced &rarr; "Open Keybase on startup"

## ibus-hangul and ibus-mozc

```sh
ibus-setup
#or
/usr/bin/python /usr/share/ibus/setup/main.py
```

- Input Method &rarr; Add &rarr; Korean &rarr; Hangul
- Emoji &rarr; Ctrl + Shift + e

```sh
gnome-control-center keyboard
```

Input Sources &rarr; Korean &rarr; Hangul &rarr; Preferences &rarr; Sebeolsik final, Start in Hangul mode

```
ibus-setup-hangul
```

## Wine

```
WINEPREFIX=~/.wine wine wineboot
winecfg
```

## Kakaotalk

```sh
LANG=ko_KR.UTF-8 wine ~/Downloads/KakaoTalk_Setup.exe
```

## Login

- KakaoTalk
- Steam

# Wikimedia Gerrit

_TODO_

# Configure AWS CLI

Visit https://femiwiki.signin.aws.amazon.com/console/

```sh
aws configure
```

# TODO Docker Hub

https://hub.docker.com/settings/security

```
sudo docker login -u lens0021
```

<!-- # Android studio

```sh
/usr/local/android-studio/bin/studio.sh
```

Click on Tools menu -> Create Desktop Entry. -->

# Wallpapers

Download https://drive.google.com/drive/folders/1L7jq68I14d4Mf99fQQNqKkMI-Z5i0X3I and
compress to `~/Wallpapers`

# Downloads secrets from keybase

```sh
curl https://gitlab.com/lens0021/provision/-/raw/main/secrets/ssh/id_ed25519_2019.pgp | keybase pgp decrypt -o "$HOME/.ssh/id_ed25519_2019"
sudo chmod 600 "$HOME/.ssh/id_ed25519_2019"
mkdir -p ~/secrets
curl https://gitlab.com/lens0021/provision/-/raw/main/secrets/tokens/github/lens0021/gist.pgp | keybase pgp decrypt -o ~/secrets/github-gist-token.txt
curl https://gitlab.com/lens0021/provision/-/raw/main/secrets/gpg/gpg.pgp | keybase pgp decrypt -o ~/secrets/gpg
```

## Howdy

```sh
sudo howdy add
```

# ~~Removed~~
