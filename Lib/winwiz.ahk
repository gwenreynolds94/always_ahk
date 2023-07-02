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
                "processname" , [ ],
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
                    }
                return true
            }
            if !!_use_recent and !!this._recent_winlists_.Has(_wintitle)
                return this._recent_winlists_[_wintitle]
            retwinlist :=
                this._recent_winlists_[_wintitle] :=
                    wingetlist(_wintitle).Filter(winlist_filter)
            return retwinlist
        }
    }

    /**
     * @prop {integer} prevwin
     * @param {string|integer} [_wintitle=""]
     * @param {integer} [_zorder=1]
     */
    static prevwin[_wintitle:="", _zorder:=2, _use_recent_winlist:=false] {
        get {
            if !!_wintitle and !winexist(_wintitle)
                return 0x0
            windows := this.winlist[_wintitle, _use_recent_winlist]
            _zorder := (_zorder < 1) ? (windows.Length + _zorder) :
                       (_zorder > windows.Length) ? windows.Length : _zorder
            prevwin_hwnd := windows[_zorder]
            return prevwin_hwnd
        }
    }

    /**
     * @prop {integer} btmwin
     * @param {string|integer} [_wintitle=""]
     * @param {integer} [_zorder=1]
     */
    static btmwin[_wintitle:="", _zorder:=1, _use_recent_winlist:=false] {
        get {
            _wintitle := !!winexist(_wintitle) ? _wintitle : ""
            windows := this.winlist[_wintitle, _use_recent_winlist]
            _zorder := (_zorder < 1) ? (windows.Length + _zorder) :
                       (_zorder > windows.Length) ? windows.Length : _zorder
            _zorder := windows.Length - _zorder + 1
            btmwin_hwnd := windows[_zorder]
            return btmwin_hwnd
        }
    }

    static loopwindows(_reverse:=false, _wintitle:="", _use_recent_winlist:=false, *) {
        _wintitle := (!!_wintitle and !!winexist(_wintitle)) ? _wintitle : ""
        windows := this.winlist[_wintitle, _use_recent_winlist]
        if _reverse
            winactivate(windows[windows.length])
        else winmovebottom(windows[1]),
             winactivate(windows[2])
    }

    static cyclewindows(_reverse:=false, _wintitle:="", _use_recent_winlist:=false, *) {
        _wintitle := (!!_wintitle and !!winexist(_wintitle)) ? _wintitle : ""
        windows := this.winlist[_wintitle, _use_recent_winlist]
        if windows.length <= 1 
            return
        winactivate windows[(_reverse ? windows.length : 2)]
    }
}
