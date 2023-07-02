#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include DEBUG\jk_debug.ahk
#Include bultins_extended.ahk


class kitable {

    methbinds := {
        enable: {},
        disable: {},
        toggle: {},
        ontrigger: {},
        ontimeout: {},
    },
    
    _enabled := false,
    timeout := false,
    child_timeout := false,
    oneshot := false,
    prevhotif := false,
    hotifexpr := false,
    kimap := Map()

    /**
     * @param {String|Integer|Number} [_timeout=2000]
     */
    __New(_timeout:=0, _oneshot:=false, _child_timeout:=2250, _hotifexpr:=false) {
        this.timeout := _timeout
        this.child_timeout := _child_timeout
        this.oneshot := _oneshot
        this.hotifexpr := _hotifexpr
        this.methbinds.enable := ObjBindMethod(this, "enable")
        this.methbinds.disable := ObjBindMethod(this, "disable")
        this.methbinds.toggle := ObjBindMethod(this, "toggle")
        this.methbinds.ontrigger := ObjBindMethod(this, "ontrigger")
        this.methbinds.ontimeout := ObjBindMethod(this, "ontimeout")
    }

    enabled {
        get => this._enabled
        set => (!!Value ? (this.enable()) : (this.disable()))
    }

    enable(*) {
        kidisable := this.methbinds.disable
        ontrigger := this.methbinds.ontrigger
        hotifexpr := this.hotifexpr
        if !!hotifexpr
            hotif((this.prevhotif:=hotifexpr))
        for _key, _action in this.kimap {
            use_action := (_action is kitable) ?
                ontrigger.bind(_action.methbinds.enable, this.oneshot) : _action
            Hotkey _key, use_action, "On"
        }
        if !!hotifexpr
            hotif()
        if this.timeout
            SetTimer kidisable, ((-1) * abs(this.timeout))
        return (this._enabled := true)
    }

    disable(*) {
        kidisable := this.methbinds.disable
        ; try SetTimer(,0)
        hotifexpr := this.prevhotif
        if !!hotifexpr
            hotif(hotifexpr)
        for _ki, _action in this.kimap
            Hotkey _ki, "Off"
        if !!hotifexpr
            hotif()
        return (this._enabled := false)
    }

    toggle(*) {
        this.enabled := !this._enabled
    }

    ontrigger(_actions, _disable:=false, *) {
        _actions := (_actions is array) ? _actions : [_actions]

        kidisable := this.methbinds.disable
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
        ontrigger := this.methbinds.ontrigger
    }

    bind(_key, _actions, *) {
        ontrigger := this.methbinds.ontrigger
        if (_actions is func)
            return (this.kimap[_key] := _actions)
        _actions := (_actions is array) ? (_actions) : ([_actions])
        this.kimap[_key] := ontrigger.bind(_actions, this.oneshot)
    }

    bindpath(_kipath, _actions, *) {
        enablemeth := this.methbinds.enable
        _actions := (_actions is array) ? _actions : [_actions]
        kipath := (_kipath is array) ? _kipath : [_kipath]
        kplen := kipath.Length
        tblpath := [this]
        if kplen > 1 {
            for _ki in kipath {
                tblmap := tblpath[tblpath.Length].kimap
                if !tblmap.Has(_ki)
                    tblmap[_ki] := kitable(this.child_timeout, true)
                tblpath.push tblmap[_ki]
            } until (A_Index+1) >= kplen
        }
        trigtbl := tblpath[tblpath.Length]
        if not this.oneshot
            _actions.push enablemeth
        trigtbl.bind(kipath[kplen], _actions)
    }
}

class kileader extends kitable {
    __new(_parent_timeout:=0, _child_timeout:=2250) {
        super.__new(_parent_timeout, false, _child_timeout)

    }
}

;
;    /**
;     * @prop {Number|Boolean} ParsedTimeout
;     * @param {String|Number|Boolean} _timeout
;     */
;    ParsedTimeout[_timeout?] =>
;      (!IsSet(_timeout) or (_timeout = "unset"))     ? ;
;                       KeyTable.Defaults.timeout     : ;
;                                     (!_timeout)     ? (
;                         (this.timeout = "none") ? 0 : ;
;                                   this.timeout      ) :
;                              (_timeout = "max")     ? ;
;                                 this.maxtimeout     : ;
;                            (_timeout is Number)     ? ;
;                    (_timeout > this.maxtimeout)     ? ;
;                                 this.maxtimeout     : ;
;                            Abs(Round(_timeout)) : 0 ; ;
;
;    RealTimeout[_timeout?] {
;        Get {
;            _timeout := _timeout ?? "unset"
;            switch _timeout {
;                case "none", "unset":
;                    return 0
;                case "max":
;                    return this.maxtimeout
;            }
;            return IsNumber(_timeout) ? _timeout : 0
;        }
;    }
;
;    ; ParsedTimeout2[_timeout?] => this.RealTimeout[_timeout ?? this.timeout ?? unset]
;
;    /**
;     * @param {Number|String|Boolean} [_timeout=False]
;     */
;    Activate(_timeout:=False, *) {
;        bmda := this.boundmeth.deactivate
;        ontrig := this.boundmeth.disableontrigger
;        for _key, _action in this.keys
;            Hotkey( _key, ((_action is KeyTable) ?
;                          ontrig.Bind(_action.boundmeth.activate) :
;                                                 (_action)) , "On")
;        if (_tmoparsed := this.ParsedTimeout[_timeout])
;            SetTimer bmda, (_tmoparsed * (-1))
;        this._active := True
;    }
;
;    /**
;     */
;    Deactivate(*) {
;        bmda := this.boundmeth.deactivate
;        Try SetTimer(, 0)
;        for _key, _action in this.keys
;            Hotkey _key, "Off"
;        this._active := False
;    }
;
;    DisableOnTrigger(_key_action, *) {
;        bmda := this.boundmeth.deactivate
;        bmda()
;        _key_action()
;    }
;
;    /**
;     * @param {String} _key_new
;     * @param {Func|KeyTable} _action_new
;     * @param {Boolean} [_oneshot=False]
;     */
;    MapKey(_key_new, _action_new, _oneshot:=False, *) {
;        ontrig := this.boundmeth.disableontrigger
;        if _oneshot
;            this.keys[_key_new] := ontrig.Bind(_action_new)
;        else this.keys[_key_new] := _action_new
;    }
;
;
;
;    /**
;     * @param {__Array} _kpath
;     * @param {Func} _action
;     * @param {String|Number|Boolean} [_timeout=3000]
;     */
;    MapKeyPath(_kpath, _action, _timeout:=3000) {
;        kp := (_kpath is Array) ? _kpath : [_kpath]
;        kplen := kp.Length
;        ktbls := [this]
;        if kplen > 1 {
;            for _k in kp {
;                curkeys := ktbls[ktbls.Length].keys
;                if !curkeys.Has(_k)
;                    curkeys[_k] := KeyTable(_timeout)
;                ktbls.Push(curkeys[_k])
;            } Until (A_Index+1) >= kplen
;        }
;        ktbls[kplen].MapKey(kp[kplen], _action, True)
;    }
;
;    /** @param {Integer|Boolean} [_timeout=False] */
;    Active[_timeout := False] {
;        Get => this._active
;        Set => (!!Value and !this._active) ? (this.Activate(_timeout)) :
;               (!Value and !!this._active) ? (this.Deactivate()) :  ("")
;    }
;
;    /**
;     * @param {Integer|Boolean} [_timeout]
;     */
;    ToggleKeyPaths(_timeout?, *) {
;        _timeout := this.ParsedTimeout[_timeout ?? this.timeout]
;        this.Active := !this.Active
;    }
;}
;

