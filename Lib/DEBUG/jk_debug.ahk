; jk_debug.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include ..\bultins_extended.ahk

__DBG__describe(_objlist*) {
    if not _objlist.Length
        return
    desc := ""
    nestlvl := 0
    lvlchars := ["|", "_"]
    indstr := inddef := " " lvlchars[1] " "

    EvalIndent() {
        ind := ""
        loop nestlvl
            ind .= " " lvlchars[Mod(A_Index + lvlchars.Length - 1, lvlchars.Length) + 1] " "
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
        for _prop_name in ObjOwnProps(_obj)
            _prop_names.Push _prop_name
        if not _prop_names.Length
            return ""
        out_str .= EvalIndent() "Props[Prototype]:`n"
        for _prop_name in _prop_names {
            out_str .= TryStringOut(_prop_name)
            nestlvl++
            out_str  .= TryStringOut(_obj.%_prop_name%)
            nestlvl--
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
            out_str .= TryStringOut(_prop_name)
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

    TryObjectOut(out_item) {
        ind_pre := indstr
        indstr := '-|-'
        out_str := EvalIndent() "{" out_item.__Class "}::`n"
        indstr := ind_pre
        nestlvl++
        if out_item is Array {
            out_str .= EvalIndent() "Items[" out_item.Length "]:`n"
            for itm in out_item
                out_str .= TryStringOut(itm)
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
    OutputDebug __DBG__describe(_olist*)
}

dbgln(_olist*) {
    loop parse, __DBG__describe(_olist*), "`n", "`r" {
        OutputDebug A_LoopField
    }
}

/**
 * @param {Array} _olist
 */
stdo(_olist*) {
    FileAppend __DBG__describe(_olist*), "*", "utf-8"
}

/**
 * @param {Array} _olist
 */
msgout(_olist*) {
    MsgBox __DBG__describe(_olist*)
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
