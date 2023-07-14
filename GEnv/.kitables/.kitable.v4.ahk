; keymap.v4.ahk

#Requires AutoHotkey v2.0
#Warn All, OutputDebug
#SingleInstance Force


#Include DEBUG\jk_debug.ahk
#Include builtins_extended.ahk


class keymap extends map {

    static previd := 0
        ,  allmaps := Map()

    bm := {
        enable: {},
        disable: {},
        toggle: {},
        funcwrapr: {},
        ontimeout: {},
    },

    child_timeout := false,
    timeout := false,
    oneshot := false,
    keybinds := Map(),
    prevhotif := false,
    hotifexpr := false,
    __enabled__ := false,
    id := 0,
    depth := 0

    __New() {
        this.id := ++keymap.previd
        
    }

    enable(*) {
    }

    disable(*) {
    }

    ondisable(*) {
    }

    funcwrapr(*) {
    }

    ontimeout(*) {
    }

    setkey(*) {
    }

    setkeypath(*) {
    }

    class binding extends funcarray {
        key := ""
        timeout := 0
        oneshot := false
        hotifexpr := false
        queuedkeys := []
        __enabled__ := false
        
        bm := {
            ontimeout: {},
            enable   : {},
            disable  : {}
        }
        __new(_key, _actions, _timeout:=0, _hotifexpr:=false, _oneshot:=false, *) {
            this.key := _key
            this.hotifexpr := _hotifexpr
            this.timeout := _timeout
            this.oneshot := _oneshot
            this.bm.ontimeout := objbindmethod(this, "ontimeout") 
            this.bm.enable    := objbindmethod(this, "enable") 
            this.bm.disable   := objbindmethod(this, "disable") 
            for _action in (_actions is array and _actions or [_actions])
                this.push((_action is primitive) ? ((*)=>send(_action)) : (_action))
        }
        enabled => this.__enabled__
        enable(*) {
            if this.hotifexpr
                hotif(this.hotifexpr)

            hotkey this.key, this, "on"
            this.__enabled__ := true

            if this.hotifexpr
                hotif()
            if this.timeout
                settimer this.bm.ontimeout, this.timeout.neg()
        }
        disable(*) {
            if this.hotifexpr
                hotif(this.hotifexpr)

            hotkey this.key, "off"
            this.__enabled__ := false

            if this.hotifexpr
                hotif()
        }
        ontimeout(*) {
            this.disable()
        }
        call(_args*) {
            if this.timeout
                settimer this.bm.ontimeout, 0
            if this.oneshot
                this.disable()
            for _qk in this.queuedkeys
                if _qk.enabled
                    _qk.enable()
            super.call()
        }
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



