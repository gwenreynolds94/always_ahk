; leader_table.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include keytable.ahk

class leader_table extends keytable {
    key_paths := Map()
    leader := "Alt & Space"
    
    __new(_leader?, _initial_hotkeys?) {
        this.leader := _leader ?? this.leader
        super.__new(_initial_hotkeys ?? unset)
    }
}
