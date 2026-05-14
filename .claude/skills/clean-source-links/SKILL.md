---
name: clean-source-links
description: Format reference URLs as "clean link to highlight" — Chrome text fragments for web docs, commit-hash permalinks for source code, `?plain=1#L<n>` for GitHub Markdown files, `#L<n>` for GitHub code files. Use whenever the user asks for evidence-backed writeups, "근거 링크", citations, or sources.
---

# Clean source-link style

When citing external sources, use the most precise link format possible so the reader lands on (and visually sees) the exact quoted line.

## Format rules

### Web docs (HTML pages)

Use Chrome text-fragment URLs:

```
https://example.com/page#:~:text=specific%20quoted%20phrase
```

- URL-encode spaces (`%20`), commas (`%2C`), backticks (`%60`), parentheses (`%28` / `%29`), colons (`%3A`), slashes (`%2F`). Hyphens, dots, and underscores pass through as-is.
- Quote the **exact** phrase from the source. If long, take the most distinctive substring (10–20 words is plenty).
- Test mentally: pasting into Chrome should scroll-and-highlight that line.
- If the page is heavy JS / SPA the fragment may not work, fall back to a section anchor (`#section-id`).

### GitHub source code (non-Markdown)

Use commit-SHA permalinks with line number(s):

```
https://github.com/<owner>/<repo>/blob/<commit-sha>/<path>#L42
```

- Use a specific commit SHA (40-char full, or short 7+ char). NEVER `main` or `HEAD` — branches move and the line will drift.
- Single line: `#L42`. Range: `#L42-L45`.
- Get latest commit touching a file: `git log -1 --format=%H -- <path>` (or current `HEAD` if just made the change).

### GitHub Markdown files (`.md`)

GitHub renders `.md` files by default and the rendered view ignores `#L<n>` anchors. **Append `?plain=1`** to switch to plain text view first:

```
https://github.com/<owner>/<repo>/blob/<commit-sha>/README.md?plain=1#L39
```

- Without `?plain=1`, `#L39` will be silently dropped.
- Works for any `.md`, `.markdown`, `.rst`, `.adoc` (anything GitHub renders).

### Internal repo

For repos like `portone-io/kubernetes`, `portone-io/deploy-metadata`, `lens0021/leslie-kit`, etc., same rules — always pin to commit SHA.

## Sourcing priority

When multiple options exist, prefer in this order:

1. Official upstream docs (e.g. `kubernetes.io/docs`, `docs.aws.amazon.com`)
2. Upstream source code (e.g. `github.com/kubernetes/kubernetes`)
3. Our own repo permalinks (config evidence)
4. Vendor / well-known engineering blog
5. Community (Stack Overflow, Reddit) — only if nothing better

## When you can't find a link

Mark explicitly as `[근거 보완 필요]` or `[reference needed]` with a one-line note on what kind of source was tried and what's missing. Don't fabricate URLs. Don't claim a source exists when uncertain.

## Quick reference

| Source type | Format | Example |
| --- | --- | --- |
| Web doc | `#:~:text=phrase` | `kubernetes.io/docs/...#:~:text=cordon%20the%20node` |
| GitHub code | `/blob/<sha>/path#L42` | `kubernetes/kubernetes/blob/8b65a39/.../controller_utils.go#L1085-L1089` |
| GitHub markdown | `/blob/<sha>/path?plain=1#L42` | `aws/aws-node-termination-handler/blob/64d4f57/README.md?plain=1#L39` |
| Our repo | same, pinned SHA | `portone-io/kubernetes/blob/d52cf057/addons/.../values.yaml#L13` |

## Workflow tip

When evidence-gathering at scale, prefer spawning sub-agents to find links in parallel rather than serially. Ask each sub-agent for the strongest 1–2 quotable URLs in the required format, plus a note on what each link proves. Compare results before stitching into the writeup.
