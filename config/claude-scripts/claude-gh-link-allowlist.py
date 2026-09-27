#!/usr/bin/env python3
"""PreToolUse hook: keep gh posts from referencing other owners' issues and users.

A GitHub issue, pull request or comment that names another repository's issue
or pull request (`owner/repo#N`, or its URL) puts a "mentioned this" event on
that issue's timeline, and editing the text later does not take it back; an
`@login` notifies that user. This hook denies a gh call that would post such a
reference unless its owner is on the allow-list below.

Checked: `gh issue|pr create|edit|comment|review`, `gh issue|pr close|reopen
--comment`, and `gh api` calls that send a `body` field or an `--input` file.
The text looked at is the command itself plus any body file it names that
already exists. Code spans and fenced code blocks are skipped, since GitHub
does not autolink inside them: writing `owner/repo#N` in backticks is the way
to name an upstream thread without the backlink.

A post to a repository the API reports as private is let through, because a
private repository's references are not shown to anyone outside it.

Fails open (exit 0, no decision) on any error.

Registered in ~/.claude/settings.json as a PreToolUse hook (matcher "Bash"):
  "command": "python3 ~/git/lens/provision/config/claude-scripts/claude-gh-link-allowlist.py"
"""
import json
import os
import re
import subprocess
import sys

ALLOWED_OWNERS = {"femiwiki", "lens0021", "chaotic-ground"}

POST_RE = re.compile(
    r"\bgh\b[^\n|;&]*?\b(?:"
    r"(?:issue|pr)\s+(?:create|edit|comment|review)"
    r"|(?:issue|pr)\s+(?:close|reopen)\b[^\n|;&]*?(?:--comment|-c)[=\s]"
    r"|api\b[^\n|;&]*?(?:\bbody=|--input\b)"
    r")"
)

# Where a body can come from a file: gh's --body-file/-F, gh api's
# -F body=@file and --input file.
FILE_RES = [
    re.compile(r"(?:^|\s)(?:--body-file|-F)(?:=|\s+)(['\"]?)([^\s'\"@=]+)\1"),
    re.compile(r"(?:^|\s)(?:-F|--field)\s+body=@(['\"]?)([^\s'\"]+)\1"),
    re.compile(r"(?:^|\s)--input(?:=|\s+)(['\"]?)([^\s'\"]+)\1"),
]

REPO_FLAG_RE = re.compile(r"(?:^|\s)(?:-R|--repo)(?:=|\s+)(['\"]?)([\w.-]+/[\w.-]+)\1")
API_PATH_RE = re.compile(r"\brepos/([\w.-]+/[\w.-]+)/")

OWNER = r"[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?"
REF_RES = [
    # https://github.com/owner/repo/issues/12, /pull/12, /discussions/12
    re.compile(r"github\.com/(" + OWNER + r")/[\w.-]+/(?:issues|pull|discussions)/\d+", re.I),
    # owner/repo#12
    re.compile(r"(?<![\w/.-])(" + OWNER + r")/[\w.-]+#\d+"),
    # @login, @org/team
    re.compile(r"(?<![\w`/.@=-])@(" + OWNER + r")(?![\w-])"),
]


def strip_code(text):
    text = text.replace("\\`", "`")
    text = re.sub(r"```.*?```", " ", text, flags=re.S)
    text = re.sub(r"~~~.*?~~~", " ", text, flags=re.S)
    return re.sub(r"`[^`\n]*`", " ", text)


def body_files(cmd, cwd):
    for regex in FILE_RES:
        for m in regex.finditer(cmd):
            path = os.path.expanduser(m.group(2))
            if path == "-" or "$" in path:
                continue
            if not os.path.isabs(path):
                path = os.path.join(cwd, path)
            if os.path.isfile(path):
                with open(path, encoding="utf-8", errors="replace") as f:
                    yield f.read()


def target_repo(cmd, cwd):
    m = REPO_FLAG_RE.search(cmd) or API_PATH_RE.search(cmd)
    if m:
        return m.group(m.lastindex)
    try:
        out = subprocess.run(
            ["gh", "repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner"],
            cwd=cwd, capture_output=True, text=True, timeout=10,
        )
        return out.stdout.strip() or None
    except Exception:
        return None


def is_private(repo):
    try:
        out = subprocess.run(
            ["gh", "api", f"repos/{repo}", "--jq", ".private"],
            capture_output=True, text=True, timeout=10,
        )
        return out.stdout.strip() == "true"
    except Exception:
        return False


def main():
    data = json.loads(sys.stdin.read())
    if data.get("tool_name") != "Bash":
        return
    cmd = (data.get("tool_input") or {}).get("command")
    if not isinstance(cmd, str) or "gh" not in cmd or not POST_RE.search(cmd):
        return
    cwd = data.get("cwd") or os.getcwd()

    text = strip_code("\n".join([cmd, *body_files(cmd, cwd)]))
    found = []
    for regex in REF_RES:
        for m in regex.finditer(text):
            if m.group(1).lower() not in ALLOWED_OWNERS and m.group(0) not in found:
                found.append(m.group(0))
    if not found:
        return

    repo = target_repo(cmd, cwd)
    if repo and is_private(repo):
        return

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "This post references owners outside the allow-list ("
                + ", ".join(sorted(ALLOWED_OWNERS)) + "): " + ", ".join(found)
                + ". A reference to another owner's issue or pull request leaves a permanent "
                "\"mentioned this\" event on it, and an @login notifies that user. Put each one "
                "in a code span (`owner/repo#N`) or reword it, then post again."
            ),
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # fail open -- never block work on a hook error
    sys.exit(0)
