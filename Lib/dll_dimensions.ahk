; dll_dimensions.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

class dlldim {
    static mouse_get() {
        int_point := Buffer(8)
        DllCall "GetCursorPos", "ptr", int_point
        ret_point := {
            x: NumGet(int_point, 0, "int"),
            y: NumGet(int_point, 4, "int")
        }
        return ret_point
    }
    static mouse_set(_mouse_x?, _mouse_y?, _relative:=false) {
        existing_point := dlldim.mouse_get()
        _mouse_x := _relative ? (existing_point.x+=(_mouse_x ?? 0)) : (_mouse_x ?? existing_point.x)
        _mouse_y := _relative ? (existing_point.y+=(_mouse_y ?? 0)) : (_mouse_y ?? existing_point.y)
        DllCall "SetCursorPos"
              , "int", _mouse_x
              , "int", _mouse_y
    }
}

