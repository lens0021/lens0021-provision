#Requires AutoHotkey v2.0
#SingleInstance Force

; Volume control via Ctrl+Win+Arrow.
^#Up::Send "{Volume_Up}"
^#Down::Send "{Volume_Down}"
