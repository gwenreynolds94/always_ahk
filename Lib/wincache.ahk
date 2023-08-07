; wincache.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include builtins_extended.ahk
#Include winwiz.ahk

class wincache {
    static _item_cache_ := Map()
        ,  _dead_item_cache_ := Map()
        ,  _last_cleanup_ := 0
        ,  _cleanup_interval_ := 5

    static __item[_win_title, _winwrapr_prop?] {

        get {
            wincache.incrlastcleanup
            wlist := !!_win_title ? winwiz.winlist[_win_title] : winwiz.winlist
            if !!_win_title and !!winexist(_win_title) and !wlist.length
                wlist := wingetlist(_win_title)
            rwlist := []
            haswraprprop := isset(_winwrapr_prop)
            for _hwnd in wlist {
                if not wincache._item_cache_.has(_hwnd) {
                    if haswraprprop
                        rwlist.push((wincache._item_cache_[_hwnd]:=winwrapper(_hwnd)).%_winwrapr_prop%)
                    else rwlist.push(wincache._item_cache_[_hwnd]:=winwrapper(_hwnd))
                }
                else if wincache._item_cache_[_hwnd].exists {
                    if haswraprprop
                        rwlist.push(wincache._item_cache_[_hwnd].%_winwrapr_prop%)
                    else rwlist.push(wincache._item_cache_[_hwnd])
                }
            }
            rwlist := (rwlist.length > 1) ? rwlist : (rwlist.length = 1) ? rwlist[1] : 0
            return rwlist
        }
    }

    static __enum(_varcount:=5) {
        ___enum(_vcnt, &_v1?, &_v2?, &_v3?, &_v4?, &_v5?) {
            static _cache_ := 0, _prev_ := 0
            wincache.incrlastcleanup
            if not _cache_
                for _h in (_cache_:=[], winwiz.winlist)
                    _cache_.push(( wincache._item_cache_.has(_h) ?
                                       wincache._item_cache_[_h] :
                       wincache._item_cache_[_h]:=winwrapper(_h) ))

            if ++_prev_ > _cache_.length
                return (_cache_:=_prev_:=0)

            switch _vcnt {
                case 1:
                    _v1 := _cache_[_prev_]
                case 2:
                    _v1 := _cache_[_prev_].hwnd
                    _v2 := _cache_[_prev_].rect
                case 3:
                    _v1 := _cache_[_prev_].hwnd
                    _v2 := _cache_[_prev_].rect
                    _v3 := _cache_[_prev_].class
                case 4:
                    _v1 := _cache_[_prev_].hwnd
                    _v2 := _cache_[_prev_].rect
                    _v3 := _cache_[_prev_].class
                    _v4 := _cache_[_prev_].exe
                case 5:
                    _v1 := _cache_[_prev_].hwnd
                    _v2 := _cache_[_prev_].rect
                    _v3 := _cache_[_prev_].class
                    _v4 := _cache_[_prev_].exe
                    _v5 := _cache_[_prev_].title
            }

            return true
        }
        return ___enum.bind(_varcount)
    }

    static incrlastcleanup(*) {
        if wincache._last_cleanup_++ >= wincache._cleanup_interval_
            wincache.cleanupbodies
    }

    static cleanupbodies(*) {
        for _hwnd, _win in wincache._item_cache_
            if not _win.exists
                wincache._dead_item_cache_[_hwnd] := _win,
                wincache._item_cache_.delete(_hwnd)
        wincache._last_cleanup_ := 0
    }
}

class winwrapper {
    _frameboundsoffset := false
    _frameboundsmargincorners := false
    _frameboundsmarginrect := false
    _frameboundsmargin := false
    _alwaysontop := false
    _rect     := false
    _realrect := false
    _exe      := ""
    _hwnd     := 0x0
    _title    := ""
    _class    := ""
    _transanim := false
    _transparency := 255
    _update_attr_min_delay_ := 100
    _last_updated_attr_ := 0
    _last_updates_ := Map(
        "title", {mintk: 100, maxtk: 1000, pvtk: 0},
        "rect", {mintk: 0, maxtk: 1000, pvtk: 0},
        "frameboundsmargincorners", {mintk: 100, maxtk: 100, pvtk: 0},
        "frameboundsmarginrect", {mintk: 100, maxtk: 100, pvtk: 0},
    )

    __new(_window_title:="") {
        this.hwnd := _window_title
    }

    _update_attr_(*) {
        ticknow := A_TickCount
        (this.exe), (this.class), (this.rect), (this.title), (this.transparency)
        ; if (ticknow - this._last_updated_attr_) > this._update_attr_min_delay_
            (this.frameboundsmargincorners), (this.frameboundsmarginrect)
        this._last_updated_attr_ := ticknow
    }

    _should_update_(_propname, _return_previous:=false, *) {
        _retbool_ := true
        if !this._last_updates_.Has(_propname)
            return
        ticknow := A_TickCount
        updt := this._last_updates_[_propname]
        tickdelta := (ticknow - updt.pvtk)
        if !_return_previous and (tickdelta < updt.mintk)
            _retbool_ := false
        else _retbool_ := !_return_previous
        if _retbool_
            updt.pvtk := ticknow
        return _retbool_
    }

    hwnd {
        get => this._hwnd
        set {
            this._hwnd := value
            if this.exists
                this._update_attr_()
        }
    }
    exists => (this.hwnd and winexist(this.hwnd))
    exe => (this.hwnd and this._exe) or (this._exe:=wingetprocessname(this.hwnd))
    class => (this.hwnd and this._class) or (this._class:=wingetclass(this.hwnd))
    title {
        get { 
            if this._should_update_("title", true)
                this._title := wingettitle(this.hwnd)
            return this._title
        }
    }
    ancestor[_GA_ANCESTOR:="PARENT"] {
        get {
            static GA_PARENT:=1, GA_ROOT:=2, GA_ROOTOWNER:=3
            return dllcall("GetAncestor", "ptr", this.hwnd, "uint", %("GA_" _GA_ANCESTOR)%)
        }
    }
    rect[_return_previous:=false] {
        get {
            if !this._rect
                this._rect := winwrapper.winrect(this)
            else if this._should_update_("rect", _return_previous)
                this._rect.set(winwiz.dll.getwindowrect(this.hwnd))
            return this._rect
        }
    }
    realrect[_return_previous:=false] {
        get {
            if !this._realrect
                this._realrect := winwiz.dll.getwindowrect(this.hwnd).sub(this.frameboundsmarginrect[_return_previous]*)
            if this._should_update_("realrect", _return_previous)
                this._realrect.set(winwiz.dll.getwindowrect(this.hwnd).sub(this.frameboundsmarginrect[_return_previous]*)*)
            return this._realrect
        }
    }
    frameboundsmarginrect[_return_previous:=false] {
        get {
            if !this._frameboundsmarginrect
                this._frameboundsmarginrect := 
                    winwiz.dll.setwindowpos.extframeboundsmargin(this.hwnd)
            else if this._should_update_("frameboundsmarginrect", _return_previous)
                this._frameboundsmarginrect.set(
                    winwiz.dll.setwindowpos.extframeboundsmargin(this.hwnd)*)
            return this._frameboundsmarginrect
        }
    }
    frameboundsmargincorners[_return_previous:=false] {
        get {
            if !this._frameboundsmargincorners
                this._frameboundsmargincorners := 
                    winwiz.dll.dwmgetwindowattribute.extendedframeboundsoffset(this.hwnd)
            else if this._should_update_("frameboundsmargincorners", _return_previous)
                this._frameboundsmargincorners.set(
                    winwiz.dll.dwmgetwindowattribute.extendedframeboundsoffset(this.hwnd))
            return this._frameboundsmargincorners
        }
    }
    alwaysontop {
        get => this._alwaysontop
        set => WinSetAlwaysOnTop(this._alwaysontop:=value, this.hwnd)
    }
    transparency[_return_previous:=false] {
        get => _return_previous ? this._transparency : (this._transparency := (wingettransparent(this.hwnd) or 255))
        set => winsettransparent(this._transparency:=integer(value).min(255).max(0), this.hwnd)
    }
    transanim[_return_previous:=true] => (_return_previous and this._transanim) ? 
                                                              (this._transanim) : 
                                  (this._transanim := anim.win.trans(this.hwnd) )
    updatepos(*) {
        winwiz.dll.setwindowpos(this.hwnd,, this.rect.add(this.win.frameboundsmarginrect*)*)
    }
    
    class winrect extends vector4.rect {
        win := {},
        tmprect := Vector4.Rect()

        __new(_win) {
            this.win := _win
            super.__new()
            this.syncpos()
        }

        setpos(_x?, _y?, _w?, _h?, _uopts?, *) {
            nt := this.__numtype__
            tmprect := this.tmprect
            hasxy := isset(_x) and isset(_y)
            haswh := isset(_w) and isset(_h)
            if hasxy
                this.set(_x, _y)
            if haswh
                this.w := %nt%(_w), this.h := %nt%(_h)
            tmprect.set(this*).add(this.win.frameboundsmarginrect[true]*)
            winwiz.dll.setwindowpos(this.win.hwnd,,
                                    hasxy ? tmprect.x : unset, 
                                    hasxy ? tmprect.y : unset,
                                    haswh ? tmprect.w : unset,
                                    haswh ? tmprect.h : unset, _uopts?)
        }

        stealthsetpos(_x?, _y?, _w?, _h?, *) {
            static SWP := winwiz.dll.setwindowpos.SWP
            this.setpos(_x?, _y?, _w?, _h?, SWP.NOREDRAW | SWP.NOACTIVATE | SWP.NOSENDCHANGING)
        }

        syncpos(*) {
            this.set(
                winwiz.dll.getwindowrect(this.win.hwnd).rectified.sub(
                     winwiz.dll.dwmgetwindowattribute.extendedframebounds(this.win.hwnd)*) 
            )
        }

        updatepos(_uopts?, *) {
            static temprect := Vector4.Rect()
            args := [temprect.set(this*).add(this.win.frameboundsmarginrect[true]*)*]
            if isset(_uopts)
                args.push _uopts
            winwiz.dll.setwindowpos(this.win.hwnd,, args*)
        }

        stealthupdatepos(*) {
            static SWP := winwiz.dll.setwindowpos.SWP
            this.updatepos(SWP.NOREDRAW | SWP.NOACTIVATE | SWP.NOSENDCHANGING)
        }
    }
}
