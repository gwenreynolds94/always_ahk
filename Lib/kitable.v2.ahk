
#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include .\DEBUG\jk_debug.ahk
#Include .\builtins_extended.ahk

class kitable extends Map {
    
    static previd := 1
         , ktbls := Map()
         , kbinds := Map()
         , activekeys := Map()
         , activebindids := []

    __enabled__ := false
    __leaderenabled__ := false
    leaderbind := false
    name := ""
    leader := ""
    childcnt := 0
    timeout := false
    oneshot := false
    hotifexpr := false
    onenable := false
    ondisable := false
    nestlevel := 0
    parent := ""
    id := 0

    bm := {
        enable: (*)=>(0),
        disable: (*)=>(0),
        toggle: (*)=>(0),
        enableleader: (*)=>(0)
    }

    __new(_name:="", _timeout:=0, _leader:="", _oneshot:=false, _hotifexpr:=false) {
        this.bm.enable := objbindmethod(this, "enable")
        this.bm.disable := objbindmethod(this, "disable")
        this.bm.toggle := objbindmethod(this, "toggle")
        this.bm.enableleader := objbindmethod(this, "enableleader")
        this.id := kitable.previd++
        this.name := (_name or "anon") "." (_leader or "n-a") "." this.id
        this.is_root := !this.name.StartsWith("_")
        this.leader := kitable.kibind(_leader, this.bm.enable, _timeout, _hotifexpr, false, this)
        this.timeout := _timeout
        this.oneshot := _oneshot
        this.onenable := kitable.kibind.kiaction()
        this.ondisable := kitable.kibind.kiaction()
        this.settimeout := (_timeout:=0,*)=>(settimer(this.bm.disable, _timeout and _timeout.neg()))
        this.starttimeout := this.settimeout.bind(this.timeout.neg())
        this.stoptimeout := this.settimeout.bind(0)
        kitable.ktbls[this.name] := this
    }

    enabled => this.__enabled__

    enableleader(*) {
        this.leaderenabled := true
    }

    leaderenabled {
        get => this.__leaderenabled__
        set {
            if this.leader
                if (this.__leaderenabled__ := !!Value)
                    this.leader.enable()
                else this.leader.disable()
        }
    }

    enable(_hotkey:="", *) {
        dbgln("kitable.enable: " this.name " : " this.enabled " : parent: " (this.parent and this.parent.name))
        for _ki, _kikind in this
            _kikind.enable()
        if this.timeout
            this.starttimeout
        this.onenable()
        this.__enabled__ := true
    }

    disable(_hotkey:="", *) {
        this.stoptimeout
        for _ki , _kibind in this
            _kibind.disable()
        this.ondisable()
        if this.leaderenabled
            this.leader.enable()
        this.__enabled__ := false
    }

    ontimeout(*) {
    }

    toggle(_hotkey:="", *) {
        dbgln("AHK: always_ahk.kitable: kitable.toggle( " (_hotkey or "") " )")
    }

    hotki(_ki, _actions, _timeout:=0, _hotifexpr:=false, _oneshot:=false, *) {
        this[_ki] := kitable.kibind(_ki, _actions, _timeout or this.timeout, this.hotifexpr, _oneshot, this)
    }

    pathki(_ki_array, _actions, _timeout:=2250, _hotifexpr:=false, _oneshot:=false, *) {
        _actions:= (_actions is array) and _actions or [_actions]
        if not (_ki_array is array or (_ki_array is string and _ki_array:=[_ki_array]))
            throw Error("_ki_array must be a string or array type")
        if _ki_array.Length = 1 {
            this[_ki_array[1]] := kitable.kibind(_ki_array[1], _actions, _timeout, _hotifexpr, _oneshot, this)
            return
        }
        ktbls := [this]
        for _ki in _ki_array {
            ktbl := ktbls[ktbls.length]
            if ktbl.has(_ki) and ktbl[_ki] is kitable.kibind {
                newbind := kitable.kibind("", false, _timeout, _hotifexpr, _oneshot)
                ktbl.action.push
            }
            newtbl := kitable("__" this.name "." (++ktbl.childcnt), _timeout, _ki, true, _hotifexpr)
            newtbl.parent := ktbl
            newtbl.is_root := false
            newtbl.nestlevel := A_Index 
            ktbl[_ki] := newtbl
            ktbls.push ktbl[_ki]
        } until (A_Index) >= _ki_array.length
        lastki := _ki_array[_ki_array.length]
        lastkitbl := ktbls[ktbls.length]
        lastkitbl.leader.onenable.push(_actions)
        lastkitbl.leader.ondisable.push(this.bm.enableleader)
    }

    class kibind extends map {
        static previd := 0

        bm := {
            enable: (*)=>(0),
            disable: (*)=>(0),
            ondisable: (*)=>(0)
        }
        name := ""
        ki := false
        id := 0
        action := false
        parent_table := false
        oneshot := false
        kiqueue := false
        hotifexpr := false
        prevhotifexpr := false
        timeout := 0
        onenable := false
        ondisable := false
        /**
         * @prop {integer} __enabled__
         */
        __enabled__ := false

        __new(_ki:="", _actions:=false, _timeout:=0, _hotifexpr:=false, _oneshot:=false, _parent_table?) {
            this.id := ++kitable.kibind.previd
            this.ki := _ki
            this.name := (isset(_parent_table) ? _parent_table.name : "anon") ".{" this.ki "}." this.id
            this.action := kitable.kibind.kiaction(_actions, this)
            this.oneshot := _oneshot
            this.timeout := _timeout
            this.parent_table := _parent_table ?? false
            this.hotifexpr := _hotifexpr
            this.bm.enable := objbindmethod(this, "enable")
            this.bm.disable := objbindmethod(this, "disable")
            this.onenable := kitable.kibind.kiaction()
            this.ondisable := kitable.kibind.kiaction()
            this.settimeout := (_timeout:=0,*)=>(settimer(this.bm.disable, _timeout.neg()))
            this.starttimeout := this.settimeout.bind(this.timeout.neg())
            this.stoptimeout := this.settimeout.bind(0)
            kitable.kbinds[this.id] := this
        }

        enabled => this.__enabled__

        enable(*) {
            dbgln("kitable.kibind.enable: " this.name " : " this.enabled " : parent: " (this.parent_table and this.parent_table.name))

            if this.__enabled__
                return

            if this.hotifexpr
                hotif((this.prevhotifexpr:=this.hotifexpr))

            hotkey this.ki, this.action

            this.__enabled__ := true

            if this.hotifexpr
                hotif()

            kitable.activekeys[this.id] := this
            kitable.activebindids.push(this.id)

            if this.timeout
                this.starttimeout

            this.onenable()
        }

        disable(*) {
            dbgln("kitable.kibind.disable: " this.name " : " this.enabled " : parent: " (this.parent_table and this.parent_table.name))
            if this.timeout
                this.stoptimeout

            if !this.__enabled__
                return

            if this.prevhotifexpr
                hotif(this.prevhotifexpr)

            hotkey this.ki, "off"

            if this.hotifexpr
                hotif()

            kitable.activekeys.delete(this.id)
            if (_idx := kitable.activebindids.IndexOf(this.id))
                kitable.activebindids.RemoveAt _idx

            this.__enabled__ := false
        
            if this.parent_table and this.parent_table.name ~= "^_" and this.oneshot
                this.parent_table.bm.disable()

            this.ondisable()
        }

        ontimeout(*) {
            
        }

        class kiaction extends array {
            parent_bind := false

            __new(_actions:=false, _parent_bind:=false) {
                this.parent_bind := _parent_bind
                if not _actions
                    return
                _actions := ((_actions is array) ? _actions : [_actions])
                for _action in _actions
                    this.push _action
            }
            
            call(*) {
                doaction(_action) {
                    if _action is func or _action is kitable.kibind.kiaction
                        _action()
                    else if _action is kitable or _action is kitable.kibind
                        _action.enable()
                    else if _action is string
                        send(_action)
                }
                if (pbind:=this.parent_bind)
                    if pbind.oneshot
                        pbind.disable()
                for _action in this
                    doaction _action
            }
        }
    }
}


asd := kitable("root.asd", 0, "^0", false, false)
asd.pathki(["^9", "^8", "^7"], [msgbox.bind("^9 ^8 ^7"), asd.bm.enableleader])
asd.hotki("^5", dbgln.bind(kitable.activebindids))
asd.leaderenabled := true

^6::Reload

