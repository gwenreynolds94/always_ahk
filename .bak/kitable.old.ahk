; kitable.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include bultins_extended.ahk

class kitable extends Map {
    _enabled      := false
    oneshot       := false
    global_hotif  := false
    bf_on_timeout := false
    timeout       := 0
    kimap         := Map()

    __new(_hotkey_map?, _hotif:=false, _oneshot:=false, _timeout:=0) {
        this.timeout        := _timeout
        this.global_hotif   := _hotif
        this.oneshot        := _oneshot
        this.bf_on_timeout  := ObjBindMethod(this, "on_timeout")
        this.bf_enable      := ObjBindMethod(this, "_enable")
        this.bf_disable     := ObjBindMethod(this, "_disable")
        if IsSet(_hotkey_map)
            this.add_from_map _hotkey_map
    }

    add_from_map(_hotkey_map) {
        if not (_hotkey_map is Map)
            throw Error("{_hotkey_map} MUST be of a {Map} type")
        for _hkstr, _hkacts in _hotkey_map
            ; decide whether to use bind or bindpath
            this.bind(_hkstr, _hkacts, this.global_hotif, this.oneshot, this.timeout)
    }

    enabled {
        get => this._enabled
        set {
            if !!Value and !this._enabled
                this._enable
            else if !Value and !!this._enabled
                this._disable
        }
    }

    _enable(*) {
        if this.enabled
            return
        bf_on_timeout := this.bf_on_timeout
        for _ki, _bind in this
            _bind.enabled := true
        if this.timeout
            SetTimer bf_on_timeout, (-1) * Abs(this.timeout)
        this._enabled := true
        ostr := ""
        for _ki, _bind in this
            ostr .= _ki "`n"
        tooltip ostr
    }

    _disable(*) {
        if not this.enabled
            return
        for _ki, _bind in this
            _bind.enabled := false
        this._enabled := false
    }

    toggle(*) {
        this.enabled := !this.enabled
    }

    on_timeout(*) {
        this.enabled := false
    }

    bind(_ki, _actions, _hotif:=false, _oneshot:=false, _timeout:=0) {
        bf_on_timeout := this.bf_on_timeout
        _hotif   := !!_hotif   ? _hotif   : this.global_hotif
        _timeout := !!_timeout ? _timeout : this.timeout
        _oneshot := !!_oneshot ? _oneshot : this.oneshot
        _actions := !!(_actions is array) ? (_actions) : ([_actions])
        if !this.Has(_ki) {
            this.kimap[_ki] := _actions
            this[_ki] := kibind(_ki, _actions, _hotif, _oneshot, _timeout)
            if _oneshot
                this[_ki].actions.callback := ((*)=>bf_on_timeout())
        } else {
            this.kimap[_ki].push(_actions*)
            this[_ki].actions.add_actions(_actions)
        }
    }

    /**
     * @param {array} _kipath
     * @param {array|any} _actions
     * @param {integer} [_hotif=false]
     * @param {integer} [_timeout=2250]
     */
    bindpath(_kipath, _actions, _hotif:=false, _timeout:=2250) {
        bf_on_timeout := this.bf_on_timeout
        bf_enable := this.bf_enable
        bf_disable := this.bf_disable
        _hotif   := !!_hotif   ? _hotif   : this.global_hotif
        _timeout := !!_timeout ? _timeout : this.timeout
        _actions := !!(_actions is array) ? (_actions) : ([_actions])
        kpath := _kipath, kplen := kpath.Length
        ktbls :=  [this], kmaps := [this.kimap]
        if kplen > 1 {
            for _ki in kpath {
                curmap := kmaps[kmaps.Length]
                curtbl := ktbls[ktbls.Length]
                ;;;;; something is messed up here i can feel it ;;;;;
                if !curmap.Has(_ki) {
                    newtbl := kitable(unset, _hotif, true, _timeout)
                    bf_curtbl_enable := newtbl.bf_enable
                    bf_curtbl_disable := newtbl.bf_disable
                    newtbl[_ki] := kibind(_ki, ((*)=>bf_newtbl_enable()), _hotif, true, _timeout)
                    curmap[_ki] := newtbl[_ki].raw_actions
                    newtbl[_ki].actions.callback := ((*)=>bf_newtbl_disable())
                    curtbl[_ki] := newtbl
                } else {
                    curtbl[_ki].actions.add_actions(curtbl[_ki].raw_actions)
                    curmap[_ki] := curtbl[_ki].raw_actions
                }
                ktbls.push curtbl[_ki]
                kmaps.push curmap[_ki]
            } until (A_Index+1) >= kplen
        }

        lasttbl := ktbls[ktbls.Length]
        lastmap := kmaps[kmaps.Length]
        if !lastmap.Has(kpath[kplen])
            lasttbl
        else {
            lasttbl.bind(kpath[kplen], _actions, _hotif, true, _timeout)
        }
    }

    unbind(_ki) {
        if this.kimap[_ki] is kibind
            this[_ki].enabled := false
        else if this.kimap[_ki] is kitable
            this[_ki].enabled := false
        this.Delete(_ki)
        this.kimap.Delete(_ki)
    }

}

class kilead {
    leader   := ""
    _enabled := false
    hotexpr  := false
    ktbl     := false
    timeout  := 0

    __new(_leader:="LAlt & RAlt", _hotif:=false, _timeout:=2250) {
        this.leader := _leader
        this.hotexpr := _hotif
        this.timeout := _timeout
        this.ktbl := kitable(unset, false, true, _timeout)
    }

    bind => this.ktbl.bind

    bindpath => this.ktbl.bindpath

    enabled {
        get => this._enabled
        set {
            if !!Value and !this._enabled
                this._enable()
            else if !Value and !!this._enabled
                this._disable()
        }
    }

    _enable(*) {
        this._enabled := true
        if !!this.hotexpr
            HotIf(this.hotexpr)
        Hotkey this.leader, this, "On"
        if !!this.hotexpr
            HotIf()
    }

    _disable(*) {
        this._enabled := false
        if !!this.hotexpr
            HotIf(this.hotexpr)
        Hotkey this.leader, "Off"
        if !!this.hotexpr
            HotIf()
    }

    call(*) {
        this.ktbl.enabled := true
    }
}

class kibind {

    class action_cluster extends Array {

        class node {
            action := false

            __new(_action) {
                this.action := _action
                if not ((_action is closure) or (_action is func)  or
                        (_action is string)  or (_action is kitable))
                    throw ValueError("[_action] MUST be a string, function, closure[, or kitable?]")
            }

            call(*) {
                if (this.action is String)
                    Send(this.action)
                else if (this.action is Func)
                    this.action()
                else if (this.action is kitable)
                    this.action.enabled := true
            }
        }

        callback := false

        __new(_actions, _callback?) {
            this.add_actions _actions
            this.callback := _callback ?? false
        }

        call(*) {
            for _action in this
                _action()
            if this.callback
                this.callback()
        }

        add_actions(_actions) {
            if not (_actions is array)
                _actions := [_actions]
            for _action in _actions
                this.push kibind.action_cluster.node(_action)
        }
        ; __index[] {}
    }

                 ki := false
    ,      _actions := false
    ,   raw_actions := false
    ,      _enabled := false
    ,       hotexpr := false
    ,       oneshot := false
    ,  prev_hotexpr := false
    , bf_disable := false
    ,       timeout := 0
    
    __new(_ki, _actions?, _hotif:=false, _oneshot:=false, _timeout:=0) {
        this.bf_disable := ObjBindMethod(this, "_disable")
        this.ki := _ki
        if IsSet(_actions)
            this.actions := _actions
        this.hotexpr := _hotif
        this.oneshot := _oneshot
        ; may need to stop inheriting timeout
        ; this.timeout := _timeout
    }

    actions {
        get => this._actions
        set => this._actions := kibind.action_cluster((this.raw_actions:=Value))
    }

    enabled {
        get => this._enabled
        set {
            if !!Value and !this._enabled
                this._enable()
            else if !Value and !!this._enabled
                this._disable()
        }
    }

    _enable() {
        this._enabled := true
        bf_disable := this.bf_disable
        if !!this.hotexpr
            HotIf(this.hotexpr)
        Hotkey this.ki, this, "On"
        if !!this.hotexpr
            HotIf()
        this.prev_hotexpr := this.hotexpr
        if this.timeout
            SetTimer bf_disable, (-1) * Abs(this.timeout)
    }

    _disable() {
        this._enabled := false
        if !!this.prev_hotexpr
            HotIf this.prev_hotexpr
        Hotkey this.ki, "Off"
        if !!this.prev_hotexpr
            HotIf()
    }

    call(*) {
        this.actions()
    }
}

ntbl := kitable(unset, false, true, 2250)
ntbl.bindpath(["a", "b"], ((*)=>MsgBox("YAYYYY")), false)

#6:: {
    ntbl.enabled := true
}
