
#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include ..\apps\appaid.ahk

class appsheet_armored_core extends appaid.appsheet {
    static initial_keytables := Map(
            "MouseWheelDPad", Map(
                "WheelUp", (*)=>(Send("{Up Down}"),SetTimer((*)=>Send("{Up Up}"), -50)),
                "WheelDown", (*)=>(Send("{Down Down}"),SetTimer((*)=>Send("{Down Up}"), -50)),
                "+WheelUp", (*)=>(Send("{Right Down}"),SetTimer((*)=>Send("{Right Up}"), -50)),
                "+WheelDown", (*)=>(Send("{Left Down}"),SetTimer((*)=>Send("{Left Up}"), -50))
            )
        )

    __new() {
        super.__new("armored_core")
        this.app_exe := "duckstation-qt-x64-ReleaseLTCG.exe"
        for _keytable_name, _initial_hotkeys in appsheet_armored_core.initial_keytables
            this.add(_keytable_name, _initial_hotkeys)
    }
}

appaid["armored_core"] := appsheet_armored_core()

