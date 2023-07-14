; anim.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include builtins_extended.ahk

class anim {
        duration := 5000
      , fps      := 100
      , bm       := { loop : false
                    , call : false
                    , foreachloop: false
                    , afterloop : false }
      , progress := 0
      , tickstart := 0
    __new() {
      this.bm := { loop : objbindmethod(this, "loop")
                 , call : objbindmethod(this, "call")
                 , afterloop : objbindmethod(this, "afterloop")
                 , foreachloop: objbindmethod(this, "foreachloop") }
    }
    loop(*) {
        if !(this.foreachloop(&_progress:=this.progress, this.tickstart, this.duration))
            return (settimer(this.bm.loop, 0), this.afterloop(), false)
        return (this.progress := _progress)
    }
    foreachloop(&_progress, _tickstart, _duration, *) {
        _progress := ((A_TickCount - _tickstart) / _duration).clamp()
        return (_progress < 1)
    }
    afterloop(*) {
        this.progress := 0
    }
    call(*) {
        this.tickstart := A_TickCount
        settimer(this.bm.loop, (1000 // this.fps).abs())
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
