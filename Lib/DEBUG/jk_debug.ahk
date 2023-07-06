; jk_debug.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include ..\bultins_extended.ahk
#Include ..\quiktip.ahk

class ___DBG___ {
    static cfg := {
        desc: {
            nestlvlmax: 6,
            nestchars: ["|", ":"],
            verbosity: 2,
            printfuncs: false
        },
        dbgo: {
            focusdebugview: true,
            opendebugview: true
        },
        dbgln: {
            focusdebugview: false,
            opendebugview: false
        },
        msgo: {
            focusdebugview: true,
            opendebugview: true
        },
        stdo: {
            focusdebugview: true,
            opendebugview: true
        }
    }, bm := {
         opendebugview : objbindmethod(this, "opendebugview"),
        focusdebugview : objbindmethod(this, "focusdebugview")
    }

    static parseopts(_opts, &_cfg) {
        if not _opts is Object
            return
    }

    static opendebugview(*) {
        static _exe_path := "C:\Users\" A_UserName "\Portables\sysinternals\DebugView\dbgview64.exe"
        if not winexist("ahk_exe dbgview64.exe") {
            run _exe_path,,, &_dbgview_pid:=0
            winwait "ahk_pid " _dbgview_pid
        } settimer((*)=>(winactivate("ahk_exe dbgview64.exe")), (500).neg())
    }

    static focusdebugview(*) {
        if winexist("ahk_exe dbgview64.exe")
            settimer(((*)=>(winactivate()), (500).neg()))
        else quiktray("no instances of dbgview64.exe were found", "always_ahk.DEBUG.jk_debug")
    }
}


__DBG__describe(_opts?, _objlist*) {
    if not _objlist.Length
        return
    desc := ""
    _opts := !!objhasownprop(_opts, "__o__") and !!_opts.__o__ and _opts
    nestlvl := 0
    nestlvlmax := _opts and _opts.nestlvlmax or ___DBG___.cfg.desc.nestlvlmax or 4
    nestchars := _opts and _opts.nestchars or ___DBG___.cfg.desc.nestchars or ["|", "_"]
    indstr := inddef := " " nestchars[1] " "

    EvalIndent() {
        ind := ""
        loop nestlvl
            ind .= " " nestchars[Mod(A_Index + nestchars.Length - 1, nestchars.Length) + 1] " "
        return ind
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
        out_str .= EvalIndent() "Props[Prototype]:`n"
        for _prop_name in _prop_names {
            if nestlvl < nestlvlmax {
                out_str .= TryStringOut(_prop_name ":")
                if ___DBG___.cfg.desc.verbosity >= 1 {
                    nestlvl++
                    try (out_str .= TryStringOut(_obj.%_prop_name%))
                    nestlvl--
                }
            } else out_str .= TryStringOut(_prop_name ": ...")
        }
        return out_str
    }

    CollectBaseProps(_obj) {
        out_str := ""
        _prop_names := []
        for _prop_name in ObjOwnProps(ObjGetBase(_obj))
            _prop_names.Push _prop_name
        if not _prop_names.Length
            return ""
        out_str .= EvalIndent() "Props[Base]:`n"
        for _prop_name in _prop_names {
            if nestlvl < nestlvlmax {
                out_str .= EvalIndent() " " _prop_name
                if ___DBG___.cfg.desc.verbosity >= 2 {
                    propval := false
                    try (_obj.%_prop_name%), propval:=_obj.%_prop_name%
                    if propval {
                        if propval is Primitive {
                            nestcharspre := nestchars.CleanClone()
                            nestchars := [""]
                            out_str .= ":{" type(propval) "}: " (propval) "`n"
                            nestchars := nestcharspre
                        } else if propval is Func {
                            nestcharspre := nestchars.CleanClone()
                            nestchars := [""]
                            out_str .= ":{" propval.__Class "}[" propval.name "]"
                            if ___DBG___.cfg.desc.verbosity < 3
                                out_str .= ":MN" propval.MinParams ":MX" propval.MaxParams 
                                        . ":V" propval.IsVariadic ":O" propval.IsOptional()
                                        . ":R" propval.IsByRef() "`n"
                            nestchars := nestcharspre
                        }
                        else nestlvl++, out_str .= "`n" TryStringOut(propval), nestlvl--
                    } else out_str .= "?`n"
                }
            } else out_str .= TryStringOut(_prop_name ": ...")
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
        if ___DBG___.cfg.desc.verbosity < 3
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
        nestchars := ["=", "-"]
        out_str := EvalIndent() "{" out_item.__Class "}::`n"
        nestchars := nestcharspre
        nestlvl++
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
    OutputDebug __DBG__describe({}, _olist*)
}

dbgln(_olist*) {
    opts := { 
        __prefix__    : false
      , nestlvlmax    : false
      , nestchars     : false
      , focusdebugview: false
      , opendebugview : false
      , __o__       : false 
    }
    if (_olist.length > 1) and ((first_item:=_olist[1]) is Object)
        for _optname in ObjOwnProps(opts)
            if ObjHasOwnProp(first_item, _optname)
                (opts.%_optname% := first_item.%_optname%), ++opts.__o__
    if opts.__o__ and (_olist := _olist.fromrange(2))
        open_view:=(opts.opendebugview and ___DBG___.bm.opendebugview 
                     or opts.focusdebugview and ___DBG___.bm.focusdebugview)
    else open_view:=(___DBG___.cfg.dbgln.opendebugview and ___DBG___.bm.opendebugview 
                      or ___DBG___.cfg.dbgln.focusdebugview and ___DBG___.bm.focusdebugview)
    if open_view
        open_view
    loop parse, __DBG__describe(opts, _olist*), "`n", "`r"
        OutputDebug A_LoopField
}

/**
 * @param {Array} _olist
 */
stdo(_olist*) {
    FileAppend __DBG__describe({}, _olist*), "*", "utf-8"
}

/**
 * @param {Array} _olist
 */
msgo(_olist*) {
    MsgBox __DBG__describe({}, _olist*)
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
