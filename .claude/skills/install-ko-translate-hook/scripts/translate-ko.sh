#!/usr/bin/env bash
set -euo pipefail

[[ "${CLAUDE_KO_TRANSLATE_NESTED:-}" == "1" ]] && exit 0

DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$DIR/translations.log"
PIDS_DIR="$DIR/.translate-pids"
MAX_PARALLEL=2

input=$(cat)
prompt=$(jq -r '.prompt // empty' <<<"$input")
session_id=$(jq -r '.session_id // "unknown"' <<<"$input")

printf '%s' "$prompt" | grep -qP '[\x{AC00}-\x{D7A3}]' || exit 0

mkdir -p "$PIDS_DIR"
for f in "$PIDS_DIR"/*; do
  [[ -e "$f" ]] || continue
  pid=$(basename "$f")
  kill -0 "$pid" 2>/dev/null || rm -f "$f"
done
count=$(find "$PIDS_DIR" -maxdepth 1 -type f | wc -l)
(( count >= MAX_PARALLEL )) && exit 0

(
  pidfile="$PIDS_DIR/$BASHPID"
  : > "$pidfile"
  trap 'rm -f "$pidfile"' EXIT
  translation=$(
    printf '%s\n\n---\n%s\n' \
      "Translate the following Korean text to natural English. Preserve tone, nuance, and politeness level. Output ONLY the translation, no quotes or commentary." \
      "$prompt" \
    | CLAUDE_KO_TRANSLATE_NESTED=1 claude -p --model claude-haiku-4-5 --effort low 2>/dev/null \
    | tr '\n' ' ' \
    | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
  )
  [[ -n "$translation" ]] || exit 0
  printf '%s\t%s\n' "$session_id" "$translation" >> "$LOG"
  if [[ $(wc -l < "$LOG") -gt 100 ]]; then
    tail -n 100 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
  fi
) </dev/null >/dev/null 2>&1 &
disown

exit 0
