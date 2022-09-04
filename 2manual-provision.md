# Manual tasks

Login to

- Google
- Microsoft

<details>
<summary>Ubuntu</summary>

Login to

- Ubuntu SSO

and Open Snap store to install

- Cheese

also install below from the console:

```sh
snap install \
  discord \
  libreoffice \
  inkscape
```

## Login gh cli

```sh
gh auth login
```

## Login Snap store

```sh
sudo snap login lorentz0021@gmail.com
```

</details>

Please re-login.

## Kakaotalk

```sh
LANG=ko_KR.UTF-8 wine ~/Downloads/KakaoTalk_Setup.exe
```

## Keybase

```sh
run_keybase
```

turn off Settings &rarr; Advanced &rarr; "Open Keybase on startup"

## ibus-hangul and ibus-mozc

```sh
ibus-setup
```

```sh
gnome-control-center region
```

```
ibus-setup-hangul
```

## Configure Wine

```
winecfg
```

## Login

- KakaoTalk
- Google Chrome
- Steam
- Discord

## GNOME Extensions Sync

Visit https://extensions.gnome.org/extension/1486/extensions-sync/ and install.

## YouTube Music

Go to `chrome://flags` and enable 'Desktop PWA launch handler'.
Install Webapp from https://music.youtube.com/.

# Slack
Go to https://slack.com/intl/ko-kr/downloads/instructions/ubuntu and download the installer.


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

# Android studio

```sh
/usr/local/android-studio/bin/studio.sh
```

Click on Tools menu -> Create Desktop Entry.

# VS Code extension

```sh
code --install-extension Shan.code-settings-sync
```

# Wallpapers

Download https://drive.google.com/drive/folders/1L7jq68I14d4Mf99fQQNqKkMI-Z5i0X3I and
compress to `~/Wallpapers`

# Downloads secrets from keybase

```sh
curl https://pastebin.com/raw/DFPTc9zE | keybase pgp decrypt -o "$HOME/.ssh/id_rsa"
mkdir -p ~/secrets
curl https://pastebin.com/raw/2LdAw5FN | keybase pgp decrypt -o ~/secrets/github-gist-token.txt
curl https://pastebin.com/raw/FtU2pCcm | keybase pgp decrypt -o ~/secrets/gpg
```

# GSConnect

```sh
gapplication action org.gnome.Shell.Extensions.GSConnect preferences
```

# ~~Removed~~

## ~~Howdy~~

```sh
sudo apt install -y howdy
sudo howdy add
```
