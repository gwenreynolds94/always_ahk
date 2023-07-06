; quiktip.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

class quiktool {
    static defaults := { timeout: 2250 }
    static call(_msg, _pos?, _timeout?, *) {
        _timeout := _timeout ?? this.defaults.timeout
        _params := [_msg]
        if IsSet(_pos) and ObjHasOwnProp(_pos, "x") and ObjHasOwnProp(_pos, "y")
            _params.push(_pos.x, _pos.y)
        ToolTip(_params*)
        SetTimer (*)=>ToolTip(), (-1) * Abs(_timeout)
    }
}

class quiktray {
    static defaults := {
           timeout: 2250
      ,       icon: "tray"
      ,       mute: false
      , large_icon: false
    }

    static call(_msg?, _title?, _timeout?, _opts?, *) {
        defs     := this.defaults
        _msg     := _msg ?? ""
        _title   := _title ?? ""
        _timeout := _timeout ?? this.defaults.timeout
        _opts    := _opts ?? quiktray.opts.flags[defs.icon, defs.mute, defs.large_icon]
        TrayTip _msg, _title, _opts
        SetTimer (*)=>TrayTip(), (-1) * Abs(_timeout)
    }

    class opts {
        static hex_codes := {
            icon: Map(
                "info"    , 0x1,
                "warning" , 0x2,
                "error"   , 0x3,
                "tray"    , 0x4
            ),
            mute: 0x10,
            large_icon: 0x20
        }
        static flags[_icon:="tray", _mute:=false, _large_icon:=false] {
            get {
                retflags := 0
                retflags |= !!this.hex_codes.icon.Has(_icon) ? this.hex_codes.icon[_icon] : 0
                retflags |= !!_mute ? this.hex_codes.mute : 0
                retflags |= !!_large_icon ? this.hex_codes.large_icon : 0
                return retflags
            }
        }
    }
}

