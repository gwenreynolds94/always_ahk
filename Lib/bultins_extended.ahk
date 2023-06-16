
Class __Float extends Float {
    static __New() {
        this.Prototype.__Class := "Float"
        for _prop in ObjOwnProps(this.Prototype)
            Float.Prototype.%_prop% := this.Prototype.%_prop%
    }

    /**
     *
     * @param {number} [_N=0] Round to `_N` digits after decimal point
     * @returns {number|string}
     */
    Round(_N:=0) {
        return Round(this, _N)
    }
}

Class __Array extends Array {

    Static __New() {
        this.Prototype.__Class := "Array"
        for _prop in ObjOwnProps(this.Prototype)
            Array.Prototype.%_prop% := this.Prototype.%_prop%
    }

    Reverse() {
        new_array := []
        Loop this.Length
            new_array.Push(this[this.Length-A_Index + 1])
        return new_array
    }

    IndexOf(_value) {
        found := False
        for _i, _v in this
            found := (_v = _value) ? _i : found
        return found
    }

    /**
     * if an index is negative, it will be changed to
     *
     *      this.Length + index + 1
     * which means `-1` would indicate the last item in array
     *
     * otherwise out-of-bound indexes are rounded to the nearest valid index
     *
     * @param {number} _index
     * @param {number} [_index2]
     * @returns {array}
     */
    FromRange(_index:=1, _index2?) {
        if _index < 0
            _index := this.Length + _index + 1
        if _index < 1
            _index := 1
        else if _index > this.Length
            _index := this.Length

        if IsSet(_index2) {
            if _index2 < 0
                _index2 := this.Length + _index2 + 1
            if _index2 < _index
                _index2 := _index
            else if _index2 > this.Length
                _index2 := this.Length
        } else _index2 := this.Length

        out_array := []

        loop (_index2 - _index) + 1
            out_array.Push(this[(_index + A_Index) - 1])

        return out_array
    }

    PushPass(_values*) {
        this.Push(_values*)
        Return this[this.Length]
    }

    ForEach(_func) {
        _parsed_list := []
        for _index, _value in this
            _parsed_list.Push _func(_value, _index, this)
        return _parsed_list
    }

    Filter(_func) {
        _filtered_list := []
        for _value in this
            if !!_func(_value)
                _filtered_list.Push(_value)
        return _filtered_list
    }

    /**
     * ```autohotkey2
     *
     * ==< VARIADIC >==
     *
     * ```
     * Pass a sequence of objects to be pushed to the original class instance.
     *
     * Where it differs from `{Array}.Push`is that any `{Array}` or
     * descendent of `{Array}` included in the arguments will be
     * iterated over and the individual values in said array are pushed
     * to the original class instance.
     *
     * @param {any} [_added] Can be a sequence of anything, but if it's nothing, the method
     *      will just return a clone of itself.
     * @returns {array} A shiny new array with *all* the values
     */
    Extend(_added*) {
        _new_array := this.CleanClone()
        ; _extended_array := []
        ; for _value in this
        ;     _extended_array.Push _value
        for _array in _added {
            if not (_array is Array)
                _new_array.Push _array
            else for _value in _array
                _new_array.Push _value
        }
        return _new_array
    }

    CleanClone() {
        _clean_array := []
        for _value in this
            _clean_array.Push _value
        return _clean_array
    }
}


Class __String extends String {

    Static __New() {
        this.Prototype.__Class := "String"
        for _prop in ObjOwnProps(this.Prototype)
            String.Prototype.%_prop% := this.Prototype.%_prop%
    }

    Length() {
        Return StrLen(this)
    }

    Sub(_starting_pos, _length?){
        Return SubStr(this, _starting_pos, _length ?? unset)
    }

    StartsWith(_chars) {
        Return this.Sub(1, _chars.Length()) == _chars
    }

    EndsWith(_chars) {
        Return this.Sub((-1) * _chars.Length(), _chars.Length()) == _chars
    }

    Replace(_re_needle, _replacement:='', &_cnt:=(-1), _starting_pos?) {
        repl_args := [
            this,
            _re_needle,
            _replacement
        ]
        if _cnt >= 0
            repl_args.Push(&_cnt)
        if (_starting_pos ?? False)
            repl_args.Push(_starting_pos)
        return RegExReplace(repl_args*)
    }
}


TrayTip.Quik := (_this, _title := '', _msg := '', _dur := 3000) => (
    TrayTip(_msg, _title, 0x20),
    SetTimer((*) => TrayTip(), (-1) * Abs(_dur)))


; Class __BuiltinClassExtension {
;     Static __TargetClass := "unset"
;     Static __New() {
;         cls := this.__TargetClass
;         if cls != "unset"
;             for _prop in this.Prototype.OwnProps()
;                 if SubStr(_prop, 1, 1) != "_"
;                     cls.Prototype.%_prop% := this.Prototype.%_prop%
;
;     }
; }

; Class __BuiltinClassExtension {
;     Static __New() {
;         clsproto := this.Prototype.__Class
;         clsname := SubStr(clsproto, 3)
;         if clsproto ~= "^[^_]{1,2}|__BuiltinClassExtension"
;             Return
;         cls := %clsname%
;         for _prop in this.Prototype.OwnProps()
;             if SubStr(_prop, 1, 2) != "__"
;                 cls.Prototype.%_prop% := this.Prototype.%_prop%
;     }
; }

; __BuiltinClassExt__New(_This) {
;     cls := %(_This.Base.Prototype.__Class)%
;     for _prop in ObjOwnProps(_This.Prototype)
;         if SubStr(_prop, 1, 2) != "__"
;             cls.Prototype.%_prop% := _This.Prototype.%_prop%
; }



; /**
;  * @class __Array
;  * @extends {Array|__BuiltinClassExtension}
;  */
; Class __Array extends __BuiltinClassExtension {
;     /** @extends {Array} */

;     ; Static __TargetClass := Array
;     ; Static __New() {
;     ;     for k in this.Prototype.OwnProps()
;     ;         if SubStr(k, 1, 1) != "_"
;     ;             Array.Prototype.%k% := this.Prototype.%k%
;     ; }

;     Reverse() {
;         new_array := []
;         Loop this.Length
;             new_array.Push(this[this.Length-A_Index + 1])
;         return new_array
;     }

;     IndexOf(_value) {
;         _found := False
;         for _i, _v in this
;             if _v = _value
;                 _found := _i
;         return _found
;     }

;     PushPass(_values*) {
;         this.Push(_values*)
;         Return this[this.Length]
;     }
; }



