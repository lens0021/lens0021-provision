#!/usr/bin/env python3
"""PreToolUse hook: deny a Bash command that reads stdin with nothing feeding it.

The Bash tool's stdin carries nothing, so `sed -n 1,5p /dev/stdin` with no pipe
or redirect reads zero bytes and exits 0. The call looks like it ran, but the
file it was meant to read was never named. With a terminal on stdin the same
command would wait forever instead.

Denied: a command that names /dev/stdin, /dev/fd/0 or /proc/self/fd/0 and has
no pipe (`|`), heredoc (`<<`), here-string (`<<<`) or input redirect (`<`)
anywhere in it. The check is coarse on purpose: any of those characters lets the
command through, since it then most likely feeds stdin itself.

Fails open (exit 0, no decision) on any error.

Registered in ~/.claude/settings.json as a PreToolUse hook (matcher "Bash"):
  "command": "python3 ~/git/lens/provision/config/claude-scripts/claude-bash-stdin-guard.py"
"""
import json
import re
import sys

STDIN_PATH_RE = re.compile(r"/dev/stdin\b|/dev/fd/0\b|/proc/self/fd/0\b")


def main():
    data = json.loads(sys.stdin.read())
    if data.get("tool_name") != "Bash":
        return
    cmd = (data.get("tool_input") or {}).get("command")
    if not isinstance(cmd, str):
        return
    m = STDIN_PATH_RE.search(cmd)
    if not m or "|" in cmd or "<" in cmd:
        return

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                f"This command reads {m.group(0)} but nothing feeds it: the Bash tool's stdin "
                "is empty, so the command would read zero bytes and exit 0 as if it worked. "
                "Name the file you meant to read instead."
            ),
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # fail open -- never block work on a hook error
    sys.exit(0)
