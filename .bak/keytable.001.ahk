; .\Lib\keytable.ahk


; remove hotif_conf features from subclasses
; keep it for keytable class


#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include bultins_extended.ahk

class keytable extends Map {

     /**
      * @prop {Integer}
      */
    _enabled := false
     /**
      * @prop {Map} raw
      */
    , raw := Map()
     /**
      * @prop {Func} _hotif_cond
      */
    , _hotif_cond := ""

    __new(_initial_hotkeys?) {
        if !IsSet(_initial_hotkeys)
            return
        if not (_initial_hotkeys is Map)
            Throw ValueError(
                "<" A_ScriptName ">{keytable}.__new(_initial_hotkeys?) ... " .
                "[_initial_hotkeys] MUST be a {Map} type"
            )
        else for _key, _value in _initial_hotkeys {
            if _value is Array
                this.add(_key, _value*)
            else this.add(_key, _value)
        }
    }

    hotif_cond {
        get => this._hotif_cond
        set {
            if Value == this._hotif_cond
                return
            this._hotif_cond := Value
            if !!this.enabled
                this.reset_hotkeys()
        }
    }

    enabled {
        get => this._enabled
        set {
            if !!Value and !this._enabled
                this.set_hotkeys
            else if !Value and !!this._enabled
                this.unset_hotkeys
            this._enabled := !!Value
        }
    }

    set_hotkeys() {
        for _key, _binding in this {
            if !!_binding.enabled {
                _binding.active[(!!this.hotif_cond ? this.hotif_cond : unset), false] := true
            }
        }
    }

    unset_hotkeys() {
        for _key, _binding in this
            _binding.active := false
    }

    reset_hotkeys() {
        this.enabled := !this.enabled
        this.enabled := !this.enabled
    }

    add(_key, _actions*) {
        is_new := not this.raw.Has(_key)
        if is_new {
            this.raw[_key] := [_actions*]
            this[_key] := keytable.binding(_key, _actions*)
        } else for _action in _actions
            this[_key].action.add(this.raw[_key].PushPass(_action))
    }

    del(_key) {
        this[_key].active := false
        this.raw.Delete _key
        this.Delete _key
    }

    class binding {
        enabled  := true
        , key    := ""
        , action := {}
        , _hotif_cond := ""
        , _active := false

        __new(_key, _actions*) {
            this.key := _key
            this.action := keytable.binding.action_cluster(_actions*)
        }

        hotif_cond {
            get => this._hotif_cond
            set {
                if this._hotif_cond == Value
                    return
                if !!this.active {
                    this.active := false
                    this._hotif_cond := Value
                    this.active := true
                } else this._hotif_cond := Value
            }
        }

        active[_hotif_cond?, _keep_cond:=false] {
            get => this._active
            set {
                if !!Value and !this._active
                    this.bind(_hotif_cond ?? unset, _keep_cond)
                else if !Value and !!this._active
                    this.unbind
                this._active := !!Value
            }
        }

        bind(_hotif_cond?, _keep_cond:=true, *) {
            use_hotif := false
            if IsSet(_hotif_cond) {
                if !!_keep_cond
                    this._hotif_cond := _hotif_cond
                use_hotif := !!(_hotif_cond != "none") ? _hotif_cond : false
            } else if !!this.hotif_cond and (this.hotif_cond != "none")
                use_hotif := this.hotif_cond
            if !!use_hotif
                HotIf (*)=> use_hotif()
            Hotkey this.key, this, "On"
            if !!use_hotif
                HotIf
        }

        unbind(*) {
            Hotkey this.key, "Off"
        }

        call(*) {
            if not this.enabled
                return
            this.action()
        }
        
        class action_node {
            enabled := true
            type := "func"
            action := ""

            __new(_action) {
                this.action := _action
                this.type := Type(this.action).Lower()
                if not (this.type ~= "string|func")
                    throw ValueError("{keytable.binding.single_action}.__new(_action) ... " .
                                     "[_value] MUST be a string or function")
            }

            call(*) {
                if not this.enabled
                    return
                if this.type = "string"
                    Send(this.action)
                else if this.type = "func"
                    this.action()
            }
        }

        class action_cluster extends Array {
            enabled := true

            __new(_actions*) {
                this.add(_actions*)
            }

            call(*) {
                if not this.enabled
                    return
                for _action in this
                    _action()
            }

            add(_actions*) {
                for _action in _actions
                    this.Push keytable.binding.action_node(_action)
            }
        }
    }
}

kt := keytable()
kt.add "Ctrl & Space", (*)=>ExitApp()
kt.add "Alt & Space", (*)=>Reload()
kt.add "+a", "{Space 66}", (*)=>MsgBox("shift + a"), (*)=>MsgBox("shift + a`nreprieve!")
kt.enabled := true
kt.hotif_cond := (*)=>WinActive("ahk_exe firefox.exe")

RAlt & AppsKey:: {
    kt.enabled := !kt.enabled
}
