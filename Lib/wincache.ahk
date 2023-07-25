; wincache.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include builtins_extended.ahk
#Include winwiz.ahk

class wincache {
    static _item_cache_ := Map()

    static __item[_win_title, _winwrapr_prop?] {

        get {
            _win_title := (_win_title = "A") ? winexist("A") : _win_title
            if _win_title and (_win_title is number) {
                if this._item_cache_.has(_win_title) and this._item_cache_[_win_title].exists
                    return this._item_cache_[_win_title]
                else if (newwin:=winwrapper(_win_title)).exists
                    return (this._item_cache_[_win_title]:=newwin)
                else return false
            }
            wlist := !!_win_title ? winwiz.winlist[_win_title] : winwiz.winlist
            rwlist := []
            haswraprprop := isset(_winwrapr_prop)
            for _hwnd in wlist {
                if not wincache._item_cache_.has(_hwnd)
                    rwlist.push(wincache._item_cache_[_hwnd]:=winwrapper(_hwnd))
                else if wincache._item_cache_[_hwnd].exists {
                    if haswraprprop
                        rwlist.push(wincache._item_cache_[_hwnd].%_winwrapr_prop%)
                    else rwlist.push(wincache._item_cache_[_hwnd])
                }
            }
            return rwlist
        }
    }

    static __enum(_varcount:=5) {
        ___enum(_vcnt, &_v1?, &_v2?, &_v3?, &_v4?, &_v5?) {
            static _cache_ := 0, _prev_ := 0
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
}

class winwrapper {
    _frameboundsoffset := false
    _frameboundsmargin := false
    _rect     := false
    _exe      := ""
    _title    := ""
    _class    := ""
    hwnd      := 0x0

    __new(_window_title:="") {
        this.hwnd := winexist(_window_title)
        if !this.hwnd
            return
        (this.exe), (this.class), (this.rect), (this.title)
        (this.frameboundsmargincorners), (this.frameboundsmarginrect)
    }

    exists => (this.hwnd and winexist(this))
    title => (this.hwnd and this._title) or (this._title:=wingettitle(this.hwnd))
    exe => (this.hwnd and this._exe) or (this._exe:=wingetprocessname(this.hwnd))
    class => (this.hwnd and this._class) or (this._class:=wingetclass(this.hwnd))

    ancestor[_GA_ANCESTOR:="PARENT"] {
        get {
            static GA_PARENT:=1, GA_ROOT:=2, GA_ROOTOWNER:=3
            return dllcall("GetAncestor", "ptr", this.hwnd, "uint", %("GA_" _GA_ANCESTOR)%)
        }
    }
    rect[_return_previous:=false] {
        get => ((_return_previous and this._rect) or (this._rect :=
            winwiz.dll.getwindowrect.framebounds(this.hwnd).Rectified ))
    }
    frameboundsmargincorners[_return_previous:=false] {
        get => ((_return_previous and this._frameboundsoffset) or (this._frameboundsoffset :=
            winwiz.dll.dwmgetwindowattribute.extendedframeboundsoffset(this.hwnd) ))
    }
    frameboundsmarginrect[_return_previous:=false] {
        get => ((_return_previous and this._frameboundsmargin) or (this._frameboundsmargin :=
            winwiz.dll.setwindowpos.extframeboundsmargin(this.hwnd) ))
    }

    alwaysontop {
        set => WinSetAlwaysOnTop(value, this.hwnd)
    }
}
#Include DEBUG\jk_debug.ahk
^0::{
    dbgln({__o__:1,printfuncs:0, nestlvlmax:2},("*-".repeat(66) "`n").repeat(5), wincache*)
}
^9::{
    dbgln({__o__:1,nestlvlmax:8},("*--".repeat(30)), wincache)
}
