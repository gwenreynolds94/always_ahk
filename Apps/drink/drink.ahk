; drink.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <gdip\jdip>
#include <consts\wmconsts>


class drink {
    static ui := drinkui()
    static disable(*) => this.ui.disable()
    static  enable(*) => this.ui.enable()
}

class drinkui extends gdipui {
    message := "Drink Water!"
    fontfam := "UbuntuMono NFM"
    fontsize := 27
    fontcolor := "ff89a2be"
    __bgcolor__ := "dd526172"
    fontopts := "Center vCenter c" this.fontcolor " r4 s" this.fontsize
    timerstart := 0
    interval := 60
    maxdur := 30
    bm := { show: objbindmethod(this, "show"), 
            hide: objbindmethod(this, "hide"), 
            notify: objbindmethod(this, "notify"),
            reenable: objbindmethod(this, "reenable") }
    showifexpr := ((*)=>true)
    _enabled := false
    __new(_interval:=60) {
        this.interval := _interval
        super.__new(,"drink.ahk",, 4, this.bgcolor)
        this.rect.set(25, A_ScreenHeight - 25 - 60, 200, 60)
        OnMessage(WM_LBUTTONDOWN, (*)=>(this.bm.hide(), settimer(this.bm.hide, 0)))
    }
    enabled => this._enabled
    enable(*) {
        if this.enabled
            return
        this.bm.notify
        settimer(this.bm.notify, this.interval * 60 * 1000)
        this.timerstart := A_TickCount
        this._enabled := true
    }
    disable(*) {
        if !this.enabled
            return
        settimer(this.bm.notify, 0)
        this._enabled := false
    }
    reenable(*)=>( this.disable(), this.enable() )
    bgcolor {
        get => this.__bgcolor__
        set => this.__bgcolor__ := this._bgcolor_ := value
    }
    show(*) {
        this.openctx
        this.drawbg
        this.drawtext(this.message, this.fontopts, this.rect.w, this.rect.h)
        this.updatelayeredwindow
        this.closectx
        super.show
        WinSetAlwaysOnTop true, this
    }
    hide(*) => super.hide()
    notify(*) {
        if !this.showifexpr()
            return
        this.show()
        settimer(this.bm.hide, this.maxdur * (-1000))
        this.timerstart := A_TickCount
    }
    updateinterval(*) {
        if !this.enabled
            return
        currenttick := A_TickCount
        sincetimerstart := currenttick - this.timerstart
        if this.interval < sincetimerstart
            this.disable(), this.enable()
        else {
            settimer(this.bm.notify, 0)
            settimer(this.bm.reenable, (this.interval - sincetimerstart).neg())
        }
    }
}

