; jk_debug.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include ..\builtins_extended.ahk
#Include ..\quiktip.ahk

class ___DBG___ {
    static cfg := {
        desc: {
            __o__: 1,
            nestlvlmax: 3,
            nestchars: ["|", ":"],
            verbosity: 2,
            printfuncs: true
        },
        dbgo: {
            __o__: 1,
            focusdebugview: false,
            opendebugview: false
        },
        dbgln: {
            __o__: 1,
            focusdebugview: true,
            nestlvlmax: 3,
            nestchars: ["|", ":"],
            verbosity: 2,
            printfuncs: true,
            opendebugview: true,
            focusprevwin: false,
            focusprevwintimeout: 2222
        },
        msgo: {
            __o__: 1,
            focusdebugview: false,
            opendebugview: false
        },
        stdo: {
            __o__: 1,
            focusdebugview: false,
            opendebugview: false
        }
    }, bm := {
         opendebugview   : objbindmethod(this, "opendebugview"),
        focusdebugview   : objbindmethod(this, "focusdebugview"),
        activateprevwin  : objbindmethod(this, "activateprevwin"),
        activatedebugview: objbindmethod(this, "activatedebugview"),
    }, debugview_wintitle := "ahk_exe dbgview64.exe"

    static __new() {
    }
    static asd => (13,235,32,46,34,6,346,34,6,36,
        0,045)

    static parseopts(&_opts, &_cfgs, _strip_opts:=true, _fill_opts:=true, _set_cfgs:=false, _whatif:=false) {
        if !objhasownprop(_opts, "__o__")
            return false
        optsincfgs  :=  [objownprops(_opts)*].filter2((_v)=>(objhasownprop(_cfgs,_v)))
        cfgsinopts  :=  [objownprops(_cfgs)*].filter2((_v)=>(objhasownprop(_opts,_v)))
        (_strip_opts and optsincfgs[ false ].foreach((_v,*)=>(%(&_opts)%.deleteprop(_v))))
        ( _fill_opts and cfgsinopts[ false ].foreach((_v,*)=>(%(&_opts)%.%_v%:=_cfgs.%_v%)))
        (  _set_cfgs and optsincfgs[  true ].foreach((_v,*)=>(%(&_cfgs)%.%_v%:=_opts.%_v%)))
        return map("opts", _opts, "cfgs", _cfgs)
    }

    static opendebugview(*) {
        static _exe_path := "C:\Users\" A_UserName "\Portables\sysinternals\DebugView\dbgview64.exe"
        if not winexist("ahk_exe dbgview64.exe") {
            run _exe_path,,, &_dbgview_pid:=0
            winwait "ahk_pid " _dbgview_pid
            winactivate "ahk_pid " _dbgview_pid
        }
    }

    static prevwin => (
        SetTitleMatchMode("RegEx"),
        winexist("ahk_exe i)(wezterm(\-gui)?|cmd|pwsh)\.exe") )

    static activateprevwin(*) => ( settimer(this.bm.activateprevwin,0),
            (_pw:=this.prevwin) and winexist(_pw) and winactivate(_pw))
    static activatedebugview(*) => ( settimer(this.bm.activatedebugview,0),
            winexist(this.debugview_wintitle) and winactivate(this.debugview_wintitle))

    static focusdebugview(_focus_prevwin:=false, *) {
        this.activatedebugview()
        if _focus_prevwin
            settimer(___DBG___.bm.activateprevwin, (1000).neg())
    }
}


__DBG__describe(_opts?, _objlist*) {
    if not _objlist.Length
        return
    desc := ""
    _opts := (_opts ?? false) or ___DBG___.cfg.desc.clone()
    nestlvl := 0
    verbosity := _opts.verbosity
    nestlvlmax := _opts.nestlvlmax
    nestchars := _opts.nestchars
    printfuncs := _opts.printfuncs
    indstr := inddef := " " nestchars[1] " "

    EvalIndent() {
        ind := ""
        loop nestlvl
            ind .= " " nestchars[Mod(A_Index + nestchars.Length - 1, nestchars.Length) + 1] " "
        return ind
    }

    EvalPastMax(_nestlvl?) {
        pastnestmax := ((_nestlvl ?? nestlvl) > (nestlvlmax))
        return pastnestmax
    }

    TryStringOut(out_item) {
        ind := EvalIndent()
        Try
            Return ind " " String(out_item) "`n"
        Catch MethodError
            Return TryObjectOut(out_item)
    }

    CollectOwnProps(_obj) {
        out_str := ""
        _prop_names := []
        try for _prop_name in ObjOwnProps(_obj is varref and %(%_obj%)% or _obj)
            _prop_names.Push _prop_name
        if not _prop_names.Length
            return ""
        if EvalPastMax()
            return EvalIndent() "Props[Prototype][" _prop_names.Length "]...`n"
        out_str .= EvalIndent() "Props[Prototype]:`n"
        for _prop_name in _prop_names {
            if EvalPastMax() {
                out_str .= TryStringOut(_prop_name ": ...")
            } else {
                out_str .= EvalIndent() " " _prop_name
                if verbosity >= 1 {
                    nestlvl++
                    if EvalPastMax()
                        out_str .= "...`n"
                    else {
                        try (out_str .= "`n" TryStringOut(_obj.%_prop_name%))
                        catch
                            out_str .= "`n"
                    }
                    nestlvl--
                }
            }
        }
        return out_str
    }

    CollectBaseProps(_obj) {
        out_str := ""
        _prop_names := []
        for _prop_name in ObjOwnProps(_obj and ObjGetBase(_obj) or {})
            _prop_names.Push _prop_name
        if not _prop_names.Length
            return ""
        if EvalPastMax()
            return EvalIndent() "Props[Base][" _prop_names.Length "]...`n"
        out_str .= EvalIndent() "Props[Base]:`n"
        for _prop_name in _prop_names {
            if EvalPastMax() {
                try out_type := type(_obj.%_prop_name%)
                out_type := (out_type ?? false) is string and out_type.sub(1,1).upper() or "_.-=U=-._"
                out_str .= TryStringOut(_prop_name ("@" out_type "@") " ... ")
                return out_str
            }
            propval := false
            try (_obj.%_prop_name%), propval:=_obj.%_prop_name%
            if propval and propval is func and !printfuncs
                continue
            out_str .= EvalIndent() " " _prop_name
            if not propval
                return (out_str .= "?`n", out_str)
            if propval is Primitive {
                nestcharspre := nestchars.CleanClone()
                nestchars := [""]
                out_str .= ":{" type(propval) "}: " (propval) "`n"
                nestchars := nestcharspre
            } else if propval is Func {
                nestcharspre := nestchars.CleanClone()
                nestchars := [""]
                out_str .= ":{" propval.__Class "}[" propval.name "]"
                if verbosity < 3
                    out_str .= ":MN" propval.MinParams ":MX" propval.MaxParams
                            . ":V" propval.IsVariadic ":O" propval.IsOptional()
                            . ":R" propval.IsByRef() "`n"
                nestchars := nestcharspre
            } else {
                nestlvl++
                if EvalPastMax()
                    out_str .= "...`n"
                else out_str .= "`n" TryStringOut(propval)
                nestlvl--
            }
        }
        return out_str
    }

    CollectMapPairs(_obj) {
        out_str := EvalIndent() "K/V Pairs:`n"
        for _key, _value in _obj {
            out_str .= TryStringOut(_key)
            nestlvl++
            out_str .= TryStringOut(_value)
            nestlvl--
        }
        return out_str
    }

    TryEnumOut(_enum) {

    }

    TryFuncOut(_func) {
        out_str := EvalIndent() "{" _func.__Class "}::"
        if verbosity < 3
            return out_str _func.MinParams "," _func.MaxParams "`n"
        out_str .= "`n"
        nestlvl++
        out_str .= TryStringOut( "MinMaxParams:" _func.MinParams "," _func.MaxParams )
        out_str .= TryStringOut( "Variadic:" _func.IsVariadic "`n" )
        nestlvl--
        return out_str
    }

    TryObjectOut(out_item) {
        nestcharspre := nestchars.CleanClone()
        nestchars := ["|", "*"]
        out_str := EvalIndent() "{" out_item.__Class "}::"
        nestchars := nestcharspre
        nestlvl++
        if EvalPastMax(nestlvl)
            return (nestlvl--, out_str "...`n")
        else out_str .= "`n"
        if type(out_item) ~= "[aA]rray" {
            out_str .= EvalIndent() "Items[" out_item.Length "]:`n"
            for itm in out_item
                out_str .= TryStringOut(itm ?? "unset")
        } else if out_item is Map {
            out_str .= CollectMapPairs(out_item)
        }
        out_str .= CollectBaseProps(out_item)
        out_str .= CollectOwnProps(out_item)
        nestlvl--
        return out_str

    }

    for _itm in _objlist {
        nestlvl := 0
        indstr := inddef
        desc .= TryStringOut(_itm)
    }

    return desc
}

/**
 * @param {Array} _olist
 */
dbgo(_olist*) {
    static __dbgo_desc__  := ___DBG___.cfg.desc.clone()
        ,  __dbgo__ := ___DBG___.cfg.dbgo.clone()
        ,  ___ := ___DBG___.parseopts(&__dbgo_desc__, &__dbgo__,false)["opts"]
    if _olist.length and isobject(_olist[1]) and objhasownprop(_olist[1], "__o__")
        uopts := _olist[1]
    else uopts := __dbgo_desc__.clone()
    if ___DBG___.parseopts(&uopts, &__dbgo_desc__, false, true)
        _olist:=_olist.fromrange(has_uopts:=2)

    OutputDebug __DBG__describe(has_uopts ? uopts : __dbgo_desc__, _olist*)
}

dbgln(_olist*) {
    static __dbgln_desc__  := ___DBG___.cfg.desc.clone()
        ,  __dbgln__ := ___DBG___.cfg.dbgln.clone()
        ,  ____ := ___DBG___.parseopts(&__dbgln_desc__, &__dbgln__,false)["opts"]
    has_uopts := false
    if _olist.length and isobject(_olist[1]) and objhasownprop(_olist[1], "__o__") {
        uopts := _olist[1]
        _olist:=_olist.fromrange(has_uopts:=2)
    } else uopts := __dbgln_desc__.clone()
    ___DBG___.parseopts(&uopts, &__dbgln_desc__, false, true)

    uopts := (has_uopts ? uopts : __dbgln_desc__)

    if (!!uopts.opendebugview)
        ___DBG___.bm.opendebugview()
    if (!!uopts.focusdebugview) {
        ___DBG___.bm.activatedebugview()
        if !!uopts.focusprevwin
            settimer(___DBG___.bm.activateprevwin, uopts.focusprevwintimeout.neg())
    }

    loop parse, __DBG__describe(uopts?, _olist*), "`n", "`r"
        OutputDebug A_LoopField
}

/**
 * @param {Array} _olist
 */
stdo(_olist*) {
    static __stdo_desc__  := ___DBG___.cfg.desc.clone()
        ,  __stdo__ := ___DBG___.cfg.stdo.clone()
        ,  _____ := ___DBG___.parseopts(&__stdo_desc__, &__stdo__,false)["opts"]
    if _olist.length and isobject(_olist[1]) and objhasownprop(_olist[1], "__o__")
        uopts := _olist[1]
    else uopts := __stdo_desc__.clone()
    if ___DBG___.parseopts(&uopts, &__stdo_desc__, false, true)
        _olist:=_olist.fromrange(has_uopts:=2)

    FileAppend __DBG__describe(has_uopts ? uopts : __stdo_desc__, _olist*), "*", "utf-8"
}

/**
 * @param {Array} _olist
 */
msgo(_olist*) {
    static __msgo_desc__  := ___DBG___.cfg.desc.clone()
        ,  __msgo__ := ___DBG___.cfg.msgo.clone()
        ,  ______ := ___DBG___.parseopts(&__msgo_desc__, &__msgo__,false)["opts"]
    if _olist.length and isobject(_olist[1]) and objhasownprop(_olist[1], "__o__")
        uopts := _olist[1]
    else uopts := __msgo_desc__.clone()
    if ___DBG___.parseopts(&uopts, &__msgo_desc__, false, true)
        _olist:=_olist.fromrange(has_uopts:=2)

    MsgBox __DBG__describe(has_uopts ? uopts : __msgo_desc__, _olist*)
}


/**
 * Upon initialization of a new instance, the tick frequency is fetched and stored -- so that the
 *      tick count can be divided by it upon retrieval and multiplied by 1000, resulting in
 *      a return value calculated in milliseconds.
 *
 * The counter will not start until *`this.Start()`* is called and will not stop until
 *      *`this.Stop()`* is called, which will return the tick count in ms.
 *
 * Calling *`this.Lap()`* will push the current tick count to *`this._laps[]`*.
 *
 * Lastly, the current tick count can be retrieved at any time using *`this.GetCurrentCounter()`*.
 *      By default, this value is passed through *`this.ToMilliseconds(&ms)`* before being returned,
 *      but you can set *`this.ms`* to ***False*** to change this behaviour.
 */
Class PerfCounter {
    start := 0
    _laps := []
    __New() {
        DllCall "QueryPerformanceFrequency", "Int*", &freq := 0
        this.frequency := freq
        this.ms := True
    }
    StartTimer() {
        this.start := this.GetCurrentCounter()
        this.laps := []
        this.laps.Push(this.start)
    }
    StopTimer() {
        this.end := this.GetCurrentCounter()
        this.laps.Push(this.end)
        Return this.end - this.start
    }
    Lap() {
        this.now := this.GetCurrentCounter()
        this.laps.Push(this.now)
        Return this.now-this.laps[this.laps.Length-1]
    }
    ToMilliseconds(&_p_count) {
        Return _p_count := _p_count / this.frequency * 1000
    }
    GetCurrentCounter() {
        DllCall "QueryPerformanceCounter", "Int*", &counter := 0
        if this.ms
            this.ToMilliseconds(&counter)
        Return counter
    }
}

Class PerformanceCounter {
    _start := 0
    _stop  := 0
    __new(_start_immediately:=true) {
        this.freq := this.__get_frequency__()
        if _start_immediately
            this.setstart()
    }
    setstart() => (this._start := this.now, dbgln(A_LineFile, 
                           "PerformanceCounter::started:: " this._start), this._start)
    setstop() => (this._stop := this.now, dbgln(A_LineFile,
                           "PerformanceCounter::stopped::",
                           "start::`t`t`t" this._start,
                           "stop::`t`t`t`t" this._stop,
                           "elapsed::`t" this.elapsed["min"]), this._stop)
    elapsed[_tscale:="raw"] => (this._stop - this._start) * this.__calc_counter_mul__(_tscale)
    now[_tscale:="raw"] => this.__get_counter__() * this.__calc_counter_mul__(_tscale)
    delta[_tscale:="raw"] => (this.now - this._start) * this.__calc_counter_mul__(_tscale)
    __calc_counter_mul__(_tscale:="raw") => ( (_tscale ~= "m[ls]") ? (1 / this.freq) * (1000) :
                                              (_tscale ~= "se?c?") ? (1 / this.freq) * (1000/1000**1) :
                                              (_tscale ~= "mi?n?") ? (1 / this.freq) * (1000/1000**2) :
                                              (_tscale ~= "h[r]?") ? (1 / this.freq) * (1000/1000**3) : 1 )
    __get_frequency__() => (dllcall("QueryPerformanceFrequency", "int*", &freq := 0), freq)
    __get_counter__() {
        dllcall "QueryPerformanceCounter", "int*", &counter := 0
        return counter
    }
}
