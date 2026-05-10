#Requires AutoHotkey v2.0
#SingleInstance Force

; Volume control via Ctrl+Win+Arrow.
^#Up::Send "{Volume_Up}"
^#Down::Send "{Volume_Down}"

; Launch a new instance of the Nth pinned taskbar app (GNOME-style).
; Windows native: Shift+Win+<n> → new instance, Ctrl+Win+<n> → switch
; to last active window. GNOME muscle memory uses Ctrl+Super+<n> for
; "new instance"; rebind Ctrl+Win+<n> to Shift+Win+<n> to match.
^#1::Send "+#1"
^#2::Send "+#2"
^#3::Send "+#3"
^#4::Send "+#4"
^#5::Send "+#5"
^#6::Send "+#6"
^#7::Send "+#7"
^#8::Send "+#8"
^#9::Send "+#9"
