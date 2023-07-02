; apptree.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

class wintree {
    class defaults {
        static location := "right"
    }
    static locations := Map(
            "left", {}
        )
         /**
          * @prop {Gui} g
          */
    static  g := ""

    static init_gui() {
        g := this.g := Gui("", "always_ahk__wintree", this)
        
    }

    static show(_location?) {
        _location := _location ?? "right"
    }

    static __item[_win_title] {
        get {
        }
    }
}
