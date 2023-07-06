#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include DEBUG\jk_debug.ahk
#Include bultins_extended.ahk


class kitable extends map {

    static kid := 0
         , 

    bm := {
        enable: {},
        disable: {},
        toggle: {},
        ontrigger: {},
        ontimeout: {}
    },

    __enabled__ := false,
    timeout := false,
    child_timeout := false,
    oneshot := false,
    prevhotif := false,
    hotifexpr := false,
    kimap := Map(),
    kimaplvl := 1,
    token := 0,
    starttimeout := false,
    stoptimeout := false,
    activebinds := map()

    /**
     * @param {String|Integer|Number} [_timeout=2000]
     */
    __New(_timeout:=0, _oneshot:=false, _child_timeout:=2250, _hotifexpr:=false) {
        this.timeout := _timeout
        this.child_timeout := _child_timeout
        this.oneshot := _oneshot
        this.hotifexpr := _hotifexpr
        this.token := kitable.kid++
        this.bm.enable := ObjBindMethod(this, "enable")
        bmdisable := this.bm.disable := ObjBindMethod(this, "disable")
        this.bm.toggle := ObjBindMethod(this, "toggle")
        this.bm.ontrigger := ObjBindMethod(this, "ontrigger")
        this.bm.ontimeout := ObjBindMethod(this, "ontimeout")
        this.starttimeout := (_to:=0, *)=>(settimer(bmdisable, _to and _to.neg()))
        this.stoptimeout := (*)=>(settimer(bmdisable,0))
    }

    enabled {
        get => this.__enabled__
        set => (!!Value ? (this.enable()) : (this.disable()))
    }

    enable(*) {
        dbgln("TRIGGERED;;;kitable[ " this.token " ]enable()")
        for _key, _action in this {
            if !this.activebinds.has(_action.token)
                if _action is kitable
                    this.activebinds[_action.token] := kitable.kibind(_key, _action, this.activebinds[_action.token].timeout, this.hotifexpr)
                else this.activebinds[_action.token] := _action
            this.activebinds[_action.token].enable()
        }
        if this.timeout
            this.starttimeout()
        return (this.__enabled__ := true)
    }

    disable(*) {
        dbgln("TRIGGERED;;;kitable[ " this.token " ]disable()")
        if this.timeout
            this.stoptimeout()
        for _ki, _action in this {
            this.activebinds[_action.token].disable()
        }
        return (this.__enabled__ := false)
    }

    toggle(*) {
        this.enabled := !this.__enabled__
    }

    ontrigger(_actions, _disable:=false, *) {
        dbgln("TRIGGERED;;;kitable[ " this.token " ]ontrigger(_actions, _disable)", _actions, _disable)
        _actions := (_actions is array) ? _actions : [_actions]

        kidisable := this.bm.disable
        if _disable {
            kidisable()
        }

        for _action in _actions {
            if (_action is func)
                _action()
            else if (_action is string)
                send(_action)
        }
    }

    ontimeout(_actions, *) {
        ontrigger := this.bm.ontrigger
    }

    hotki(_ki, _actions, _timeout?, _hotifexpr?, *) {
        dbgln("TRIGGERED;;;kitable[ " this.token " ]hotki( " _ki " )")
        _timeout := _timeout ?? this.timeout
        _hotifexpr := _hotifexpr ?? this.hotifexpr
        this[_ki] := kitable.kibind(_ki, _actions, _timeout, _hotifexpr)
        if this.oneshot
            this[_ki].push this.bm.disable
    }

    pathki(_kipath, _actions, _timeout?, _childtimeout?, *) {
        dbgln("TRIGGERED;;;kitable[ " this.token " ]pathki()")
        enablemeth := this.bm.enable
        _timeout := _timeout ?? this.timeout
        _childtimeout := _childtimeout ?? this.child_timeout
        _actions := (_actions is array) ? _actions : [_actions]
        kipath := (_kipath is array) ? _kipath : [_kipath]
        kplen := kipath.Length
        tblpath := [this]
        if kplen > 1 {
            for _ki in kipath {
                tblmap := tblpath[tblpath.Length]
                if !tblmap.Has(_ki)
                    tblmap[_ki] := kitable(_childtimeout, true, _childtimeout)
                tblpath.push tblmap[_ki]
            } until (A_Index+1) >= kplen
        }
        trigtbl := tblpath[tblpath.Length]
        trigtbl[_kipath[_kipath.length]] := kitable.kibind(_kipath[_kipath.length], _actions, _childtimeout,,, this)
    }

    progki(_ki, _progpath, _relative_to:=true, *) {
        static _prev_relative_to:=""
        _relative_to := _relative_to is string ?
             (_prev_relative_to:=_relative_to) :
                             _prev_relative_to
        action := (*)=>(run(_relative_to _progpath))
        this.hotki(_ki, action)
    }

    class kibind extends array {
        bm := {
            enable: ((*)=>()),
            disable: ((*)=>())
        }
        
        ki := false
        action := false
        oneshot := false
        ondisable := false
        timeout := 0
        hotifexpr := false
        prevhotifexpr := false
        token := false
        root := false

        __new(_ki, _actions, _timeout:=0, _hotifexpr:=false, _ondisable:=false, _root:=false) {
            this.ki := _ki, this.action := _actions
            this.timeout := _timeout
            this.root := _root
            this.hotifexpr := _hotifexpr, this.ondisable := _ondisable
            this.token := ++kitable.kid
            this.bm.enable := objbindmethod(this, "enable")
            this.bm.disable := objbindmethod(this, "disable")
            for _action in (_actions is array and _actions or [_actions])
                this.push(_action)
        }

        enable(*) {
            if this.hotifexpr
                hotif(this.prevhotifexpr:=this.hotifexpr)
            
            hotkey this.ki, this, "on"

            if this.hotifexpr
                hotif()
        }

        disable(*) {
            if this.prevhotifexpr
                hotif(this.prevhotifexpr)
            
            hotkey this.ki, "off"

            if this.prevhotifexpr
                hotif()

            if this.ondisable
                this.ondisable()
        }

        do_action(_action) {
            if _action is func or _action is kitable.kibind
                _action()
            else if _action is kitable
                _action.enable()
            else if _action is string
                send(_action)
        }

        call(*) {
            for _action in this
                this.do_action(_action)
            if this.root and this.root.oneshot
                this.root.disable()
            else if this.root
                this.root.enable()
        }
    }
}

class kileader extends kitable {
    leader := ""
    root := {}

    __new(_leader:="LAlt & RALt", _parent_timeout:=0, _oneshot:=false, _child_timeout:=2250, _hotifexpr:=false) {
        super.__new(_parent_timeout, _oneshot, _child_timeout, _hotifexpr)
        this.leader := _leader
        this.root := this[this.leader] := kitable(this.child_timeout, true)
    }

    hotki(_ki, _actions, *) {
        dbgln("TRIGGERED;;;kileader[ " this.token ", " this.leader " ]hotki( " _ki " )")
        this.root.hotki(_ki, _actions)
    }

    pathki(_kipath, _actions, *) {
        dbgln("TRIGGERED;;;kileader[ " this.token ", " this.leader " ]pathki()")
        this.root.pathki(_kipath, _actions)
    }
}



