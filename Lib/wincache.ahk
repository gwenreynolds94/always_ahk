; wincache.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force



class wincache {
    static _item_cache := Map()

    static __item[_win_title?] {
        get {
        }
        set {
        }
    }
}

class winwrapper {
    _hwnd     := 0x0
    _title    := ""
    _exe      := ""
    _class    := ""
    _verified := false

    __new(_window_title:="") {
        this.title := _window_title
    }

    title {
        get => this._title
        set {
            this._title := Value
            if !this._title
                return
        }
    }
}

