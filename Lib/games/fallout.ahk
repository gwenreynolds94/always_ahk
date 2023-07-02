; fallout.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include ..\apps\appaid.ahk

class appsheet_fallout extends appaid.appsheet {

    static misc_hotkeys := Map(
        "!q", "{F1}",
        "!e", "{Escape}",
        "XButton1", "p",
        "XButton2", "{Escape}",
        "XButton1 & LButton", "{Shift Down}{LButton}{Shift Up}",
        "LAlt & RAlt", (*)=>MsgBox(WinGetProcessName(WinExist("A")))
    )

    __new() {
        this.name := "fallout"
        this.app_exe := "falloutwHR.exe"
        this.add("misc", appsheet_fallout.misc_hotkeys)
    }
}

appaid["fallout"] := appsheet_fallout()

