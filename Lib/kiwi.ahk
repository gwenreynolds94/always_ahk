; kiwi.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

class kiwi {
   static previd := 0
        , activekis := map()
        , all := map()
    id := 0,
    timeout := 0,
    hotifexpr := 0,
    oneshot := 0,
    child_timeout := 0
    _enabler_key_ := ""

    __new(_timeout:=false, _hotifexpr:=false, _enabler_key:="", _oneshot:=false, _child_timeout:=false) {
        this.id := ++kiwi.previd
        this.timeout := _timeout
        this.hotifexpr := _hotifexpr
        this.oneshot := _oneshot
        this.child_timeout := _child_timeout
        this.enablerkey := _enabler_key
        kiwi.all[this.id] := this
    }

    class key {
        static previd := 0
        kiwid := 0
        id := 0
        name := ""
        aktions := kiwi.keyaktions()
        hotif := false
        _active_ := false
        _inqueue_ := false
        __new(_name, _kiwid, _hotif?) {
            this.name := _name
            this.kiwid := _kiwid
            this.id := ++kiwi.key.previd
            if !!(_hotif ?? false)
                this.hotif := (_hotif is kiwi.keyhotif) ? _hotif : kiwi.keyhotif(_hotif)
            if !kiwi.activekis.has(this.name)
                kiwi.activekis[this.name] := map()
        }
        activate(*) {
            if !this.activeki.has(!!this.hotif and this.hotif.id)
                this.activeki[!!this.hotif and this.hotif.id] := []
            loop this.activehotif.length
                if this.activehotif[A_Index].id = this.id {
                    this.activehotif.RemoveAt(A_Index)
                    break
                }
            this.activehotif.push this

            if this.activehotif.length > 1
                this.activehotif[this.activehotif.length - 1].queue()
            hashotif := !kiwi.activekis[this.name].has(!this.hotif ? false : this.hotif.id)
            if !!hashotif
                kiwi.activekis[this.name][this.hotif.id] := [this]
            else {

            }
                for _ki in kiwi.activekis[this.name][this.hotif.id]
                    if (!_ki.hotif.id and !this.hotif.id) or _ki.hotif.id = this.hotif.id
        }
        deactivate(*) {
            ; see if in queue
            loop this.activehotif.length
                if this.activehotif[A_Index].id = this.id
                    this.activehotif.RemoveAt(A_Index)
            if this.activehotif.length

            loop kiwi.activekis[this.name][this.hotif.id]
            kiwi.activekis[this.name][this.hotif.id]
            
        }
        queue(*) {
            this.deactivate()
            this._inqueue_ := true
        }
        activeki => kiwi.activekis[this.name]
        activehotif => kiwi.activekis[this.name][!!this.hotif and this.hotif.id]
    }

    class keyaktions extends array {
        static previd := 0
        _return_results_ := false
        bm := { _call_ : objbindmethod(this, "_call_") }
        call => this.bm._call_
        id := 0
        _call_(_args*) {
            retvals := []
            for _aktion in this
                if _aktion is primitive
                    send(_aktion)
                else try retvals.push(_aktion())
            if !!this._return_results_
                return retvals
        }
        __new(_aktions*) {
            this.id := ++kiwi.keyaktions.previd
            super.__new(_aktions*)
        }
    }

    class keyhotif extends array {
        static previd := 0
        operand := "and"
        bm := { _call_ : objbindmethod(this, "_call_") }
        call => this.bm._call_
        id := 0
        _call_(_args*) {
            ishot := !!(this.operand = "and")
            for _aktion in this
                ishot := !!(this.operand = "and") ? (ishot and !!_aktion(_args*)) : (ishot or !!_aktion(_args*))
            return ishot
        }
        __new(_funcs*) {
            this.id := ++kiwi.keyhotif.previd
            super.__new(_funcs*)
        }
    }

    class _kache_ extends map {
        static active_keys := map()
    }
}

; kakts := kiwi.keyaktions((*)=>(Msgbox("A")), (*)=>(Msgbox("B")), (*)=>(Msgbox("C")), "{LWin}")

