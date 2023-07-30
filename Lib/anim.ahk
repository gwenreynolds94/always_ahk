; anim.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include builtins_extended.ahk

class anim {
        duration := 5000
      , fps      := 100
      , speed    := 30
      , accel    := 1
      , bm       := { loop : false
                    , call : false
                    , foreachloop: false
                    , afterloop : false }
      , progress := 0
      , tickstart := 0
      , tickdelta := 0
      , tickprev := 0
      , ticknow := 0
      , tickavgdelta := 0
      , startloopdelay := 10
    __new() {
      this.bm := { loop : objbindmethod(this, "loop")
                 , call : objbindmethod(this, "call")
                 , afterloop : objbindmethod(this, "afterloop")
                 , foreachloop: objbindmethod(this, "foreachloop") }
    }
    startloop(*) {
        this.tickstart := this.tickprev := A_TickCount
        this.tickavgdelta := this.startloopdelay.abs()
        this.loopnext()
    }
    stoploop(*) {
        settimer this.bm.loop, 0
        this.afterloop()
    }
    loopnext(*) {
        loopdelay := integer(1000 / this.fps)
        loopcount := this.duration / loopdelay
        durprog := this.ticknow - this.tickstart
        lastloop := (durprog - durprog.mod(loopdelay)) / loopdelay
        nextloop := (lastloop + 1) * loopdelay
        loopdelay := (nextloop + this.tickstart) - this.ticknow
        settimer this.bm.loop, loopdelay.neg()
    }
    loop(*) {
        this.ticknow := A_TickCount
        this.tickdelta := this.ticknow - this.tickprev
        this.tickavgdelta += this.tickdelta, this.tickavgdelta /= 2
        this.progress := this.foreachloop()
        if not this.progress
            this.stoploop()
        else this.loopnext()
        this.tickprev := this.ticknow
        return this.progress
    }
    foreachloop(*) {
        this.progress := ((this.ticknow - this.tickstart) / this.duration).clamp()
        return ( this.progress < 1 ) ? this.progress : false
    }
    afterloop(*) {
        this.progress := 0
    }
    call(*) {
        this.tickstart := A_TickCount
        if !this.progress
            this.startloop
    }
    class win extends anim {
        _hwnd := "A",
        hwnd := 0x0,
        setwinpos := false,
        wrect := vector4.rect(), targrect := vector4.rect()
        modrect := vector4.rect(), rtnrect := vector4.rect()

        __new(_hwnd?) {
            this._hwnd := _hwnd ?? "A"
            this.setwinpos := winwiz.dll.setwindowpos.bm.sansextframebounds
            super.__new()
        }

        loop(*) {
            if super.loop()
                this.setwinpos(this.rtnrect*)
        }

        afterloop(*) {
            super.afterloop()
            this.setwinpos(this.wrect*)
        }

        call(_targrect:=false, *) {
            this.hwnd := winexist(this._hwnd)
            if not this.hwnd
                return false
            this.targrect := ((_targrect is vector4) ? _targrect :
                  (_targrect is array and _targrect.length = 4) ?
                                   this.targrect.set(_targrect*) : this.targrect)
            this.wrect.set(winwiz.dll.dwmgetwindowattribute.extendedframebounds(this.hwnd).rectified)
            this.modrect.set(0)
            super.call()
        }

    }
}
