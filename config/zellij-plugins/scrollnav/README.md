# scrollnav

A tiny zellij plugin that makes `Ctrl+Shift+F` / `Ctrl+Shift+B` context-aware:

- When the focused pane runs a **trigger command** (default: `claude`), the
  keypress is forwarded to that pane so the app scrolls itself.
- Otherwise the plugin page-scrolls the pane's scrollback via zellij.

Every other zellij binding is untouched, and `Ctrl+g` Locked mode stays a real
full lock (the scroll keys are only bound outside `locked`).

## How it fits together (`config/zellij.kdl`)

- `plugins { scrollnav location="file:~/.config/zellij/plugins/scrollnav.wasm" { triggers "claude" } }`
- `load_plugins { scrollnav }` loads it in the background on session start.
- `shared_except "scroll" "search" "locked"` binds the keys to
  `MessagePlugin "scrollnav" { payload "down"|"up" }`.
- In `scroll` / `search` modes the same keys page-scroll directly.

The built `scrollnav.wasm` is committed one level up and symlinked to
`~/.config/zellij/plugins/scrollnav.wasm` by `config/declair.json`, so a fresh
machine works without a Rust toolchain.

## Detection

Uses `list_clients()` -> `ClientInfo.running_command` (like zellij-autolock), so
it sees a child process such as `claude` running inside a shell, not just the
pane's starting command.

## Forwarded bytes

When forwarding to a trigger app it writes the Kitty keyboard protocol CSI-u
encodings of the keys: `ESC[102;6u` (Ctrl+Shift+F) and `ESC[98;6u`
(Ctrl+Shift+B). If your app expects different sequences, adjust `src/main.rs`.

## Rebuild

```sh
rustup target add wasm32-wasip1   # once
./build.sh
```

Then restart zellij. The first load prompts once for plugin permissions
(ReadApplicationState / ChangeApplicationState / WriteToStdin); approve it.
