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
echo "Done. Note: the 'claude' launcher expects 'proot-distro install alpine'"
echo "and Claude installed inside Alpine at /root/.local/bin/claude."
