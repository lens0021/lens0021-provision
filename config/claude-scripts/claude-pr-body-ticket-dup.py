#!/usr/bin/env python3
"""PreToolUse hook: remind that a PR body links its ticket rather than restating it.

Fires whenever Claude authors a PR body with `gh pr create` or `gh pr edit`.
Whether a body duplicates its ticket is a judgement no regex can make, so this
never inspects the text and never blocks -- it just puts the rule in front of
Claude at the moment the body is written.

Only calls that actually set a body fire, so `gh pr edit --add-label` stays
quiet.

Fails open (exit 0, no output) on any error.

Registered in ~/.claude/settings.json as a PreToolUse hook (matcher "Bash"):
  "command": "python3 ~/git/lens/provision/config/claude-scripts/claude-pr-body-ticket-dup.py"
"""
import json
import re
import sys

# `gh ... pr create|edit`. [^\n|;&]*? lets flags such as `-R owner/repo` sit
# between `gh` and the subcommand while staying inside one command of a chain.
SUBCMD_RE = re.compile(r"\bgh\b[^\n|;&]*?\bpr\s+(?:create|edit)\b")

BODY_FLAG_RE = re.compile(r"(?:^|\s)(?:--body|--body-file|-b|-F)(?:=|\s)")

REMINDER = (
    "PR body: link the ticket, do not restate it. Background, rationale and "
    "procedure live in the ticket; keep only what is true of this PR -- what "
    "it changes, plan or test output, how to apply and verify it."
)


def main():
    data = json.loads(sys.stdin.read())
    if data.get("tool_name") != "Bash":
        return

    cmd = (data.get("tool_input") or {}).get("command")
    if not isinstance(cmd, str) or "gh" not in cmd:
        return

    gh = SUBCMD_RE.search(cmd)
    if not gh or not BODY_FLAG_RE.search(cmd[gh.start():]):
        return

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": REMINDER,
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # fail open -- never block work on a hook error
    sys.exit(0)
