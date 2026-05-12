---
name: install-ko-translate-hook
description: Install the Korean-to-English translation hook into the user's global Claude Code config (~/.claude/). Use when the user wants to set up — on this machine — a workflow where their Korean prompts get translated to English in the background and the last two translations are shown in the status line for English-learning purposes.
---

# Install Korean → English translation hook (global)

This skill installs a `UserPromptSubmit` hook and a status line script into `~/.claude/`. After install, every Korean prompt the user types is translated asynchronously by `claude -p --model claude-haiku-4-5`, and the latest two translations show up in the status line. Claude itself still receives the Korean original — the translation is for the user's eyes only (English study).

The canonical source files live alongside this SKILL.md:

- `settings.json` — registers the hook and status line (paths use `$HOME/.claude/...`)
- `scripts/translate-ko.sh` — Korean-detect + background translate + append to `~/.claude/translations.log`
- `scripts/statusline.sh` — prints the last 2 lines of the log, prefixed with 🇬🇧

## Steps

1. **Check dependencies.** Run `command -v jq claude` and report any missing.
2. **Inspect `~/.claude/settings.json`.**
   - If it does not exist: copy `settings.json` from this skill directory to `~/.claude/settings.json`.
   - If it exists: do NOT overwrite. Show the user the diff between the existing file and the bundled one and ask whether to merge the `statusLine` and `hooks.UserPromptSubmit` keys in (preserving any other existing config). Apply the merge only after the user confirms.
3. **Install scripts.** Create `~/.claude/scripts/` if missing, then copy `scripts/translate-ko.sh` and `scripts/statusline.sh` there. `chmod +x` both.
4. **Smoke test.** Run `echo '{"prompt":"안녕하세요","session_id":"smoketest"}' | bash ~/.claude/scripts/translate-ko.sh` and wait ~15 seconds, then `cat ~/.claude/translations.log` to confirm a `smoketest\t<English>` line appeared. If it didn't, surface the failure (probably `claude -p` auth issue or model name change).
5. **Tell the user** they need to start a fresh `claude` session for the hook to load — settings are read at session start.

## Notes

- Do not touch `~/.claude/settings.local.json` (per-machine permissions).
- `~/.claude/translations.log` and `~/.claude/.translate-pids/` are runtime files; do not create or commit them.
- Log lines are tab-separated: `<session_id>\t<translation>`. The status line filters by the current session_id (read from its own stdin JSON) so each session sees only its own prompts.
- The status line shows only the last 2 entries for the current session; the log is auto-trimmed to 100 lines total by the translate script.
- The translate script guards against re-entry (the inner `claude -p` would otherwise re-fire `UserPromptSubmit` and spawn nested translations) via `CLAUDE_KO_TRANSLATE_NESTED=1`, and caps concurrent translations via PID files in `.translate-pids/` (default `MAX_PARALLEL=2`).
- If the user later wants to update the installed copy after pulling repo changes, they can re-run this skill — step 2/3 are idempotent (with consent for settings.json).
