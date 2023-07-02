; the_surge_2.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include ..\dll_dimensions.ahk

class appaid_TheSurge2 {
    static _enabled := false
        ,  mouse_block_duration := 200
        ,  mouse_block_distance := 100
        ,  mouse_block_start := 0
        ,  mouse_pos_direction := {x:0,y:0}
        ,  mouse_pos_start := {x:0,y:0}
        ,  mouse_pos_current := {x:0,y:0}
        ,  bound_methods := {
            /**
             * @prop {Func} mouse_block_linear
             */
            mouse_block_linear: {}
        }
        ,  remaps := Map(
            "send_in_place", Map(
                "CapsLock", "h"
            )
        )

    static __New() {
        this.bound_methods.mouse_block_linear := ObjBindMethod(this, "mouse_block_linear")
    }

    static enabled {
        get => this._enabled
        set {
            return (this._enabled := !!Value)
        }
    }

    static mouse_block_linear() {
        current_tick := A_TickCount
        ticks_passed := current_tick - this.mouse_block_start
        current_progress := ticks_passed / this.mouse_block_duration
        current_distance := (current_progress >= 1) ? (this.mouse_block_distance) :
                                   (this.mouse_block_distance * current_progress)
        OutputDebug current_distance
        current_pos := {
            x: this.mouse_pos_start.x + (this.mouse_pos_direction.x * current_distance)
          , y: this.mouse_pos_start.y + (this.mouse_pos_direction.y * current_distance)
        }
        ; dlldim.mouse_set current_pos.x, current_pos.y
        MouseMove current_pos.x, current_pos.y, 0
        if current_progress >= 1
            SetTimer(,0)
    }

    static init_mouse_block_linear() {
        this.mouse_block_start := A_TickCount
        ; this.mouse_pos_start := dlldim.mouse_get()
        MouseGetPos(&_mx, &_my)
        this.mouse_pos_start := {x: _mx, y: _my}
        this.mouse_pos_current := {
            x: this.mouse_pos_start.x
          , y: this.mouse_pos_start.y
        }
        SetTimer this.bound_methods.mouse_block_linear, 10
    }

    static mouse_up() {
        this.mouse_pos_direction := { x: 0, y: (-1) }
        this.init_mouse_block_linear()
    }

    static mouse_down() {
        this.mouse_pos_direction := { x: 0, y: 1 }
        this.init_mouse_block_linear()
    }

    static mouse_left() {
        this.mouse_pos_direction := { x: (-1), y: 0 }
        this.init_mouse_block_linear()
    }

    static mouse_right() {
        this.mouse_pos_direction := { x: 1, y: 0 }
        this.init_mouse_block_linear()
    }
}

LCtrl::MButton


0::ExitApp

