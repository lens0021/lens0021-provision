Do not use em dashes (—). Use commas or periods instead.

When invoking Bash, avoid chaining commands with `&&`, `;`, `|`, or `2>&1` even when every segment is in the permission allow-list. The Claude Code matcher prompts on the chain itself, regardless. Split into separate Bash calls (parallel is fine). Exception: a short `cd <path> && <single-cmd>` usually passes; anything more, split.

"Agent team" means Claude Code's Agent Teams (https://code.claude.com/docs/en/agent-teams), not the Agent tool's subagent pattern. Read those docs before spawning or coordinating teammates.

Clone repositories you need for reference (upstream source, actions, charts) into `~/git`, not the scratchpad. `/tmp` is tmpfs, so a clone there sits in RAM until someone deletes it. Follow the existing layout, `~/git/<org>/<repo>` where an org directory exists (`fw`, `port`, `chaotic-ground`, ...). If the repo is already there, reuse it: `git fetch` is fine, but do not switch branches or otherwise touch that working tree. Keep the scratchpad for small, short-lived files.
