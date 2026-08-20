#!/usr/bin/env python3
"""PreToolUse hook: keep Linear issue IDs out of GitHub PR bodies.

When Claude runs `gh pr create` or `gh pr edit` and the PR body contains a
Linear issue ID (`INF-123`, case-insensitive), the command is denied. The
branch name is already `inf-NNN/...`, so Linear links the PR to the issue by
itself; a second copy in the body is redundant, and readers outside the
`portone-infra` workspace cannot open it anyway.

Only the body is inspected, never the title, the branch name or a commit
message. The body is located in the three forms Claude actually emits:

  * a quoted body:   --body "..."  /  -b '...'  /  --body=...
  * a heredoc body:  --body "$(cat <<'EOF' ... EOF)"  /  --body-file - <<'EOF'
                     (also the `cat > file <<'EOF'` that writes a body file
                     inside the same command)
  * a file body:     --body-file notes.md  /  -F notes.md  (the file is read)

Flag values are only collected from the `gh pr create|edit` call onward, so
`git checkout -b inf-781/foo && gh pr create ...` and a `--head inf-780/x`
argument stay untouched. Heredocs are scanned across the whole command,
because the heredoc that writes a `--body-file` target sits ahead of the gh
call, but a heredoc feeding `git commit`/`tag`/`notes` is skipped so commit
messages stay out of scope.

Fails open (exit 0, no decision) on any error, so it never blocks work by
accident.

Registered in ~/.claude/settings.json as a PreToolUse hook (matcher "Bash"):
  "command": "python3 ~/git/lens/provision/config/claude-scripts/claude-pr-body-linear-id.py"
"""
import json
import os
import re
import sys

LINEAR_ID_RE = re.compile(r"\bINF-\d+", re.I)

# The gh calls that author a PR body. [^\n|;&]*? lets flags such as
# `-R owner/repo` sit between `gh` and the subcommand while staying inside a
# single command of a chain.
SUBCMD_RE = re.compile(r"\bgh\b[^\n|;&]*?\bpr\s+(?:create|edit)\b")

# --body/-b, capturing the value with its quoting intact.
BODY_FLAG_RE = re.compile(
    r"(?:^|\s)(?:--body|-b)(?:=|\s+)("
    r"'[^']*'"  # single-quoted
    r'|"[^"]*"'  # double-quoted
    r"|[^\s;|&<>]+"  # bare
    r")"
)

# --body-file/-F, same capture.
BODY_FILE_RE = re.compile(
    r"(?:^|\s)(?:--body-file|-F)(?:=|\s+)("
    r"'[^']*'"
    r'|"[^"]*"'
    r"|[^\s;|&<>]+"
    r")"
)

HEREDOC_RE = re.compile(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1")

# A heredoc feeding one of these is a commit message, not a PR body.
COMMIT_SINK_RE = re.compile(r"\bgit\b[^\n|;&]*?\b(?:commit|tag|notes|merge)\b")

# A path the shell would expand: reading it here would guess at the wrong file.
UNSAFE_PATH_RE = re.compile(r"[$`*?\[\]]")

MAX_FILE_BYTES = 1 << 20


def allow():
    """Exit without a decision, letting the tool run normally."""
    sys.exit(0)


def heredoc_bodies(cmd):
    """Yield the text of every heredoc in the command, minus commit messages."""
    for opener in HEREDOC_RE.finditer(cmd):
        line_start = cmd.rfind("\n", 0, opener.start()) + 1
        if COMMIT_SINK_RE.search(cmd[line_start:opener.start()]):
            continue
        delim = re.escape(opener.group(2))
        closer = re.search(r"\n[ \t]*" + delim + r"(?=\s|\)|$)", cmd[opener.end():])
        if not closer:
            continue
        body_start = cmd.find("\n", opener.end())
        if body_start == -1:
            continue
        yield cmd[body_start:opener.end() + closer.start()]


def file_bodies(region):
    """Yield the contents of every --body-file the gh call reads."""
    for m in BODY_FILE_RE.finditer(region):
        path = m.group(1).strip("'\"")
        if path == "-" or UNSAFE_PATH_RE.search(path):
            continue
        path = os.path.expanduser(path)
        if not os.path.isfile(path):
            continue
        try:
            with open(path, encoding="utf-8", errors="replace") as fh:
                yield path, fh.read(MAX_FILE_BYTES)
        except OSError:
            continue


def main():
    data = json.loads(sys.stdin.read())
    if data.get("tool_name") != "Bash":
        allow()

    cmd = (data.get("tool_input") or {}).get("command")
    if not isinstance(cmd, str) or "gh" not in cmd:
        allow()

    gh = SUBCMD_RE.search(cmd)
    if not gh:
        allow()

    region = cmd[gh.start():]
    sources = []
    for m in BODY_FLAG_RE.finditer(region):
        sources.append(("--body", m.group(1).strip("'\"")))
    for path, text in file_bodies(region):
        sources.append(("--body-file " + path, text))
    for text in heredoc_bodies(cmd):
        sources.append(("heredoc body", text))

    for where, text in sources:
        found = LINEAR_ID_RE.search(text or "")
        if found:
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": (
                        "The PR body carries the Linear issue ID "
                        + found.group(0) + " (in " + where + "). Remove it and "
                        "re-run. The branch is already named inf-NNN/..., so "
                        "Linear links the PR to the issue on its own, and "
                        "readers outside the portone-infra workspace cannot "
                        "open the ID anyway. Open the body with the summary "
                        "instead, and describe any follow-up work in prose "
                        "without an ID."
                    ),
                }
            }))
            sys.exit(0)

    allow()


if __name__ == "__main__":
    try:
        main()
    except Exception:
        allow()  # fail open — never block work on a hook error
