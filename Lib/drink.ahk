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
    message := "Drink Water"
    fontfam := "UbuntuMono NFM"
    fontsize := 30
    _scale := 1
    fontcolor := "ff89a2be"
    __bgcolor__ := "dd526172"
    timerstart := 0
    interval := 60
    maxdur := 30
    lmrg := 25
    bmrg := 25
    w := 200
    h := 45
    bm := { show: objbindmethod(this, "show"), 
            hide: objbindmethod(this, "hide"), 
            notify: objbindmethod(this, "notify"),
            reenable: objbindmethod(this, "reenable"),
            updateinterval: objbindmethod(this, "updateinterval") }
    showifexpr := ((*)=>true)
    _enabled := false
    __new(_interval:=60, _scale:=1) {
        this.interval := _interval
        super.__new(,"drink.ahk",, 4, this.bgcolor)
        this.scale := _scale
        OnMessage(WM_LBUTTONDOWN, (*)=>(this.bm.hide(), settimer(this.bm.hide, 0)))
    }
    fontopts => "Center vCenter c" this.fontcolor " r4 s" this.fontsize*this.scale
    scale {
        get => this._scale
        set => ( this._scale:=value
               , this.rect.set( this.lmrg, A_ScreenHeight - this.bmrg - this.h*this.scale
                              , this.w*this.scale, this.h*this.scale ) )
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
    updateinterval(_interval, *) {
        this.interval := IsNumber(_interval) and _interval or this.interval
        if !this.enabled
            return
        currenttick := A_TickCount
        sincetimerstart := currenttick - this.timerstart
        if (this.interval * 60 * 1000) <= sincetimerstart
            this.disable(), this.enable()
        else {
            settimer(this.bm.notify, 0)
            settimer(this.bm.reenable, ((this.interval * 60 * 1000) - sincetimerstart).neg())
        }
    }
}

