; builtins_extended.ahk

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

Class __Number extends Number {
    static __New() {
        this.Prototype.__Class := "Number"
        for _prop in ObjOwnProps(this.Prototype)
            Number.Prototype.%_prop% := this.Prototype.%_prop%
    }

    Abs() {
        return Abs(this)
    }

    Neg() {
        return ((-1) * Abs(this))
    }

    Clamp(_min:=0,_max:=1) {
        if _max < this
            return _max
        if _min > this
            return _min
        return this
    }

    Nearest(_numbers*) {
        closest_number := _numbers.length ? _numbers[1] : Number(this)
        for _nbr in _numbers {
            if (_nbr - this).abs() < (closest_number - this).abs()
                closest_number := _nbr
        }
        return closest_number
    }

    Lerp(_v2, _t) => Math.Lerp(this, _v2, _t)
    Min(_values*) => Min(this, _values*)
    Max(_values*) => Max(this, _values*)
}

Class __String extends String {

    static __matchmode__ := "regex"

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
        Return this.Sub((-1) * _chars.Length(), _chars.Length()) ~= _chars
    }

    Lower() {
        return StrLower(this)
    }

    Upper() {
        return StrUpper(this)
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

    Repeat(_count) {
        retstr := ""
        loop _count
            retstr .= this
        return retstr
    }

}


Class __Array extends Array {

    static previd := 0
        ,  cache := []

    Static __New() {
        this.Prototype.__Class := "Array"
        for _prop in ObjOwnProps(this.Prototype)
            if (not _prop.StartsWith("__")) or _prop.EndsWith("__")
                Array.Prototype.%_prop% := this.Prototype.%_prop%
    }

    __new(_params*) {
        this.___cacheid___ := ++__Array.previd
        super.__new(_params*)
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
            if _index2 = 0
                return []
            if _index2 < 0
                _index2 := this.Length + _index2 + 1
            if _index2 < _index
                _index2 := _index
            else if _index2 > this.Length
                _index2 := this.Length
        } else _index2 := this.Length

        if (_index2 ?? "i2") = _index
            try return [_index2 ? (this[_index2]) : unset]

        out_array := []
        loop ((_index2 - _index) + 1)
            out_array.Push(this[(_index + A_Index) - 1])

        return out_array
    }

    PushPass(_values*) {
        this.Push(_values*)
        Return this[this.Length]
    }

    ForEach(_func, *) {
        _parsed_list := []
        for _index, _value in this
            _parsed_list.Push _func(_value, _index, this)
        return _parsed_list
    }
    Min(_values*) => Min(this.extend(_values)*)
    Max(_values*) => Max(this.extend(_values)*)

    Filter(_func, *) {
        _filtered_list := []
        for _value in this
            if !!_func(_value)
                _filtered_list.Push(_value)
        return _filtered_list
    }

    Filter2(_func, &_filteredtrue:=false, &_filteredfalse:=false, *) {
        _filteredtrue := _filteredtrue or []
        _filteredfalse := _filteredfalse or []
        for _value in this
            (!!_func(_value) ? _filteredtrue.push(_value) : _filteredfalse.push(_value))
        return map( true, _filteredtrue, false, _filteredfalse )
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


Class __Map extends Map {

    static previd := 0
        ,  cache := []

    Static __New() {
        this.Prototype.__Class := "Map"
        for _prop in ObjOwnProps(this.Prototype)
            if not _prop.StartsWith("__")
                Map.Prototype.%_prop% := this.Prototype.%_prop%
    }
    ___cacheid___ := 0

    __new(_params*) {
        super.__new(_params*)
        this.___cacheid___ := ++__Map.previd
    }

    Extend(_map2, _mode:="keep", _new_map:=false, *) {
        newmap := _new_map and map() or this
        if _new_map
            for _k1, _v1 in this
                newmap[_k1] := _v1
        for _key, _value in _map2
            if (!newmap.has(_key) or _mode="force")
                newmap[_key] := _value
        return newmap
    }

}

class FuncArray extends Array {
    call(_args*) {
        retvals := []
        for _func in this
            if _func is func or hasmethod(_func, "call") {
                if (_funcargs:=_args.fromrange(!!_func.call.maxparams, _func.call.maxparams))
                    retvals.push(_func(_funcargs*))
            } else if (_func is string)
                send(_func)
        return retvals
    }
}

#include maths.ahk


