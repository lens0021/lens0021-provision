#!/usr/bin/env python3
"""PreToolUse hook: remind that a sub-issue links its parent rather than restating it.

Fires when Claude puts an issue into a tree on either registered Linear server:
a `save_issue` that sets `parentId`, or one that links `relatedTo` / `blocks` /
`blockedBy`. That is the moment the duplication gets written, whether the child
body is authored in the same call or trimmed right after the link.

Whether a body duplicates its parent is a judgement no regex can make, so this
never inspects the text and never blocks -- it just puts the rule in front of
Claude while the relation is being made. Same contract as
claude-pr-body-ticket-dup.py, which does the job for `gh pr create|edit` bodies.

Calls with no relation to make stay quiet: a plain body edit, a state or label
change, a `removeRelatedTo` cleanup. `parentId: null` (unlinking) is quiet too.

Fails open (exit 0, no output) on any error.

Registered in ~/.claude/settings.json as a PreToolUse hook, matcher:
  mcp__linear__save_issue|mcp__linear__save_comment|mcp__linear-infra__save_issue|mcp__linear-infra__save_comment
  "command": "python3 ~/git/lens/provision/config/claude-scripts/claude-linear-parent-dup.py"
"""
import json
import sys

RELATION_FIELDS = ("relatedTo", "blocks", "blockedBy")

REMINDER = (
    "Linear tree: a sub-issue links its parent, it does not restate it. "
    "Background, rationale and shared findings live in the parent; keep only "
    "what is true of this child -- its own scope, resource IDs and checklist. "
    "The parent body carries no per-child checklist or status board either: "
    "the sub-issue list already shows both, and a hand-copied one goes stale "
    "and re-creates duplicate relations from its identifier mentions."
)


def main():
    data = json.loads(sys.stdin.read())

    tool = data.get("tool_name") or ""
    if not tool.endswith("__save_issue"):
        return

    args = data.get("tool_input") or {}

    # parentId: null removes a parent, which needs no reminder.
    linking = args.get("parentId") is not None or any(
        args.get(f) for f in RELATION_FIELDS
    )
    if not linking:
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
