#!/usr/bin/env python3
"""PreToolUse hook: keep the Claude Code attribution on gh PR/issue bodies.

When Claude runs `gh pr create`, `gh pr comment`, `gh pr review`,
`gh issue create` or `gh issue comment`, or closes/reopens a PR or issue
with a comment (`gh pr close --comment`, `gh pr reopen --comment`,
`gh issue close --comment`, `gh issue reopen --comment`) and the text is
missing the line

    🤖 Generated with [Claude Code](https://claude.com/claude-code)

this hook appends it. It handles the three forms Claude actually emits:

  * a heredoc body:  --body "$(cat <<'EOF' ... EOF)"
  * a quoted body:   --body "..."  /  -b '...'  /  --body=...
    (same for --comment/-c on close/reopen)
  * a file body:     --body-file notes.md  /  -F notes.md

The file form is stamped by splicing an append ahead of the gh call rather
than by editing the file here, because the file is usually written by a
heredoc in the same command and so does not exist yet when this hook runs.

If the attribution is already present the command is left untouched. Forms
whose body comes from commits or an interactive surface (--fill*, --web,
--editor) are left alone, as is a bare close/reopen with no comment, a
--body-file reading stdin, and a path the shell would expand. `gh pr merge
--body` is a merge commit message, not an authored comment, so it is out of
scope. If the body can't be located at all, the command is denied with a
fix-it reason so nothing ships without attribution.

Fails open (exit 0, no decision) on any error, so it never blocks work by
accident.

Registered in ~/.claude/settings.json as a PreToolUse hook (matcher "Bash"):
  "command": "python3 ~/git/lens/provision/config/claude-scripts/claude-gh-attribution.py"
"""
import json
import re
import sys

ATTR = "🤖 Generated with [Claude Code](https://claude.com/claude-code)"
MARKER = "claude.com/claude-code"  # idempotency: skip if already stamped

# gh subcommands that carry a body we want to stamp. The [^\n|;&]*? lets flags
# such as `-R owner/repo` sit between `gh` and the subcommand while staying
# inside a single command of a chain.
SUBCMD_RE = re.compile(
    r"\bgh\b[^\n|;&]*?\b(?:pr\s+(?:create|comment|review)|issue\s+(?:create|comment))\b"
)

# close/reopen only author text when --comment is given; a bare close/reopen
# has nothing to stamp.
CLOSE_SUBCMD_RE = re.compile(
    r"\bgh\b[^\n|;&]*?\b(?:pr|issue)\s+(?:close|reopen)\b"
)
COMMENT_FLAG_RE = re.compile(r"(?:^|\s)(?:--comment|-c)(?:=|\s)")

# Body-source forms we must not rewrite (body comes from commits, an editor, or
# the browser). --body-file is handled separately, below.
SKIP_RE = re.compile(
    r"(?:^|\s)(?:--fill\b|--fill-first\b|--fill-verbose\b|--web\b|--editor\b)"
)

# --body-file/-F, capturing the path with its quoting intact so it can be
# handed straight back to the shell.
BODY_FILE_RE = re.compile(
    r"(?:^|\s)(?:--body-file|-F)(?:=|\s+)("
    r"'[^']*'"  # single-quoted
    r'|"[^"]*"'  # double-quoted
    r"|[^\s;|&<>]+"  # bare
    r")"
)

# A path we cannot reason about statically: the shell would expand it, and
# guessing wrong means appending to the wrong file.
UNSAFE_PATH_RE = re.compile(r"[$`*?\[\]]")


def allow():
    """Exit without a decision, letting the tool run normally."""
    sys.exit(0)


def emit(obj):
    print(json.dumps(obj))
    sys.exit(0)


def append_heredoc(cmd):
    """Insert the attribution just before a heredoc's closing delimiter."""
    opener = re.search(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1", cmd)
    if not opener:
        return None
    delim = re.escape(opener.group(2))
    closer = re.search(r"\n[ \t]*" + delim + r"(?=\s|\)|$)", cmd[opener.end():])
    if not closer:
        return None
    at = opener.end() + closer.start()
    return cmd[:at] + "\n\n" + ATTR + cmd[at:]


def append_body_flag(cmd):
    """Insert the attribution before the closing quote of --body/--comment "...".

    ATTR contains no ", ', $, backtick or backslash, so it is safe to drop
    inside either a single- or double-quoted shell string. The leading
    (?:^|\\s) keeps `-c` from matching inside `--comment`, and requiring a
    quote right after the flag skips `gh pr review --comment -b "..."`, where
    --comment is a boolean event flag.
    """
    m = re.search(
        r"(?:^|\s)(?:--body|-b|--comment|-c)(?:=|\s+)(['\"])(.*?)\1", cmd, re.S
    )
    if not m:
        return None
    close_quote = m.end() - 1  # index of the closing quote char
    return cmd[:close_quote] + "\n\n" + ATTR + cmd[close_quote:]


def append_body_file(cmd, match):
    """Stamp the file --body-file points at, from inside the command itself.

    The file is often written by a heredoc in the same command, so it does not
    exist yet when this hook runs and cannot be edited here. Instead the append
    is spliced in ahead of the gh call, where it runs after the file exists.
    The grep keeps it idempotent for a file that is already stamped, and the
    braces keep && and || chains around it intact.
    """
    path = match.group(1)
    bare = path.strip("'\"")
    if bare == "-" or UNSAFE_PATH_RE.search(bare):
        return None

    gh = SUBCMD_RE.search(cmd) or CLOSE_SUBCMD_RE.search(cmd)
    if not gh:
        return None

    stamp = (
        "{ grep -qF '" + MARKER + "' " + path
        + " || printf '\\n\\n%s\\n' '" + ATTR + "' >> " + path + "; } && "
    )
    return cmd[:gh.start()] + stamp + cmd[gh.start():]


def main():
    data = json.loads(sys.stdin.read())
    if data.get("tool_name") != "Bash":
        allow()

    tool_input = data.get("tool_input") or {}
    cmd = tool_input.get("command")
    if not isinstance(cmd, str) or "gh" not in cmd:
        allow()
    stampable = SUBCMD_RE.search(cmd) or (
        CLOSE_SUBCMD_RE.search(cmd) and COMMENT_FLAG_RE.search(cmd)
    )
    if not stampable:
        allow()
    if MARKER in cmd:  # already stamped
        allow()
    if SKIP_RE.search(cmd):  # body from commits/web/editor
        allow()

    body_file = BODY_FILE_RE.search(cmd)
    if body_file:
        new_cmd = append_body_file(cmd, body_file)
    else:
        new_cmd = append_heredoc(cmd) or append_body_flag(cmd)
    if new_cmd and new_cmd != cmd:
        updated = dict(tool_input)
        updated["command"] = new_cmd
        emit({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "updatedInput": updated,
            }
        })

    emit({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "This gh PR/issue command is missing the Claude Code "
                "attribution and the hook couldn't locate the body or "
                "--comment text to append it to. Re-run with the body/comment "
                "ending in:\n\n" + ATTR
            ),
        }
    })


if __name__ == "__main__":
    try:
        main()
    except Exception:
        allow()  # fail open — never block work on a hook error
