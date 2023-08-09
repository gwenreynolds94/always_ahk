; anim.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#include wincache.ahk
#Include builtins_extended.ahk

class anim {
        progress := 0
      , duration := 5000
      , fps      := 60
      , speed    := 30
      , accel    := 1
      , bm       := { loop : false
                    , call : false
                    , foreachloop: false
                    , afterloop : false }
      , tickinterval := 0
      , tickavgdelta := 0
      , tickcount := 0
      , tickdelta := 0
      , tickstart := 0
      , tickprev := 0
      , ticknow := 0
      , loopdur := 0
      , loopindex := 0
      , loopdelay := 0

    __new() {
      this.bm := { loop : objbindmethod(this, "loop")
                 , call : objbindmethod(this, "call")
                 , afterloop : objbindmethod(this, "afterloop")
                 , foreachloop: objbindmethod(this, "foreachloop") }
    }
    startloop(*) {
        this.tickstart := A_TickCount
        this.tickinterval := ( 1000 / this.fps )
        this.tickcount := this.duration / this.tickinterval
        settimer this.bm.loop, integer(this.tickinterval.abs())
    }
    stoploop(*) {
        settimer this.bm.loop, 0
        this.afterloop
    }
    afterloop(*) {
        this.progress := 0
    }
    loopnext(*) {
        (++this.loopindex)
        return settimer(this.bm.loop, this.tickinterval)
        loopcount := this.duration / loopdelay
        durprog := this.ticknow - this.tickstart
        lastloop := (durprog - durprog.mod(loopdelay)) / loopdelay
        nextloop := (lastloop + 1) * loopdelay
        loopdelay := (nextloop + this.tickstart) - this.ticknow
        settimer this.bm.loop, loopdelay.neg()
    }
    loop(*) {
        this.tickprev := this.ticknow
        this.ticknow := A_TickCount
        this.tickdelta := this.ticknow - this.tickprev
        this.tickavgdelta += this.tickdelta, this.tickavgdelta /= 2
        this.progress := this.foreachloop()
        if not this.progress
            this.stoploop()
        ; else this.loopnext()
        return this.progress
    }
    foreachloop(*) {
        this.progress := ((this.ticknow - this.tickstart) / this.duration).clamp()
        return ( this.progress < 1 ) ? this.progress : false
    }
    call(*) {
        this.tickstart := A_TickCount
        this.startloop
    }

    class win extends anim {
        wintitle := "A",
        /**
         * @prop {winwrapper} win
         */
        win := 0x0,
        hwnd := 0x0

        __new(_wintitle?) {
            this.wintitle := _wintitle ?? "A"
            this.hwnd := winexist(this.wintitle)
            this.win := wincache[this.hwnd]
            super.__new()
        }

        call(*) {
            this.hwnd := winexist(this.wintitle)
            if this.hwnd != this.win.hwnd
                this.win := wincache[this.hwnd]
            super.call()
        }

        class trans extends anim.win {
            duration := 333,
            fps := 60,
            speed := 0.01,
            accel := 1.05,
            maxspeed := 2,
            friction := 0.975,
            progmod := 1,
            start_trans := 0,
            cur_trans := 0,
            targ_trans := 255

            startloop(*) {
                this.start_trans := this.win.transparency
                this.cur_trans := this.start_trans
                super.startloop()
            }

            loop(*) {
                super.loop()
                if this.progress
                    this.win.transparency := this.cur_trans
            }

            afterloop(*) {
                super.afterloop()
                this.win.transparency := this.targ_trans
                quiktool integer(wintrans.steps.IndexOf(this.targ_trans)) "." this.targ_trans
            }

            foreachloop(*) {
                if not super.foreachloop()
                    return false

                this.cur_trans := (this.start_trans).bezier(this.targ_trans, this.progress.bezier(1, this.progress))
                return this.progress
            }

            call(_targ_trans, *) {
                this.targ_trans := _targ_trans
                super.call()
            }
        }

        class rect extends anim.win {
            animate_resize := true
            duration := 500,
            fps := 500,
            startrect := vector4.rect(),
            wrect := vector4.rect(), targrect := vector4.rect()
            modrect := vector4.rect(), rtnrect := vector4.rect()

            __new(wintitle?) {
                super.__new(wintitle?)
            }

            startloop(*) {
                this.startrect.set(this.win.rect).sub(this.win.frameboundsmarginrect)
                ; SendMessage (WM_ENTERSIZEMOVE:=0x0231),,,, this.win.hwnd
                super.startloop()
            }

            loop(*) {
                if super.loop()
                    this.win.rect[true].updatepos()
                else this.win.rect[true].updatepos()
            }

            afterloop(*) {
                ; SendMessage (WM_EXITSIZEMOVE:=0x0232),,,, this.win.hwnd
                this.win.rect[true].setpos(this.targrect*)
                this.modrect.set(0)
                super.afterloop()
            }

            call(_targrect:=false, *) {
                super.call()
                if _targrect
                    this.targrect.set(_targrect*)
            }

        }
 
    }
}
