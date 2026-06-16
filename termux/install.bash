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

# Register the nightly unattended package upgrade with Android's JobScheduler.
# --job-id overwrites any previous job with the same id, so this is idempotent.
# Period is approximate (Android batches around Doze); not a fixed clock time.
if command -v termux-job-scheduler >/dev/null 2>&1; then
  termux-job-scheduler \
    --script "$dest/nightly-pkg-up" \
    --job-id 4242 \
    --period-ms 86400000 \
    --persisted true \
    --battery-not-low true \
    && echo "scheduled nightly-pkg-up (job 4242, ~daily)"
else
  echo "termux-job-scheduler not found (install termux-api); skipped nightly-pkg-up schedule"
fi

echo
echo "Done. 'claude' is the native launcher (glibc-runner, self-bootstrapping)."
echo "'claude-proot' is the Alpine-proot fallback; it expects"
echo "'proot-distro install alpine' and Claude inside it at /root/.local/bin/claude."
