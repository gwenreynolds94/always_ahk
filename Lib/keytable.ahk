; keytable.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include bultins_extended.ahk

class keytable extends Map {
    
    static default_timeout := 3000

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
     /**
      * @prop {Func} _alt_hotif_cond
      */
    , _alt_hotif_cond := ""
     /**
      * @prop {Object} bound_methods
      */
    , bound_methods := {
        enable: {},
        disable: {}
    }

    __new(_initial_hotkeys?, _map_params*) {
        super.__new(_map_params*)
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
        this.bound_methods := {
            enable: ObjBindMethod(this, "enable"),
            disable: ObjBindMethod(this, "disable")
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

    alt_hotif_cond {
        get => this._alt_hotif_cond
        set {
            if Value == this.alt_hotif_cond
                return
            this._alt_hotif_cond := Value
            if !!this.enabled
                this.reset_hotkeys()
        }
    }

    /**
    class hotif_cluster extends Array {
        type := ""

        __new(_type:="or", _hotif_cond*) {
            super.__new(_hotif_cond*)
            this.type := _type
        }

        get_and(*) {
            retbool := true
            for _cond in this
                if !!_cond and (not (!!retbool and !!_cond()))
                    retbool := false
            return retbool
        }

        get_or(*) {
            retbool := false
            for _cond in this
                if !!_cond and (!!retbool or !!_cond())
                    retbool := true
            return retbool
        }
        
        call(*) {
            if this.type = "or"
                return this.get_or()
            else if this.type = "and"
                return this.get_and()
        }
    }

    add_hotif_and(_hotif_cond*) {
        this.hotif_cond := keytable.hotif_cluster("and", this.hotif_cond, _hotif_cond*)
    }

    add_hotif_or(_hotif_cond*) {
        this.hotif_cond := keytable.hotif_cluster("or", this.hotif_cond, _hotif_cond*)
    }

    add_alt_hotif_and(_alt_hotif_cond*) {
        this.alt_hotif_cond := keytable.hotif_cluster("and", this.alt_hotif_cond, _alt_hotif_cond*)
    }

    add_alt_hotif_or(_alt_hotif_cond*) {
        this.alt_hotif_cond := keytable.hotif_cluster("or", this.alt_hotif_cond, _alt_hotif_cond*)
    }
    */

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

    toggle() {
        this.enabled := !this.enabled
    }

    enable() {
        this.enabled := true
    }

    disable() {
        this.enabled := false
    }

    set_hotkeys() {
        for _key, _binding in this {
            if !!_binding.enabled {
                _binding.active[(!!this.hotif_cond     ? this.hotif_cond     :
                                 !!this.alt_hotif_cond ? this.alt_hotif_cond : unset), false] := true
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
        return this[_key]
    }

    del(_key) {
        this[_key].active := false
        this.raw.Delete _key
        this.Delete _key
    }

    pulse(_timeout?) {
        _timeout := _timeout ?? keytable.default_timeout
        bm_disable := this.bound_methods.disable
        this.enabled := true
        SetTimer bm_disable, (-1) * Abs(_timeout)
    }

    class binding {
        enabled  := true
        , key    := ""
        , action := {}
        , _active := false
        , _hotif_cond := ""
        , prev_hotif_cond := ""

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
                    this._hotif_cond := this.prev_hotif_cond
                    this.active := false
                    this._hotif_cond := Value
                    this.active := true
                } else this._hotif_cond := Value
            }
        }

        add_hotif_and(_hotif_cond*) {
            current_cond := !!this.hotif_cond ? this.hotif_cond : (*)=>true
            for _cond in _hotif_cond
                current_cond := (*)=>(!!current_cond() and !!_cond())
            this.hotif_cond := current_cond
        }

        add_hotif_or(_hotif_cond*) {
            current_cond := !!this.hotif_cond ? this.hotif_cond : (*)=>false
            for _cond in _hotif_cond
            current_cond := (*)=>(!!current_cond() or !!_cond())
            this.hotif_cond := current_cond
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
                use_hotif := (_hotif_cond != "none") ? _hotif_cond : false
            } else if !!this.hotif_cond and (this.hotif_cond != "none")
                use_hotif := this.hotif_cond
            if !!use_hotif
                HotIf use_hotif
            Hotkey this.key, this, "On"
            if !!use_hotif
                HotIf
            this.prev_hotif_cond := use_hotif
        }

        unbind(*) {
            use_hotif := this.prev_hotif_cond
            if !!use_hotif
                HotIf use_hotif
            Hotkey this.key, "Off"
            if !!use_hotif
                HotIf
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

class keysheet extends Map {
    name := ""
    _enabled := false

    __new(_name?, _map_params*) {
        this.name := _name ?? this.name
    }

    enabled {
        get => this._enabled
        set {
            if !!Value and !this._enabled
                this.enable_all()
            else if !Value and !!this._enabled
                this.disable_all()
            this._enabled := !!Value
        }
    }

    toggle(*){
        this.enabled := !this.enabled
    }

    enable_all(*) {
        for _ktbl_name, _ktbl in this
            _ktbl.enabled := true
    }

    disable_all(*) {
        for _ktbl_name, _ktbl in this
            _ktbl.enabled := false
    }

    add(_ktbl_name, _initial_hotkeys?) {
        new_ktbl := this[_ktbl_name] := keytable(_initial_hotkeys ?? unset)
        return new_ktbl
    }

    del(_ktbl_name) {
        if not this.Has(_ktbl_name)
            return
        this[_ktbl_name].enabled := false
        this.Delete(_ktbl_name)
    }
}

