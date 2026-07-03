#!/usr/bin/env bash
# Rebuild the scrollnav zellij plugin and refresh the committed wasm.
# Run this after editing src/main.rs. Requires: rustup target add wasm32-wasip1
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$here"

cargo build --release --target wasm32-wasip1
cp -f "target/wasm32-wasip1/release/scrollnav.wasm" "$here/../scrollnav.wasm"

echo "Built and copied to config/zellij-plugins/scrollnav.wasm"
echo "Restart zellij (e.g. 'zellij kill-all-sessions' then start fresh) to load it."
