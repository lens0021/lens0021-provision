#!/usr/bin/env bash
LOG="$(cd "$(dirname "$0")/.." && pwd)/translations.log"
input=$(cat)
[[ -f "$LOG" ]] || exit 0
session_id=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)
[[ -n "$session_id" ]] || exit 0
awk -F'\t' -v sid="$session_id" '$1 == sid { print "🇬🇧 " $2 }' "$LOG" | tail -n 2 | tac
