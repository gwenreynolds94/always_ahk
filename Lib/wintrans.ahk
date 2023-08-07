; wintrans.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#include builtins_extended.ahk
#include maths.ahk
#Include winwiz.ahk
#include wincache.ahk
#include quiktip.ahk
#Include DEBUG\jk_debug.ahk

class wintrans {
    static default_steps := [
        75, 150, 215, 235, 245, 255
    ]
    , steps := this.default_steps
    , bm := {
        set : objbindmethod(this, "step"),
        step : objbindmethod(this, "step"),
        setactive : objbindmethod(this, "setactive"),
        stepactive : objbindmethod(this, "stepactive"),
        setall : objbindmethod(this, "setall"),
        stepall : objbindmethod(this, "stepall"),
        removeactivestep : objbindmethod(this, "removeactivestep")
    }

    static newstep(_trans, *) {
        _trans := Integer(_trans).Min(255).Max(0)
        nearestindex := this.default_steps.IndexOf(_trans.Nearest(this.default_steps*))
        if !nearestindex or (_trans = this.default_steps[nearestindex])
            return
        this.default_steps.InsertAt(
            nearestindex - !(this.default_steps[nearestindex] > _trans), _trans )
    }

    static removestep(_trans, *) {
        rmindex := this.default_steps.IndexOf(_trans)
        if rmindex and this.default_steps.length > 1
            this.default_steps.RemoveAt(rmindex)
    }

    static removeactivestep(*) {
        this.removestep wincache["A"].transparency
        this.stepactive(true)
    }

    static set(_hwnd, _transparency:=255) {
        wincache[_hwnd].transparency := Integer(_transparency).min(255).max(1)
    }

    static step(_hwnd, _reverse:=false) {
        target_win := wincache[_hwnd]
        new_trans_index :=
            this.steps.IndexOf((target_win.transparency).nearest(this.steps*)) + (_reverse ? (-1) : 1)
        if new_trans_index > this.steps.length
            new_trans_index := 1
        else if new_trans_index < 1
            new_trans_index := this.steps.length
        target_win.transparency := this.steps[new_trans_index]
        quiktool this.steps[new_trans_index]
    }

    static stepactive(_reverse:=false) {
        this.step("A", _reverse)
    }

    static setactive(_transparency:=255) {
        this.set("A", _transparency)
    }

    static stepall(_reverse:=false) {
        for win_ in wincache
            this.step(win_.hwnd, _reverse)
    }

    static setall(_transparency:=255) {
        for win_ in wincache
            this.set(win_.hwnd, _transparency)
    }

    class tgui extends gui {

        static cfg := {
                    size : vector4.rect((A_ScreenWidth / 2) - 180, 120, 360, 160)
                  , mgn  : vector2(0, 0)
                  , opts : "-Caption +ToolWindow"
                }
            ,  editcfg := { size : vector4.rect(-128, -30, 690, 220)
                          , bg   : "ffdada"
                          , opts : "Number -Wrap -VScroll +Center -E0x200"
                          , font : { color : "000000"
                                   , name : "AnonymicePro Nerd Font"
                                   , pt : 164
                                   , wt : 700 }
                          , placeholder : ""  }
             /**
             * @prop {wintrans.tgui} inst
             */
            ,  inst := {}

        static __new() {
            for _vctr in [this.cfg.size, this.cfg.mgn, this.editcfg.size]
                _vctr.__numtype__ := "int"
            this.inst := this()
        }

        /**
         * @prop {Gui.Edit} editctrl
         */
        editctrl := {}
        /**
         * @prop {Gui.UpDown} updownctrl
         */
        , updownctrl := {}
        , hidden := true
        /**
        * @prop {func} bmsubmittransone
        */
        , bmsubmittransone := {}
        , bmsubmittransall := {}
        , bmsubmittrans := {}
        /**
        * @prop {func} bmshow
        */
        , bmshow        := {}
        /**
        * @prop {func} bmhide
        */
        , bmhide        := {}
        /**
        * @prop {func} bmtoggle
        */
        , bmtoggle      := {}
        , bmcancel      := {}
        , bmhotif       := {}
        , bmchincr      := {}
        , bmincrall     := {}
        , bmdecrall     := {}
        , bmtranspreview := {}
        , bmtranspreviewall := {}
        , translvlsonopen := Map()
        , updownincrement := 5
        , winsonopen := []
        , prevpreviewtrans := 255
        , prevactivewin := 0x00000
        , previewmode := "one"
        , lastpreview := 0
        , lastpreviewall := 0
        , deltacapmod := 1.1
        __new() {
            tgui := wintrans.tgui
            ecfg := tgui.editcfg
            tcfg := tgui.cfg

            super.__new( tcfg.opts,, this )

            this.MarginX := tcfg.mgn.x
            this.MarginY := tcfg.mgn.y
            this.BackColor := ecfg.bg
            this.editctrl := this.Add( "Edit", ecfg.opts
                               . " Background" ecfg.bg
                                        . " x" ecfg.size.x
                                        . " y" ecfg.size.y
                                        . " w" ecfg.size.w
                                        . " h" ecfg.size.h
                                             , ecfg.placeholder )
            this.updownctrl := this.Add( "UpDown", "Wrap Range0-255", 155)
            this.updownctrl.Visible := false
            this.editctrl.SetFont( "c" ecfg.font.color " s" ecfg.font.pt " w" ecfg.font.wt,
                                                                              ecfg.font.name )
            this.bmtranspreview := objbindmethod(this, "transpreview")
            this.bmtranspreviewall := objbindmethod(this, "transpreviewall")
            this.bmsubmittrans := objbindmethod(this, "submittrans")
            this.bmsubmittransone := objbindmethod(this, "submittransone")
            this.bmsubmittransall := objbindmethod(this, "submittransall")
            this.bmshow := objbindmethod(this, "show")
            this.bmhide := objbindmethod(this, "hide")
            this.bmtoggle := objbindmethod(this, "toggle")
            this.bmcancel := objbindmethod(this, "cancel")
            this.bmhotif := objbindmethod(this, "hotif")
            this.bmchincr := objbindmethod(this, "chincr")
            this.bmincr := objbindmethod(this, "chincr", 1, false)
            this.bmdecr := objbindmethod(this, "chincr", -1, false)
            this.bmincrall := objbindmethod(this, "chincr", 1, true)
            this.bmdecrall := objbindmethod(this, "chincr", -1, true)
            hotif this.bmhotif
            hotkey "Enter"              , this.bmsubmittrans, "On"
            hotkey "XButton1 & LButton" , this.bmsubmittrans, "On"
            hotkey "^Enter"             , this.bmsubmittransone, "On"
            hotkey "+Enter"             , this.bmsubmittransall, "On"
            hotkey "XButton2 & LButton" , this.bmsubmittransone, "On"
            hotkey "XButton2 & RButton" , this.bmsubmittransall, "On"
            hotkey "Escape"             , this.bmcancel, "On"
            hotkey "XButton1 & RButton" , this.bmcancel, "On"
            hotkey "Up"                 , this.bmincr, "On"
            hotkey "WheelUp"            , this.bmincr, "On"
            hotkey "Down"               , this.bmdecr, "On"
            hotkey "WheelDown"          , this.bmdecr, "On"
            hotkey "RButton & WheelUp"  , this.bmincrall, "On"
            hotkey "RButton & WheelDown", this.bmdecrall, "On"
            hotkey "$RButton", (*)=>(click("Right Down"))
            hotkey "$RButton Up", (*)=>(click("Right Up"))
            hotif
        }

        hotif(*)=>(!this.hidden)

        chincr(_incrmod:=1, _all:=false, *) {
            _incr := (_incrmod * this.updownincrement)
            if !!_all
                this.transpreviewall(_incr)
            else this.transpreview(_incr)
        }

        activewin => winwiz.mousewintitle["hwnd", true]

        transpreview(_incr?, *) {
            nowtick := A_TickCount
            deltatick := nowtick - this.lastpreview
            curtrans := this.updownctrl.Value
            newtrans := curtrans + (_incr ?? 0)
            awin := this.activewin
            if not awin
                return
            if awin != this.prevactivewin
                this.updownctrl.Value := (wincache[awin]).transparency,
                this.updownctrl.Value += (_incrval ?? 0),
                newtrans := this.updownctrl.Value
            this.updownctrl.value := newtrans
            wintrans.fade.set(awin, newtrans)
            this.previewmode := "one"
            this.prevpreviewtrans := newtrans
            this.prevactivewin := awin
            this.lastpreview := nowtick
        }

        transpreviewall(_incr?, *) {
            nowtick := A_TickCount
            deltatick := nowtick - this.lastpreviewall
            curtrans := this.updownctrl.Value
            newtrans := curtrans + (_incr ?? 0)
            this.updownctrl.Value := newtrans
            wintrans.fade.setall(newtrans)
            this.previewmode := "all"
            this.prevpreviewtrans := newtrans
            this.lastpreviewall := nowtick
        }

        show(*) {
            awin := this.activewin
            tgui := wintrans.tgui
            tcfg := tgui.cfg
            this.hidden := false
            super.show( "x" tcfg.size.x " y" tcfg.size.y " w" tcfg.size.w " h" tcfg.size.h )
            WinSetAlwaysOnTop true, this
            this.winsonopen := [wincache*]
            this.winsonopen.foreach(
                (_value, _index, _this)=>(this.translvlsonopen[_value.hwnd]:=_value.transparency) )
            this.updownctrl.value := this.prevpreviewtrans := awin ? this.translvlsonopen[awin] : 255
        }

        cancel(*) {
            if this.hidden
                return
            this.hide()
            this.translvlsonopen.foreach (_hwnd, _trans, *)=>
                                         (wintrans.fade.set(_hwnd, _trans))
            this.translvlsonopen.clear
        }

        hide(*) {
            this.hidden := true
            super.hide()
        }

        toggle(*) {
            if (this.hidden)
                this.show()
            else this.cancel()
        }

        submittrans(*)=>(
            this.%("bmsubmittrans" this.previewmode)%() )

        submittransone(*) {
            this.Submit(this.hidden:=true)
            WinWaitNotActive this
            awin := this.activewin
            if not awin
                awin := this.prevactivewin
            newtrans := this.updownctrl.Value
            wintrans.newstep(newtrans)
            this.translvlsonopen.where((_hwnd, _trans, *)=>(awin != _hwnd)).foreach(
                (_hwnd, _trans, *)=>(wintrans.fade.set(_hwnd, _trans)) )
            if awin
                wintrans.set(awin, newtrans)
        }

        submittransall(*) {
            this.Submit(this.hidden:=true)
            newtrans := this.updownctrl.Value
            wintrans.newstep(newtrans)
            wintrans.fade.setall(newtrans)
        }
    }

    class fade extends anim {

        static bm := {
                set : objbindmethod(this, "step"),
                step : objbindmethod(this, "step"),
                setactive : objbindmethod(this, "setactive"),
                stepactive : objbindmethod(this, "stepactive"),
                setall : objbindmethod(this, "setall"),
                stepall : objbindmethod(this, "stepall")
            }
            , instance := this()


        static set(_hwnd, _transparency:=255) {
            win := wincache[_hwnd]
            if win
                (win.transanim)(_transparency)
; ;;            instance := this()
; ;;            instance.wintitle := _hwnd
; ;;            instance(instance, Integer(_transparency).min(255).max(1))
        }

        static step(_hwnd, _reverse:=false) {
            win := wincache[_hwnd]
            if not win
                return false
            new_trans_index := wintrans.steps.IndexOf(
                (win.transparency).nearest(wintrans.steps*)) + (_reverse ? (-1) : 1)
            if new_trans_index > wintrans.steps.length
                new_trans_index := 1
            else if new_trans_index < 1
                new_trans_index := wintrans.steps.length
            new_trans := wintrans.steps[new_trans_index]
            (win.transanim)(new_trans)
; ;;            instance := this()
; ;;            instance.wintitle := _hwnd
; ;;            instance(instance, new_trans)
        }

        static setactive(_transparency:=255) {
            this.set("A", _transparency)
        }

        static stepactive(_reverse:=false) {
            this.step("A", _reverse)
        }

        static setall(_transparency:=255) {
            for hwnd_ in winwiz.winlist
                this.set(hwnd_, _transparency)
        }

        static stepall(_reverse:=false) {
            for hwnd_ in winwiz.winlist
                this.step(hwnd_, _reverse)
        }

        duration := 60,
        fps      := 200,
        wintitle := "A",
        hwnd     := 0x0,
        win      := { },
        source_trans  := 000,
        current_trans := 000,
        target_trans  := 255,
        call_history := Map()

        loop(*) {
            super.loop()
            if this.progress
                this.win.transparency := this.current_trans
        }

        afterloop(*) {
            super.afterloop()
            this.win.transparency := this.target_trans
            quiktool integer(wintrans.steps.IndexOf(this.target_trans)) . "." . this.target_trans "..." this.win.title
        }

        foreachloop(*) {
            this.progress:=super.foreachloop()
            if this.progress {
                this.current_trans := (this.source_trans).lerp(this.target_trans, cos(2 * Math.PI) * this.progress)
                quiktool "-." integer(this.current_trans)
            }
            return this.progress
        }

        call(_this, _target_trans, *) {
            this.hwnd := winexist(this.wintitle)
            if not this.hwnd
                return false
            this.win := wincache[this.hwnd]
            this.source_trans := this.win.transparency
            this.current_trans := this.source_trans
            this.target_trans := _target_trans
            super.call()
        }
    }
}

