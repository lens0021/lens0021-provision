# provision

Personal reformat-survival scripts. After installing the OS on a fresh
machine, this repo restores the working environment.

## Supported targets

| OS | Entry |
|---|---|
| Termux (Android) | [`termux.bash`](termux.bash) |
| Linux (Fedora / Debian) | [`1st-step.sh`](1st-step.sh) — multi-step |
| Windows | [`windows/bootstrap.ps1`](windows/bootstrap.ps1) — single script |

Linux follows an N-step convention (`1st-step`, `2nd-step`, …); `.sh` /
`.ab` files run automatically and `.md` files describe manual steps to
perform between automated runs. Windows is a single bootstrap script —
see [`windows/README.md`](windows/README.md).

## Termux

```bash
curl https://raw.githubusercontent.com/lens0021/lens0021-provision/main/termux.bash | bash
```

## Linux

```bash
curl -fsSL https://raw.githubusercontent.com/lens0021/lens0021-provision/main/1st-step.sh | bash
# follow 2nd-step.md
curl -fsSL https://raw.githubusercontent.com/lens0021/lens0021-provision/main/3rd-step.sh | bash
# follow 4th-step.md
```

`1st-step.ab` is the [Amber](https://amber-lang.com/) source the `.sh`
is generated from.

## Windows

See [`windows/README.md`](windows/README.md). Bootstrap:

```powershell
irm https://raw.githubusercontent.com/lens0021/lens0021-provision/main/windows/bootstrap.ps1 | iex
```

## Directory layout

- `windows/` — Windows provisioning (PowerShell). Single
  `bootstrap.ps1` entry point with five sections (packages, IME /
  keyboard, cosmetic / debloat / shell rc, config hardlinks,
  host-specific drivers gated by `Win32_ComputerSystem`).
- `rc/` — shell rc files (`rc.bash`, `rc.fish`, …) sourced from
  `~/.bashrc` / `~/.config/fish/config.fish`. Contains starship +
  zoxide hooks, `bash-abbrev-alias` integration, fzf.fish-style
  Ctrl+R history / Ctrl+V file picker, and `zz` (zoxide interactive
  query) abbreviation.
- `bin/` — cross-OS scripts placed on `$PATH`.
  - `zellij-copy-command` — `copy_command` wrapper for zellij that
    dispatches to `wl-copy` / `xclip` / `Set-Clipboard` / `pbcopy`
    by `uname -s`. Works around clip.exe's CP949 mojibake of UTF-8
    Hangul on Korean Windows.
- `config/` — application configs hardlinked into runtime locations
  (helix, yazi, zellij, starship, ahk, powershell, 날개셋
  `imeconf.dat`, …). Linux and Windows share the cross-OS files.
- `public_keys/` — SSH public keys.
- `secrets/` — gitignored secret material.
- `systemd/` — Linux systemd units.
- `cache/` — one-shot download cache.
- `legacy-1st-step.{fish,sh}` — earlier iterations kept for
  reference.
