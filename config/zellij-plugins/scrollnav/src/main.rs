//! scrollnav: context-aware page scroll for zellij.
//!
//! A key bound to `MessagePlugin "scrollnav" { payload "up"|"down" }` reaches
//! this plugin. It looks up the command running in the focused pane (the same
//! way zellij-autolock does, via `list_clients`, so it sees a child process like
//! `claude` running inside a shell) and then either:
//!   - forwards the keypress to that pane when the command is a trigger (so the
//!     app, e.g. Claude Code, handles its own scrolling), or
//!   - page-scrolls the pane's scrollback via zellij otherwise.
//!
//! This keeps every other zellij binding untouched and leaves the real Locked
//! mode (Ctrl+g) a true full lock, because the keys are only bound outside it.

use std::collections::BTreeMap;
use zellij_tile::prelude::*;

#[derive(Clone, Copy)]
enum Dir {
    Up,
    Down,
}

#[derive(Default)]
struct State {
    permissions_granted: bool,
    triggers: Vec<String>,
    pending: Option<Dir>,
    print_to_log: bool,
}

register_plugin!(State);

impl ZellijPlugin for State {
    fn load(&mut self, configuration: BTreeMap<String, String>) {
        self.triggers = configuration
            .get("triggers")
            .map(|s| s.split('|').map(|x| x.trim().to_string()).collect())
            .unwrap_or_else(|| vec!["claude".to_string()]);
        self.print_to_log = configuration
            .get("print_to_log")
            .map(|s| matches!(s.trim(), "true" | "t" | "y" | "1"))
            .unwrap_or(false);

        request_permission(&[
            PermissionType::ReadApplicationState,
            PermissionType::ChangeApplicationState,
            PermissionType::WriteToStdin,
        ]);
        subscribe(&[
            EventType::PermissionRequestResult,
            EventType::ListClients,
        ]);
    }

    fn update(&mut self, event: Event) -> bool {
        match event {
            Event::PermissionRequestResult(status) => {
                self.permissions_granted = matches!(status, PermissionStatus::Granted);
                if self.permissions_granted {
                    hide_self();
                }
            }
            Event::ListClients(clients) => {
                let Some(dir) = self.pending.take() else {
                    return false;
                };
                let Some(client) = clients.iter().find(|c| c.is_current_client) else {
                    return false;
                };

                let command = client.running_command.trim();
                // Basename of the executable, e.g. "/usr/bin/claude foo" -> "claude".
                let exe = command
                    .split_whitespace()
                    .next()
                    .unwrap_or("")
                    .rsplit('/')
                    .next()
                    .unwrap_or("");
                let is_trigger = self.triggers.iter().any(|t| t == exe || t == command);

                if self.print_to_log {
                    eprintln!(
                        "[scrollnav] cmd=`{}` exe=`{}` trigger={} pane={:?}",
                        command, exe, is_trigger, client.pane_id
                    );
                }

                if is_trigger {
                    // Re-emit the keypress into the pane so the focused app scrolls
                    // itself. These are the Kitty keyboard protocol CSI-u encodings
                    // of Ctrl+Shift+F (page down) and Ctrl+Shift+B (page up):
                    // ESC [ <codepoint> ; <mods> u, mods = 1(shift)+4(ctrl)+1 = 6.
                    let bytes = match dir {
                        Dir::Down => b"\x1b[102;6u".to_vec(), // Ctrl+Shift+F
                        Dir::Up => b"\x1b[98;6u".to_vec(),    // Ctrl+Shift+B
                    };
                    write_to_pane_id(bytes, client.pane_id);
                } else {
                    match dir {
                        Dir::Down => page_scroll_down_in_pane_id(client.pane_id),
                        Dir::Up => page_scroll_up_in_pane_id(client.pane_id),
                    }
                }
            }
            _ => {}
        }
        false
    }

    fn pipe(&mut self, pipe_message: PipeMessage) -> bool {
        if let Some(payload) = pipe_message.payload {
            self.pending = match payload.trim() {
                "up" => Some(Dir::Up),
                "down" => Some(Dir::Down),
                _ => None,
            };
            if self.pending.is_some() {
                // Resolve the focused pane's running command, then act in the
                // resulting Event::ListClients so the decision is always fresh.
                list_clients();
            }
        }
        false
    }
}
