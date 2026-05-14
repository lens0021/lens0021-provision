Do not use em dashes (—). Use commas or periods instead.

When invoking Bash, avoid chaining commands with `&&`, `;`, `|`, or `2>&1` even when every segment is in the permission allow-list. The Claude Code matcher prompts on the chain itself, regardless. Split into separate Bash calls (parallel is fine). Exception: a short `cd <path> && <single-cmd>` usually passes; anything more, split.
