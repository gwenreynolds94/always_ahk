; winwiz.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include builtins_extended.ahk
#Include anim.ahk
#Include quiktip.ahk
#Include wincache.ahk

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
                "processname", ["firefox.exe", "wezterm-gui.exe"],
                "title", []
            )
         , bm := {
                loopwindows:  {},
                cyclewindows: {},
                searchv2docs: {},
                winkillclass: {}
            }

    static __new() {
        this.bm.loopwindows  := objbindmethod(this,  "loopwindows")
        this.bm.cyclewindows := objbindmethod(this, "cyclewindows")
        this.bm.searchv2docs := objbindmethod(this, "searchv2docs")
        this.bm.winkillclass := objbindmethod(this, "winkillclass")
    }

    static _debug_wintitles(_wlist*) {
        outstr := ""
        for _wtitle in _wlist
            outstr .= ":::"             wingettitle(_wtitle) "`n"
                   .  ":class:: "       wingetclass(_wtitle) "`n"
                   .  ":processname:: " wingetprocessname(_wtitle) "`n`n"
        outputdebug outstr "`n::: ::: ::: ::: :::`n`n"
    }

    /**
     * @param {string} [_return_type="hwnd"] `hwnd` | `class` | `title` | `process` | `processpath`
     * @prop {number|string} win_under_mouse
     */
    static mousewintitle[_return_type:="hwnd"] {
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

    static mousewin => wincache[winwiz.mousewintitle]

    /**
     * @prop {Array} winlist
     * @return {Array}
     */
    static winlist[_wintitle:="", _use_recent:=false] {
        /**
         * @return {Array}
         */
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
            /**
              * @type {Array}
              */
            retwinlist :=
                this._recent_winlists_[_wintitle] :=
                    wingetlist(_wintitle).Filter(winlist_filter)
            return retwinlist
        }
    }


    class wiggle extends anim.win {
          cycles := 10
        , amplitude := 32

        foreachloop(&_progress, _tickstart, _duration) {
            if not super.foreachloop(&_progress, _tickstart, _duration)
                return (false)
            this.modrect.x := sin(2 * Math.PI * this.cycles * _progress) * this.amplitude
            this.modrect.y := cos(2 * Math.PI * this.cycles * _progress) * this.amplitude * 0.75
            this.rtnrect.set(this.wrect).add(this.modrect).lerp(this.wrect, cos(2 * Math.PI * _progress))
            return _progress
        }
    }

    class spring extends anim.win {
        targrect := vector4.rect(A_ScreenWidth + 4, 4, A_ScreenWidth - 8, A_ScreenHeight - 8),
        amplitude := 64,
        cycles := 5

        foreachloop(&_progress, _tickstart, _duration) {
            if not super.foreachloop(&_progress, _tickstart, _duration)
                return (this.wrect.set(this.targrect), false)
            this.modrect.y := cos(2 * Math.PI * _progress * this.cycles) * this.amplitude * 0.75
            this.rtnrect.set(this.wrect).add(this.modrect).lerp(this.targrect, cos(2 * Math.PI) * _progress)
            return _progress
        }
    }

    class slide extends anim.win {
        targrect := vector4.rect(A_ScreenWidth + 4, 4, A_ScreenWidth - 8, A_ScreenHeight - 8),
        duration := 333
        foreachloop(&_progress, _tickstart, _duration) {
            if not super.foreachloop(&_progress, _tickstart, _duration)
                return (this.wrect.set(this.targrect), false)
            this.modrect.set(this.targrect).sub(this.wrect).mul(sin(0.5 * Math.PI * _progress)).add(this.wrect)
            this.rtnrect.set(this.wrect).lerp(this.modrect, sin(0.5 * Math.PI * _progress))
            return _progress
        }
    }

    static loopwindows(_reverse:=false, _wintitle:="", _always_switch:=false, _use_recent_winlist:=false, *) {
        ; static setwinpos := winwiz.dll.setwindowpos, SWP := setwinpos.SWP, HWND_ := setwinpos.HWND
        _wintitle := (!!_wintitle and !!winexist(_wintitle)) ? _wintitle : ""
        targwins := wincache[_wintitle]
        if (targwins.length = 1) and !!(_wintitle) and _always_switch
            targwins := this.winlist
        if (winlen := targwins.length) < 1
            return false
        dest_index := _reverse ? winlen : 2
        if (dest_index = 2) and winlen > dest_index
            this.insertafter(targwins[1], targwins[winlen])
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

    static winkillclass(_wintitle:="", _waitfor:=2) {
        winhwnd := winexist(_wintitle or "A")
        winclass := wingetclass(winhwnd)
        for _win in (classlist:=this.winlist["ahk_class " winclass])
            winclose _win,, _waitfor
        quiktray("death total: " classlist.length, "[ " winclass " ]", 3333)
    }

    static insertafter(_wtitlea, _wtitleb:="", _activate:=false, *) {
        static setwinpos := winwiz.dll.setwindowpos, SWP := setwinpos.SWP, HWND_ := setwinpos.HWND
        w_a := winexist(_wtitlea)
        w_b := winexist(_wtitleb)
        swp_opts := (!_activate and SWP.NOACTIVATE)
        if not w_a
            return false
        setwinpos(w_a, w_b,,,,, swp_opts)
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

    static searchv2docs(_searchterm:=false, _newwindow:=false, *) {
        wintitle := "AutoHotkey v2 Help ahk_exe hh.exe"
        if !winexist(wintitle) or _newwindow {
            run '"C:\Program Files\AutoHotkey\v2.0.2\AutoHotkey.chm"',,, &_hhpid
            _found := winwait("ahk_pid" _hhpid,, 5)
        } else _found := true
        if not _found
            return
        winactivate _newwindow and _found or wintitle
        winwaitactive wintitle
        sleep 20
        send "{LAlt Down}s{LAlt Up}"
        sleep 30
        send "{LCtrl Down}a{LCtrl Up}"
        sleep 30
        send ("{Raw}" (type(_searchterm) = "string" and _searchterm or string(A_Clipboard)))
        sleep 30
        send "{Enter}"
    }

    static swap(_wtitle1, _wtitle2) {
        hwnd1 := winexist(_wtitle1)
        hwnd2 := winexist(_wtitle2)
        w1 := wincache[hwnd1]
        w2 := wincache[hwnd2]
        nrect1 := vector4.rect(w2.rect*).add(w1.frameboundsmarginrect)
        nrect2 := vector4.rect(w1.rect*).add(w2.frameboundsmarginrect)
        winwiz.dll.setwindowpos(hwnd1,,nrect1*)
        winwiz.dll.setwindowpos(hwnd2,,nrect2*)
    }

    static swaponpress(_key:="LButton") {
        onpress(_wtitle1, __key, *) {
            winwiz.swap(_wtitle1, winwiz.mousewintitle)
            hotkey __key, "off"
        }
        hotkey _key, onpress.bind(winwiz.mousewintitle, _key), "on"
    }

    class drag {
        static home := { win : false
                  ,   winpos : vector2.pos()
                  ,  winsize : vector2.size()
                  , fbndsoff : vector4.rect()
                  , mousepos : vector2.pos() }
        , ismoving := false
        , issizing := false
        , holdtomove := "LButton"
        , holdtosize := "RButton"
        , _move_enabled_ := false
        , _move_hotif_ := false
        , _size_enabled_ := false
        , _size_hotif_ := false
        , timerinterval := 10
        , min_size := vector2.size(100, 100)
        , bm := {
            movestart: objbindmethod(this, "movestart")
          , sizestart: objbindmethod(this, "sizestart")
        }
        static move_enabled => this._move_enabled_
        static size_enabled => this._size_enabled_
        static move_hotif => this._move_hotif_
        static size_hotif => this._size_hotif_
        static setholdtomove(_movekey, *) {
            this.holdtomove := _movekey
            this._move_hotif_:= ((*)=>(!this.ismoving))
            hotif this.move_hotif
            hotkey this.holdtomove, this.bm.movestart, "On"
            hotif()
            this._move_enabled_ := true
        }
        static setholdtosize(_sizekey, *) {
            this.holdtosize := _sizekey
            this._size_hotif_ := ((*)=>(!this.issizing))
            hotif this.size_hotif
            hotkey this.holdtosize, this.bm.sizestart, "On"
            hotif()
            this._size_enabled_ := true
        }
        static unsetholdtomove(*) {
            hotif this.move_hotif
            hotkey this.holdtomove, "Off"
            hotif()
            this._move_enabled_ := false
        }
        static unsetholdtosize(*) {
            hotif this.size_hotif
            hotkey this.holdtosize, "Off"
            hotif()
            this._size_enabled_ := false
        }
        static movestart(*) {
            static deltapos := vector2.pos(), newpos := vector2.pos()
            this.ismoving := true
            this.home.win := winwiz.mousewin
            this.home.winpos.set(this.home.win.rect.pos)
            this.home.fbndsoff.set(this.home.win.frameboundsmarginrect)
            this.home.mousepos.set(winwiz.dll.mouse.cursorpos)
            settimer _moving_, this.timerinterval
            _moving_(*) {
                if !getkeystate(this.holdtomove.Replace("^[\+\!\#\^]+"), "P")
                    return (settimer(,0), this.ismoving := false)
                deltapos.set(winwiz.dll.mouse.cursorpos).sub(this.home.mousepos)
                newpos.set(this.home.winpos).add(deltapos).add(this.home.fbndsoff)
                winwiz.dll.setwindowpos(this.home.win, 0, newpos*)
            }
        }
        static sizestart(*) {
            static newsize := vector2.size(), deltasize := vector2.size()
            this.issizing := true
            this.home.win := winwiz.mousewin
            this.home.winsize.set(this.home.win.rect)
            this.home.fbndsoff.set(this.home.win.frameboundsmarginrect)
            this.home.mousepos.set(winwiz.dll.mouse.cursorpos)
            settimer _sizing_, this.timerinterval
            postmessage 0x1666,1,,, this.home.win
            _sizing_(*) {
                if !getkeystate(this.holdtosize.replace("^[\+\!\#\^]+"), "P") {
                    settimer(,0)
                    this.issizing := false
                    postmessage 0x1666,0,,, this.home.win
                    return
                }
                deltasize.set(winwiz.dll.mouse.cursorpos*).sub(this.home.mousepos*)
                newsize.set(this.home.winsize).add(deltasize*)
                winwiz.dll.setwindowpos(this.home.win, 0,,, newsize*)
            }
        }
    }

    class dll {

        class mouse {
            static cursorpos[_relative?] {
                get => this.getcursorpos()
                set => this.setcursorpos(value.x, value.y, _relative?)
            }

            static getcursorpos(*) {
                int_point := Buffer(8)
                DllCall "GetCursorPos", "ptr", int_point
                ret_point := vector2.pos( NumGet(int_point, 0, "int") ,
                                          NumGet(int_point, 4, "int") )
                return ret_point
            }

            static setcursorpos(_mouse_x?, _mouse_y?, _relative:=false, *) {
                existing_point := this.getcursorpos()
                _mouse_x := _relative ? (existing_point.x+=(_mouse_x ?? 0)) : (_mouse_x ?? existing_point.x)
                _mouse_y := _relative ? (existing_point.y+=(_mouse_y ?? 0)) : (_mouse_y ?? existing_point.y)
                DllCall "SetCursorPos"
                    , "int", _mouse_x
                    , "int", _mouse_y
            }
        }

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
                 , bm := {
                     sansextframebounds : objbindmethod(this, "sansextframebounds")
                 }

            static call(_hwnd, _hwnd_insert_after?, _x?, _y?, _cx?, _cy?, _uflags?) {
                static uflags := this.SWP.FRAMECHANGED|this.SWP.SHOWWINDOW
                _hwnd := winexist(_hwnd or "A")

                if not isset(_uflags) {
                    uflags := this.SWP.NOACTIVATE
                } else if _uflags is number
                    uflags := _uflags

                hasNOMOVE:=((uflags & this.SWP.NOMOVE) == this.SWP.NOMOVE)
                hasNOSIZE:=((uflags & this.SWP.NOSIZE) == this.SWP.NOSIZE)

                if !isset(_x) or !isset(_y)
                    uflags |= !hasNOMOVE and this.SWP.NOMOVE
                else if hasNOMOVE
                    uflags &= ~this.SWP.NOMOVE

                if !isset(_cx) or !isset(_cy)
                    uflags |= !hasNOSIZE and this.SWP.NOSIZE
                else if hasNOSIZE
                    uflags &= ~this.SWP.NOSIZE

                dllcall "SetWindowPos",
                        "UInt"        , _hWnd                  ,
                        "UInt"        , _hwnd_insert_after ?? 0,
                        "Int"         , _x ?? 0                ,
                        "Int"         , _y ?? 0                ,
                        "Int"         , _cx ?? 0               ,
                        "Int"         , _cy ?? 0               ,
                        "UInt"        , uflags                 ;
            }

            static extframeboundsmargin(_hwnd) {
                extfrmbnds := winwiz.dll.dwmgetwindowattribute.extendedframebounds(_hwnd).rectified
                ncwinrect  := winwiz.dll.getwindowrect(_hwnd).rectified
                return ncwinrect.sub(extfrmbnds)
            }

            static sansextframebounds(_hwnd, _x?, _y?, _cx?, _cy?, _hwnd_insert_after?, _uflags?, _use_prev_offset:=true, *) {
                static prevoffsets := map(), winrect := vector4.rect()
                _hwnd := winexist(_hwnd or "A")
                if _use_prev_offset and prevoffsets.has(_hwnd)
                    offset := prevoffsets[_hwnd]
                else prevoffsets[_hwnd] := 
                        offset := winwiz.dll.setwindowpos.extframeboundsmargin(_hwnd)
                _args := [winrect.set(_x, _y, _cx, _cy).add(offset)*]
                _args.push(_uflags ?? unset)
                winwiz.dll.setwindowpos( (prevhwnd:=_hwnd), _hwnd_insert_after ?? unset, _args* )
            }

        }

        class getwindowrect {

            static call(_hwnd?) {
                _hwnd := winexist((_hwnd ?? "A") or "A")
                lpRect := buffer(16)
                dllcall "GetWindowRect", "ptr", _hwnd, "ptr", lpRect
                retRect := vector4.rect.corners( numget(lpRect,  0, "int")
                                               , numget(lpRect,  4, "int")
                                               , numget(lpRect,  8, "int")
                                               , numget(lpRect, 12, "int") )
                return retRect
            }

            static framebounds(_hwnd?) =>
                winwiz.dll.dwmgetwindowattribute.extendedframebounds(
                                    winexist((_hwnd ?? "A") or "A"))
        }

        class dwmgetwindowattribute {
            static DWMWA := {
                NCRENDERING_ENABLED           : 0x00000001
              , NCRENDERING_POLICY            : 0x00000002
              , TRANSITIONS_FORCEDISABLED     : 0x00000003
              , ALLOW_NCPAINT                 : 0x00000004
              , CAPTION_BUTTON_BOUNDS         : 0x00000005
              , NONCLIENT_RTL_LAYOUT          : 0x00000006
              , FORCE_ICONIC_REPRESENTATION   : 0x00000007
              , FLIP3D_POLICY                 : 0x00000008
              , EXTENDED_FRAME_BOUNDS         : 0x00000009
              , HAS_ICONIC_BITMAP             : 0x0000000a
              , DISALLOW_PEEK                 : 0x0000000b
              , EXCLUDED_FROM_PEEK            : 0x0000000c
              , CLOAK                         : 0x0000000d
              , CLOAKED                       : 0x0000000e
              , FREEZE_REPRESENTATION         : 0x0000000f
              , PASSIVE_UPDATE_MODE           : 0x00000010
              , USE_HOSTBACKDROPBRUSH         : 0x00000011
              , USE_IMMERSIVE_DARK_MODE       : 0x00000014
              , WINDOW_CORNER_PREFERENCE      : 0x00000021
              , BORDER_COLOR                  : 0x00000022
              , CAPTION_COLOR                 : 0x00000023
              , TEXT_COLOR                    : 0x00000024
              , VISIBLE_FRAME_BORDER_THICKNESS: 0x00000025
              , SYSTEMBACKDROP_TYPE           : 0x00000026
              , LAST                          : 0x00000027
            }
            static call(_hwnd, _dwAttribute, &_pvAttribute, _cbAttribute) {
                _hwnd := winexist(_hwnd or "A")
                dllcall "dwmapi\DwmGetWindowAttribute",
                        "ptr" , _hwnd                 ,
                        "uint", _dwAttribute          ,
                        "ptr" , _pvAttribute          ,
                        "uint", _cbAttribute          ;
            }
            static extendedframebounds(_hwnd) {
                pvAttribute := buffer(16)
                winwiz.dll.dwmgetwindowattribute _hwnd                           ,
                                                 this.DWMWA.EXTENDED_FRAME_BOUNDS,
                                                 &pvAttribute                    ,
                                                 pvAttribute.size
                retRect := vector4.rect.corners( numget(pvAttribute,  0, "int")
                                               , numget(pvAttribute,  4, "int")
                                               , numget(pvAttribute,  8, "int")
                                               , numget(pvAttribute, 12, "int") )
                return retRect
            }
            static extendedframeboundsoffset(_hwnd) {
                extfrmbnds := winwiz.dll.dwmgetwindowattribute.extendedframebounds(_hwnd)
                ncwinrect := winwiz.dll.getwindowrect(_hwnd)
                return ncwinrect.sub(extfrmbnds)
            }
        }

    }

}
