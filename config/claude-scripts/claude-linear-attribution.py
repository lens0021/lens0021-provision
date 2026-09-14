#!/usr/bin/env python3
"""PreToolUse hook: keep the Claude Code attribution on Linear issues/comments.

When Claude writes a Linear issue description (`save_issue`) or a comment body
(`save_comment`) on either registered server and the text is missing the line

    🤖 Generated with [Claude Code](https://claude.com/claude-code)

this hook appends it. Same contract as claude-gh-attribution.py, which does the
job for `gh` PR and issue bodies; the two cover the surfaces that carry the
attribution, alongside the commit trailer Claude Code writes itself.

The body is a plain field of tool_input, so unlike the gh case there is no
parsing to get wrong: if the field is there and unstamped, it is stamped. Calls
with nothing to stamp are left alone — an update that only moves state or
labels, a `patch` edit of content that is already stamped, a create that takes
its body from a template.

Idempotency matches on the bare URL, not the whole line, because Linear rewrites
the markdown to `[Claude Code](<https://claude.com/claude-code>)` when it saves.
Without that, every later edit would stack another copy.

Documents, projects and status updates are out of scope; they are not surfaces
this workflow writes.

Fails open (exit 0, no decision) on any error, so it never blocks work by
accident.

Registered in ~/.claude/settings.json as a PreToolUse hook, matcher:
  mcp__linear__save_issue|mcp__linear__save_comment|mcp__linear-infra__save_issue|mcp__linear-infra__save_comment
  "command": "python3 ~/git/lens/provision/config/claude-scripts/claude-linear-attribution.py"
"""
import json
import sys

ATTR = "🤖 Generated with [Claude Code](https://claude.com/claude-code)"
MARKER = "claude.com/claude-code"  # idempotency: Linear rewrites the link syntax

# tool name suffix => the tool_input field holding the authored text
FIELDS = {
    "save_issue": "description",
    "save_comment": "body",
}


def allow():
    """Exit without a decision, letting the tool run normally."""
    sys.exit(0)


def main():
    data = json.loads(sys.stdin.read())

    tool = data.get("tool_name") or ""
    field = next(
        (f for suffix, f in FIELDS.items() if tool.endswith("__" + suffix)), None
    )
    if not field:
        allow()

    tool_input = data.get("tool_input") or {}
    text = tool_input.get(field)
    if not isinstance(text, str) or not text.strip():
        allow()  # nothing authored here: state-only update, patch, or template
    if MARKER in text:
        allow()

    updated = dict(tool_input)
    updated[field] = text.rstrip() + "\n\n" + ATTR
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "updatedInput": updated,
        }
    }))
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        allow()  # fail open — never block work on a hook error
