#!/usr/bin/env bash
LOG="$(cd "$(dirname "$0")/.." && pwd)/translations.log"
cat >/dev/null
[[ -f "$LOG" ]] || exit 0
tail -n 2 "$LOG" | sed 's/^/🇬🇧 /'
