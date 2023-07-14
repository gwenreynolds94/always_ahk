; apptree.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include winwiz.ahk

class wintree {
    static pos := {x: 0, y: 0, w: 400, h: A_ScreenHeight}
          /**
           * @prop {Gui} g
           */
        ,  g := {}
        ,  o := 225
        ,  _initialized_ := false

    static init_gui() {
        g := this.g := Gui("", "always_ahk__wintree", this)
        g.show("x" this.pos.x " y" this.pos.y " w" this.pos.w " h" this.pos.h)
        winsettransparent(this.o, g)
        winwiz.dll.setwindowpos.sansextframebounds this.g.hwnd,
                this.pos.x, this.pos.y, this.pos.w, this.pos.h
        this._initialized_ := true
    }

    static show() {
        if not this._initialized_
            return this.init_gui()
        g := this.g
        g.show()
    }

    static hide() {
        g := this.g
        g.hide()
    }
}

0::ExitApp
7::Reload
9::{
    wintree.show()
}
8::{
    wintree.hide()
}
