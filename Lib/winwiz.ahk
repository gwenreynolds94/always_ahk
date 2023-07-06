; winwiz.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include bultins_extended.ahk

class winwiz {

    static _recent_winlists_ := Map()
         , blacklists := Map(
                "class" , [
                    "Progman", "Shell_(Secondary)?TrayWnd", "SysShadow", "EdgeUiInputWndClass",
                    "Internet Explorer_Hidden", "ApplicationManager_ImmersiveShellWindow",
                    "CEF-OSC-WIDGET", "RainmeterMeterWindow", "tooltips_class32"
                ],
                "processname" , [],
                "title" , [ "^Program\sManager", "^Window\sSpy\sfor\sAHKv2" ],
            )
         , whitelists := Map(
                "class", [],
                "processname", [],
                "title", []
            )
         , methbinds := {
                loopwindows: {},
                cyclewindows: {}
            }

    static __new() {
        this.methbinds.cyclewindows := objbindmethod(this, "cyclewindows")
        this.methbinds.loopwindows := objbindmethod(this, "loopwindows")
    }

    static _debug_wintitles(_wlist*) {
        outstr := ""
        for _wtitle in _wlist
            outstr .= "::: " wingettitle(_wtitle) "`n:::class:: " wingetclass(_wtitle) "`n:::processname:: " wingetprocessname(_wtitle) "`n`n"
        outputdebug outstr "`n::: ::: ::: ::: :::`n`n"
    }

    /**
     * @param {string} [_return_type="hwnd"] `hwnd` | `class` | `title` | `process` | `processpath`
     * @prop {number|string} win_under_mouse
     */
    static mousewin[_return_type:="hwnd"] {
        get {
            MouseGetPos(,, &_hwnd)
            return (not winexist(_hwnd))          ? false               :
                   (_return_type = "hwnd")        ? _hwnd               :
                   (_return_type = "class")       ? WinGetClass()       :
                   (_return_type = "title")       ? WinGetTitle()       :
                   (_return_type = "processpath") ? WinGetProcessPath() :
                   (_return_type = "processname") ? WinGetProcessName() : _hwnd
        }
    }

    /**
     * @param {string} [_wintitle=""]
     * @param {integer} [_use_recent=false]
     */
    static winlist[_wintitle:="", _use_recent:=false] {
        get {
            winlist_filter(_f_wintitle, *) {
                for _listgroup in [[this.whitelists,1],[this.blacklists,0]]
                    for _type, _list in _listgroup[1] {
                        _f_wintitle_alt := %("winget" _type)%(_f_wintitle)
                        for _title in _list
                            if _f_wintitle_alt ~= _title
                                return _listgroup[2]
                    } return true
            }
            if !!_use_recent and !!this._recent_winlists_.Has(_wintitle)
                return this._recent_winlists_[_wintitle]
            retwinlist :=
                this._recent_winlists_[_wintitle] :=
                    wingetlist(_wintitle).Filter(winlist_filter)
            return retwinlist
        }
    }


    class swirl {
        
    }

    static loopwindows(_reverse:=false, _wintitle:="", _use_recent_winlist:=false, *) {
        ; static setwinpos := winwiz.dll.setwindowpos, SWP := setwinpos.SWP, HWND_ := setwinpos.HWND
        _wintitle := (!!_wintitle and !!winexist(_wintitle)) ? _wintitle : ""
        targwins := this.winlist[_wintitle, _use_recent_winlist]
        winlen := targwins.length
        if winlen <= 1
            return false
        ; ... use setwindowpos to set z_order of window
        ; if !_reverse
            ; setwinpos(targwins[1], HWND_.BOTTOM,,,,,SWP.NOSIZE|SWP.NOMOVE|SWP.NOACTIVATE)
        ; setwinpos(targwins[_reverse ? winlen : 2], HWND_.TOP,,,,,SWP.NOSIZE|SWP.NOMOVE|SWP.SHOWWINDOW)
        ; winactivate targwins[winlen]

        dest_index := _reverse ? winlen : !!_wintitle ? 2 : (winmovebottom(targwins[1]), 2)
        winactivate targwins[dest_index]
        return true
    }

    static cyclewindows(_reverse:=false, _wintitle:="", _use_recent_winlist:=false, *) {
        _wintitle := (!!_wintitle and !!winexist(_wintitle)) ? _wintitle : ""
        windows := this.winlist[_wintitle, _use_recent_winlist]
        if windows.length <= 1
            return false
        winactivate windows[(_reverse ? windows.length : 2)]
        return true
    }

    static insertafter(_wtitlea, _wtitleb:="") {
        static setwinpos := winwiz.dll.setwindowpos, SWP := setwinpos.SWP, HWND_ := setwinpos.HWND
        w_a := !!winexist(_wtitlea) ? _wtitlea : false
        w_b := !!winexist(_wtitleb) ? _wtitleb : false
        if not ( w_a and w_b )
            return false
        
    }

    /**
     */
    static winfromtop[_zorder:=2, _wintitle:="", _use_recent_winlist:=false] {
        get {
            _wintitle := (!!_wintitle and !!winexist(_wintitle)) ? _wintitle : ""
            windows := this.winlist[_wintitle, _use_recent_winlist]
            _zorder := (_zorder < 1) ? (windows.Length + _zorder) :
                       (_zorder > windows.Length) ? windows.Length : _zorder
            winfromtop_hwnd := windows[_zorder]
            return winfromtop_hwnd
        }
    }

    /**
     */
    static winfromzoffset[_zoffset:=1, _wintitle:="", _reverse:=false, _use_recent_winlist:=false] {
        get {
            _wintitle := (!!_wintitle and !!winexist(_wintitle)) ? _wintitle : ""
            windows := this.winlist[_wintitle, _use_recent_winlist]
            _zoffset := (_zoffset < 1) ? (windows.Length + _zoffset - 1) :
                        (_zoffset > windows.Length) ? windows.Length     :
                        (_reverse) ? (windows.length - _zoffset + 1)     : _zoffset
            if _reverse
                _zoffset := windows.Length - _zoffset + 1
            return windows[_zoffset]
        }
    }

    class dll {

        class setwindowpos {

            static SWP := { NOSIZE         : 0x0001
                          , NOMOVE         : 0x0002
                          , NOZORDER       : 0x0004
                          , NOREDRAW       : 0x0008
                          , NOACTIVATE     : 0x0010
                          , FRAMECHANGED   : 0x0020
                          , SHOWWINDOW     : 0x0040
                          , HIDEWINDOW     : 0x0080
                          , NOCOPYBITS     : 0x0100
                          , NOOWNERZORDER  : 0x0200
                          , NOSENDCHANGING : 0x0400 }

                 , HWND := { BOTTOM     : ( 1)
                           , NOTTOPMOST : (-2)
                           , TOP        : ( 0)
                           , TOPMOST    : (-1) }

            static call(_hwnd, _hwnd_insert_after?, _x?, _y?, _cx?, _cy?, _uflags?) {
                static uflags := this.SWP.FRAMECHANGED|this.SWP.SHOWWINDOW

                if not isset(_uflags) {
                    uflags := this.SWP.FRAMECHANGED|this.SWP.SHOWWINDOW
                    if !isset(_x) or !isset(_y)
                        uflags |= this.SWP.NOMOVE
                    if !isset(_cx) or !isset(_cy)
                        uflags |= this.SWP.NOSIZE
                } else if _uflags is number
                    uflags := _uflags

                dllcall "SetWindowPos",
                        "UInt"        , _hWnd                             ,
                        "UInt"        , _hwnd_insert_after ?? 0           ,
                        "Int"         , _x ?? 0                           ,
                        "Int"         , _y ?? 0                           ,
                        "Int"         , _cx ?? 0                          ,
                        "Int"         , _cy ?? 0                          ,
                        "UInt"        , uflags
            }

        }

    }

}
