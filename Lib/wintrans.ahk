; wintrans.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#include builtins_extended.ahk
#include wincache.ahk

class wintrans {
    static default_steps := [
        25, 50, 75, 125, 150, 175, 200, 225, 255
    ], steps := this.default_steps
}
