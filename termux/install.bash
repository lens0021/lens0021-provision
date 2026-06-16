#!/data/data/com.termux/files/usr/bin/bash
# Install Termux-specific launchers into ~/.local/bin by symlinking them from
# this repo, so edits here propagate and survive a Termux reinstall.
#
# Idempotent. Run from a local checkout: `bash termux/install.bash`
# (also invoked from termux.bash during bootstrap).
set -euo pipefail
IFS=$'\n\t'

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="$HOME/.local/bin"
mkdir -p "$dest"

for src in "$here"/bin/*; do
  [ -f "$src" ] || continue
  name="$(basename "$src")"
  chmod +x "$src"
  ln -sf "$src" "$dest/$name"
  echo "linked $dest/$name -> $src"
done

echo
echo "Done. 'claude' is the native launcher (glibc-runner, self-bootstrapping)."
echo "'claude-proot' is the Alpine-proot fallback; it expects"
echo "'proot-distro install alpine' and Claude inside it at /root/.local/bin/claude."
