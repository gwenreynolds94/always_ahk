; appaid.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include ..\keytable.ahk

class appaid extends Map {
           /**
            * @prop {Map} appsheets
            */
    static appsheets := Map()


    static __item[_appsheet] {
        get => ( this.appsheets[_appsheet]          )
        set => ( this.appsheets[_appsheet] := Value )
    }

    static add_app(_name) {
        this[_name] := appaid.appsheet(_name)
        return this[_name]
    }
    
    class appsheet extends keysheet {
        app_title := ""
      , app_class := ""
      ,   app_exe := ""

        app_hotif => !!this.app_title ? (*)=>WinActive(this.app_title)              :
                     !!this.app_exe   ? (*)=>WinActive("ahk_exe " this.app_exe)     :
                     !!this.app_class ? (*)=>WinActive("ahk_class " this.app_class) : false

        add(_ktbl_name, _initial_hotkeys?) {
            new_ktbl := super.add(_ktbl_name, _initial_hotkeys ?? unset)
            if !!(use_hotif:=this.app_hotif)
                new_ktbl.alt_hotif_cond := use_hotif
            new_ktbl.enabled := true
            return new_ktbl
        }
    }
}


