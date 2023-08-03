#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include builtins_extended.ahk

class kitable extends map {

    static previd := 0

    bm := {
        enable: {},
        disable: {},
        toggle: {},
        funcwrapr: {},
        ontimeout: {},
        fflinkki: objbindmethod(this, "linkki", unset, unset, "firefox.exe")
    },

    _enabled := false,
    timeout := false,
    child_timeout := false,
    child_oneshot := false,
    oneshot := false,
    prevhotif := false,
    _hotifexpr := false,
    hotifmap := Map()
    allkis := Map(),
    kimap := Map(),
    kimaplvl := 1,
    id := 0

    /**
     * @param {String|Integer|Number} [_timeout=2000]
     */
    __New(_timeout:=0, _oneshot:=false, _child_timeout:=2250, _child_oneshot:=false, _hotifexpr:=false) {
        this.timeout := _timeout
        this.child_timeout := _child_timeout
        this.oneshot := _oneshot
        this.child_oneshot := _child_oneshot
        this.hotifexpr := _hotifexpr or this.hotifexpr
        this.id := kitable.previd++
        this.bm.enable := ObjBindMethod(this, "enable")
        this.bm.disable := ObjBindMethod(this, "disable")
        this.bm.toggle := ObjBindMethod(this, "toggle")
        this.bm.funcwrapr := ObjBindMethod(this, "funcwrapr")
        this.bm.ontimeout := ObjBindMethod(this, "ontimeout")
    }

    hotifexpr[_applytochildren:=true] {
        get => this._hotifexpr
        set {
            this._hotifexpr := value
            if _applytochildren
                for _key, _itm in this
                    if _itm is kitable
                        _itm.hotifexpr := value
        }
    }

    enabled {
        get => this._enabled
        set => (!!Value ? (this.enable()) : (this.disable()))
    }

    enable(*) {
        kidisable := this.bm.disable
        funcwrapr := this.bm.funcwrapr
        hotifexpr := this.hotifexpr
        if !!hotifexpr
            hotif(this.prevhotif := (_args*)=>(!!this._enabled and !!hotifexpr(_args*)))
        for _key, _action in this {
            fnwrapr := funcwrapr.bind(_action is kitable ? _action.bm.enable  : _action)
            hotkey _key, fnwrapr.bind(this.oneshot) , "On"
        }
        hotif()
        if this.timeout
            SetTimer kidisable, ((-1) * abs(this.timeout))
        return (this._enabled := true)
    }

    disable(*) {
        if !this._enabled
            return false
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

    toggle(*) {
        this.enabled := !this._enabled
    }

    funcwrapr(_actions, _disable:=false, *) {
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

    /**
     * @param {string} _ki
     * @param {array|func|string} _actions
     */
    hotki(_ki, _actions, *) {
        funcwrapr := this.bm.funcwrapr
        _actions := (_actions is array) ? (_actions) : ([_actions])
        this[_ki] := funcwrapr.bind(_actions, this.oneshot)
    }

    dblki(_ki, _actions, _timeout, _timeout_action, *) {
        static kis := map()
        funcwrapr := this.bm.funcwrapr
        kis[_ki] := { k: _ki      ,    a: funcwrapr.bind(_actions,false)
                   ,  t: _timeout ,   ta: funcwrapr.bind(_timeout_action,false)
                   , ot: false    , trig: 0 }
        onkipress(&_kismap, _kistr, *) {
            ontimeout(&__kismap, __kistr, *) {
                _kiobj := __kismap[__kistr]
                if _kiobj.trig = 1
                    _kiobj.ta()
                _kiobj.trig := 0
                settimer(,0)
            }
            kiobj := _kismap[_kistr]
            if not kiobj.ot
                kiobj.ot := ontimeout.bind(&_kismap, _kistr)
            if ++kiobj.trig > 1
                settimer(kiobj.ot, kiobj.trig:=0), kiobj.a()
            else settimer(kiobj.ot, kiobj.t.neg())
        }
        this[_ki] := funcwrapr.bind(onkipress.bind(&kis, _ki), this.oneshot)
    }

    pathki(_kipath, _actions, *) {
        enablemeth := this.bm.enable
        _actions := (_actions is array) ? _actions : [_actions]
        kipath := (_kipath is array) ? _kipath : [_kipath]
        kplen := kipath.Length
        tblpath := [this]
        if kplen > 1 {
            for _ki in kipath {
                tblmap := tblpath[tblpath.Length]
                if !tblmap.Has(_ki)
                    tblmap[_ki] := kitable( this.child_timeout, true, 
                        this.child_timeout, this.child_oneshot, this.hotifexpr )
                tblpath.push tblmap[_ki]
            } until (A_Index+1) >= kplen
        }
        trigtbl := tblpath[tblpath.Length]
        if not this.oneshot
            _actions.push enablemeth
        trigtbl.hotki(kipath[kplen], _actions)
    }

    progki(_kipath, _progpath, _relative_to:=true, *) {
        static _prev_relative_to:=""
        _relative_to := _relative_to is string ?
             (_prev_relative_to:=_relative_to) :
                             _prev_relative_to
        this.pathki(_kipath, (*)=>(run(_relative_to _progpath)))
    }

    linkki(_kipath, _linkaddr, _browser:="firefox.exe", *) =>
        this.pathki(_kipath, (*)=>(run(_browser " " _linkaddr)))

    fflinkki(_kipath, _linkaddr, *) => this.linkki(_kipath, _linkaddr, "firefox.exe")

    class kache extends map {
        oneshot := false
        actions := false
        parent  := false
        root    := false
    }
}

class kileader extends kitable {
    /**
     * @prop {string} leader
     */
    leader := ""
    _leader := ""
    /**
     * @prop {kitable} root
     */
    root := ""
    _root := ""


    __new(_leader:="LAlt & RALt", _parent_timeout:=0, _oneshot:=false,
          _child_timeout:=2250, _child_oneshot:=false, _hotifexpr:=false) {
        super.__new(_parent_timeout, _oneshot, _child_timeout, _child_oneshot, _hotifexpr)
        this.leader := _leader
        this[this.leader] := this.root
    }
    root {
        get {
            if !this._root {
                _root := kitable( this.child_timeout, this.child_oneshot,
                                  this.child_timeout, this.child_oneshot, this.hotifexpr )
                if this.has(this._leader)
                    _root := this[this._leader]
            } else _root := this._root
            this._root := _root
            return this._root
        }
        set => this._root := value
    }

    hotki(_ki, _actions, *) {
        this.root.hotki(_ki, _actions)
    }

    pathki(_kipath, _actions, *) {
        this.root.pathki(_kipath, _actions)
    }

    progki(_kipath, _progpath, _relative_to:=true, *) {
        this.root.progki(_kipath, _progpath, _relative_to)
    }
}



