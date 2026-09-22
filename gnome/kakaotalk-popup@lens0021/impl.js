// Put KakaoTalk's windows where the app asks for them.
//
// Wayland does not let a client position its own windows, and it does not
// let one ask where the pointer is either. KakaoTalk wants both: its tray
// menu opens at the cursor, its new-message popup in the bottom right
// corner. Under Wine it gets neither, so the menu lands in a corner of the
// screen far from the tray and reads as a right-click that does nothing.
//
// The compositor knows what the client is not allowed to. So it places them.
//
// The rules live in a JSON file, not in here, and are re-read when it
// changes. That is not tidiness: a Wayland session offers no way to make the
// shell reload an extension's code, so every edit to this file costs a
// logout, while an edit to the config costs nothing.
//
//   ~/.config/kakaotalk-popup.json
//   {
//     "log": true,
//     "rules": [
//       {"type": [9, 10], "action": "pointer"},
//       {"type": [0], "title": "", "max_width": 600, "action": "bottom-right"}
//     ]
//   }
//
// A rule matches a window owned by one of KakaoTalk's processes when every
// field it names matches: "type" against Meta.WindowType, "title" exactly,
// "max_width"/"max_height" as bounds on the frame. Actions are "pointer"
// (top left corner to the cursor), "bottom-right" (against the work area's
// corner), and "none" (match and leave alone, to keep a broader rule below
// from taking it).

import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
// Loaded by extension.js, which re-imports this file on every enable so it
// can be edited without logging out. Plain class, not an Extension subclass:
// the shell only ever sees the loader.

const TAG = '[kakaotalk-popup]';
const MARGIN = 16;
// Wine gives its own windows these, but a menu arrives with no class at all,
// so ownership is tracked by the pids these windows come from.
const OWNER_CLASSES = ['kakaotalk.exe', 'explorer.exe'];

const DEFAULT_CONFIG = {log: true, rules: []};

export default class KakaoTalkPopup {
    constructor(extension) {
        this._extension = extension;
    }

    enable() {
        this._pids = new Set();
        this._config = DEFAULT_CONFIG;
        this._configPath = GLib.build_filenamev(
            [GLib.get_user_config_dir(), 'kakaotalk-popup.json']);
        this._loadConfig();
        this._watchConfig();

        this._createdId = global.display.connect('window-created',
            (_display, window) => this._onWindowCreated(window));
        console.log(`${TAG} enabled, config=${this._configPath}`);
    }

    disable() {
        if (this._createdId) {
            global.display.disconnect(this._createdId);
            this._createdId = null;
        }
        this._monitor?.cancel();
        this._monitor = null;
        this._pids = null;
    }

    _loadConfig() {
        try {
            const [ok, bytes] = GLib.file_get_contents(this._configPath);
            if (!ok)
                throw new Error('unreadable');
            const parsed = JSON.parse(new TextDecoder().decode(bytes));
            this._config = {...DEFAULT_CONFIG, ...parsed};
            console.log(`${TAG} config loaded, ${this._config.rules.length} rules`);
        } catch (e) {
            // No config is a normal state: it means survey only.
            this._config = DEFAULT_CONFIG;
            console.log(`${TAG} config not usable (${e.message}), logging only`);
        }
    }

    _watchConfig() {
        const file = Gio.File.new_for_path(this._configPath);
        this._monitor = file.monitor(Gio.FileMonitorFlags.NONE, null);
        this._monitor.connect('changed', () => this._loadConfig());
    }

    _onWindowCreated(window) {
        // Nothing is settled at creation -- no title, no final size -- so
        // wait for the first frame before looking or moving.
        const actor = window.get_compositor_private();
        if (!actor) {
            this._handle(window);
            return;
        }
        const id = actor.connect('first-frame', () => {
            actor.disconnect(id);
            this._handle(window);
        });
    }

    _handle(window) {
        const wmClass = window.get_wm_class();
        const pid = window.get_pid();
        if (OWNER_CLASSES.includes(wmClass) && pid > 0)
            this._pids.add(pid);

        const owned = this._pids.has(pid);
        if (this._config.log)
            console.log(`${TAG} ${this._describe(window)} owned=${owned}`);
        if (!owned)
            return;

        for (const rule of this._config.rules) {
            if (!this._matches(rule, window))
                continue;
            this._apply(rule, window);
            return;
        }
    }

    _matches(rule, window) {
        const rect = window.get_frame_rect();
        if (rule.type && !rule.type.includes(window.get_window_type()))
            return false;
        if (rule.title !== undefined && window.get_title() !== rule.title)
            return false;
        if (rule.max_width && rect.width > rule.max_width)
            return false;
        if (rule.max_height && rect.height > rule.max_height)
            return false;
        return true;
    }

    _apply(rule, window) {
        const work = window.get_work_area_current_monitor();
        const rect = window.get_frame_rect();
        let x, y;

        if (rule.action === 'none') {
            return;
        } else if (rule.action === 'pointer') {
            [x, y] = global.get_pointer();
        } else if (rule.action === 'bottom-right') {
            x = work.x + work.width - rect.width - MARGIN;
            y = work.y + work.height - rect.height - MARGIN;
        } else {
            console.log(`${TAG} unknown action ${rule.action}`);
            return;
        }

        // Keep it on the monitor whatever the rule asked for.
        x = Math.max(work.x, Math.min(x, work.x + work.width - rect.width));
        y = Math.max(work.y, Math.min(y, work.y + work.height - rect.height));

        window.move_frame(false, x, y);
        console.log(`${TAG} ${rule.action} -> ${x},${y}`);
    }

    _describe(window) {
        const rect = window.get_frame_rect();
        return [
            `wm_class=${window.get_wm_class()}`,
            `pid=${window.get_pid()}`,
            `title=${JSON.stringify(window.get_title())}`,
            `type=${window.get_window_type()}`,
            `rect=${rect.x},${rect.y} ${rect.width}x${rect.height}`,
            `skip_taskbar=${window.is_skip_taskbar()}`,
            `override=${window.is_override_redirect()}`,
        ].join(' ');
    }
}
