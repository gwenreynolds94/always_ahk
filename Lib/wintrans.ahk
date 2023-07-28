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
        stepall : objbindmethod(this, "stepall")
    }

    static set(_hwnd, _transparency:=255) {
        wincache[_hwnd].transparency := _transparency.min(255).max(1)
    }

    static step(_hwnd, _reverse:=false) {
        target_win := wincache[_hwnd]
        new_trans_index := this.steps.IndexOf((target_win.transparency).nearest(this.steps*)) + (_reverse ? (-1) : 1)
        if new_trans_index > this.steps.length
            new_trans_index := 1
        else if new_trans_index < 1
            new_trans_index := this.steps.length
        target_win.transparency := this.steps[new_trans_index]
        quiktool this.steps[new_trans_index]
    }

    static stepactive(_reverse:=false) {
        /** 
         * @type {winwrapper}
         */
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
            instance := this()
            instance.wintitle := _hwnd
            instance(instance, _transparency.min(255).max(1))
        }

        static step(_hwnd, _reverse:=false) {
            target_win := wincache[_hwnd]
            new_trans_index := wintrans.steps.IndexOf((target_win.transparency).nearest(wintrans.steps*)) + (_reverse ? (-1) : 1)
            if new_trans_index > wintrans.steps.length
                new_trans_index := 1
            else if new_trans_index < 1
                new_trans_index := wintrans.steps.length
            new_trans := wintrans.steps[new_trans_index]
            instance := this()
            instance.wintitle := _hwnd
            instance(instance, new_trans)
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

        duration := 100,
        fps      := 120,
        wintitle := "A",
        hwnd     := 0x0,
        win      := { },
        source_trans  := 000,
        current_trans := 000,
        target_trans  := 255

        loop(*) {
            if super.loop()
                this.win.transparency := this.current_trans
        }

        afterloop(*) {
            super.afterloop()
            this.win.transparency := this.target_trans
            quiktool integer(wintrans.steps.IndexOf(this.target_trans)) . "." . this.target_trans
        }

        foreachloop(&_progress, _tickstart, _duration, *) {
            if not super.foreachloop(&_progress, _tickstart, _duration)
                return (false)
            this.current_trans := (this.source_trans).lerp(this.target_trans, cos(2 * Math.PI) * _progress)
            quiktool "-." integer(this.current_trans)
            return _progress
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

