#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$DIR/translations.log"
LOCK="$DIR/translations.log.lock"

input=$(cat)
prompt=$(jq -r '.prompt // empty' <<<"$input")

[[ "$prompt" =~ [가-힣] ]] || exit 0

(
  translation=$(
    printf '%s\n\n---\n%s\n' \
      "Translate the following Korean text to natural English. Preserve tone, nuance, and politeness level. Output ONLY the translation, no quotes or commentary." \
      "$prompt" \
    | claude -p --model claude-haiku-4-5 2>/dev/null \
    | tr '\n' ' ' \
    | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
  )
  [[ -n "$translation" ]] || exit 0
  (
    flock -x 200
    printf '%s\n' "$translation" >> "$LOG"
    if [[ $(wc -l < "$LOG") -gt 100 ]]; then
      tail -n 100 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
    fi
  ) 200>"$LOCK"
) </dev/null >/dev/null 2>&1 &
disown

exit 0
