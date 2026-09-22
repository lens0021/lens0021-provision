// Place KakaoTalk's new-message popup where the app wants it.
//
// Wayland does not let a client position its own windows -- that is the
// compositor's call -- so KakaoTalk's popup, which asks for the bottom right
// corner, lands wherever GNOME puts it. Nobody can fix this inside Wine. The
// compositor can, which is what this does.
//
// It starts in survey mode: LOG_ONLY logs what every new window looks like,
// so the popup can be told apart from the main window and the tray window.
// Turn it off once the match below is known to be right.

import Meta from 'gi://Meta';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const LOG_ONLY = true;
const TAG = '[kakaotalk-popup]';

// Margin from the working area's bottom right corner, in logical pixels.
const MARGIN = 16;

export default class KakaoTalkPopupExtension extends Extension {
    enable() {
        this._createdId = global.display.connect('window-created',
            (_display, window) => this._onWindowCreated(window));
        console.log(`${TAG} enabled, log_only=${LOG_ONLY}`);
    }

    disable() {
        if (this._createdId) {
            global.display.disconnect(this._createdId);
            this._createdId = null;
        }
    }

    _describe(window) {
        const rect = window.get_frame_rect();
        return [
            `wm_class=${window.get_wm_class()}`,
            `instance=${window.get_wm_class_instance()}`,
            `sandbox=${window.get_sandboxed_app_id()}`,
            `gtk_app=${window.get_gtk_application_id()}`,
            `title=${JSON.stringify(window.get_title())}`,
            `type=${window.get_window_type()}`,
            `rect=${rect.x},${rect.y} ${rect.width}x${rect.height}`,
        ].join(' ');
    }

    _onWindowCreated(window) {
        // The title and geometry are not settled the moment the window is
        // created, so look again once the first frame is up.
        const actor = window.get_compositor_private();
        if (!actor) {
            this._report(window);
            return;
        }
        const id = actor.connect('first-frame', () => {
            actor.disconnect(id);
            this._report(window);
        });
    }

    _report(window) {
        console.log(`${TAG} ${this._describe(window)}`);
        if (LOG_ONLY)
            return;
        if (!this._isPopup(window))
            return;
        this._placeBottomRight(window);
    }

    _isPopup(_window) {
        // Filled in once the survey says what the popup actually looks like.
        return false;
    }

    _placeBottomRight(window) {
        const work = window.get_work_area_current_monitor();
        const rect = window.get_frame_rect();
        const x = work.x + work.width - rect.width - MARGIN;
        const y = work.y + work.height - rect.height - MARGIN;
        window.move_frame(false, x, y);
        console.log(`${TAG} moved to ${x},${y}`);
    }
}
