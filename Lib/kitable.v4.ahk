; keymap.v4.ahk

#Requires AutoHotkey v2.0
#Warn All, OutputDebug
#SingleInstance Force


#Include DEBUG\jk_debug.ahk
#Include builtins_extended.ahk


class keymap extends map {

    static previd := 0

    bm := {
        enable: {},
        disable: {},
        toggle: {},
        funcwrapr: {},
        ontimeout: {},
    },

    _enabled := false,
    timeout := false,
    child_timeout := false,
    oneshot := false,
    prevhotif := false,
    hotifexpr := false,
    keybinds := Map(),
    id := 0

    /**
     * @param {String|Integer|Number} [_timeout=2000]
     */
    __New(_timeout:=0, _oneshot:=false, _child_timeout:=2250, _hotifexpr:=false) {
        this.timeout := _timeout
        this.child_timeout := _child_timeout
        this.oneshot := _oneshot
        this.hotifexpr := _hotifexpr
        this.id := keymap.previd++
        this.bm.enable := ObjBindMethod(this, "enable")
        this.bm.disable := ObjBindMethod(this, "disable")
        this.bm.toggle := ObjBindMethod(this, "toggle")
        this.bm.funcwrapr := ObjBindMethod(this, "funcwrapr")
        this.bm.ontimeout := ObjBindMethod(this, "ontimeout")
    }

    enabled {
        get => this._enabled
        set => (!!Value ? (this.enable()) : (this.disable()))
    }

    enable(*) {
        dbgln("TRIGGERED;;;keymap[ " this.id " ]enable()")
        kidisable := this.bm.disable
        funcwrapr := this.bm.funcwrapr
        ; hotifexpr := (_hotifexpr is func) ? _hotifexpr : this.hotifexpr
        hotifexpr := this.hotifexpr
        if !!hotifexpr
            hotif((this.prevhotif:=hotifexpr))
        for _key, _action in this {
            use_action := (_action is keymap) ?
                funcwrapr.bind(_action.bm.enable.bind(hotifexpr), this.oneshot) : funcarray(_action)
            Hotkey _key, use_action, "On"
        }
        if !!hotifexpr
            hotif()
        if this.timeout
            SetTimer kidisable, ((-1) * abs(this.timeout))
        return (this._enabled := true)
    }

    disable(*) {
        dbgln("TRIGGERED;;;keymap[ " this.id " ]disable()")
        kidisable := this.bm.disable
        SetTimer(kidisable,0)
        hotifexpr := this.prevhotif
        if !!hotifexpr
            hotif(hotifexpr)
        for _ki, _action in this
            Hotkey _ki, "Off"
        if !!hotifexpr
            hotif()
        return (this._enabled := false)
    }

    funcwrapr(_actions, _disable:=false, *) {
        dbgln("TRIGGERED;;;keymap[ " this.id " ]funcwrapr(_actions, _disable)", _actions, _disable)
        _actions := (_actions is array) ? _actions : [_actions]
        if _disable
            this.bm.disable()
        for _action in _actions
            if (_action is func)
                _action()
            else if (_action is string)
                send(_action)
    }

    ontimeout(_actions, *) {
        funcwrapr := this.bm.funcwrapr
    }

    pathki(_kipath, _actions, *) {
        dbgln("TRIGGERED;;;keymap[ " this.id " ]pathki()")
        enablemeth := this.bm.enable
        _actions := (_actions is array) ? _actions : [_actions]
        kipath := (_kipath is array) ? _kipath : [_kipath]
        kplen := kipath.Length
        tblpath := [this]
        if kplen > 1 {
            for _ki in kipath {
                tblmap := tblpath[tblpath.Length]
                if !tblmap.Has(_ki)
                    tblmap[_ki] := keymap(this.child_timeout, true)
                tblpath.push tblmap[_ki]
            } until (A_Index+1) >= kplen
        }
        trigtbl := tblpath[tblpath.Length]
        if not this.oneshot
            _actions.push enablemeth
        trigtbl.hotki(kipath[kplen], _actions)
    }

    class binding extends funcarray {
        
    }
}


class kileader extends keymap {
    leader := ""
    root := {}

    __new(_leader:="LAlt & RALt", _parent_timeout:=0, _oneshot:=false, _child_timeout:=2250, _hotifexpr:=false) {
        super.__new(_parent_timeout, _oneshot, _child_timeout, _hotifexpr)
        this.leader := _leader
        this.root := this[this.leader] := keymap(this.child_timeout, true)
    }

    hotki(_ki, _actions, *) {
        dbgln("TRIGGERED;;;kileader[ " this.id ", " this.leader " ]hotki( " _ki " )")
        this.root.hotki(_ki, _actions)
    }

    pathki(_kipath, _actions, *) {
        dbgln("TRIGGERED;;;kileader[ " this.id ", " this.leader " ]pathki()")
        this.root.pathki(_kipath, _actions)
    }

    progki(_kipath, _progpath, _relative_to:=true, *) {
        dbgln("TRIGGERED;;;kileader[ " this.id ", " this.leader " ]progki()")
        this.root.progki(_kipath, _progpath, _relative_to)
    }
}



