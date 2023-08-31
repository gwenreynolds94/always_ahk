; maths.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#include builtins_extended.ahk

class Math {
    static PI => 3.14159
    class Lerp {
        static precision := "imprecise"
        static imprecise(_v1, _v2, _t) => _v1 + _t * (_v2 - _v1)
        static precise(_v1, _v2, _t) => (1 - _t) * _v1 + _t * _v2
        static call(_v1, _v2, _t) => Math.Lerp.%(Math.Lerp.precision)%(_v1, _v2, _t)
        static Flip(_v1) => 1 - _v1
        static EaseIn(_v1, _v2, _t) => this(_v1, _v2, _t ** 2)
        static EaseOut(_v1, _v2, _t) => this(_v1, _v2, this.flip(this.flip(_t) ** 2))
        static Bezier(_v1, _v2, _t) => _v1 + (_t * _t * (3 - 2 * _t) * (_v2 - _v1))
    }
    class Vector {
        ___bm___ := {
            anon : objbindmethod(this, "Anon"),
            anon4: objbindmethod(this, "Anon4")
        }
        __propslist__ => ["x", "y", "z", "w"]
        __altpropslist__ => []
        ___numtype___ := "float"
        __numtype__ {
            get => this.___numtype___
            set => (this.___numtype___ := (value ~= "fl(oa)?t")   ? "float"   :
                                          (value ~= "int(eger)?") ? "integer" : 
                                                           this.___numtype___ )
        }
        __new(_values*){
            if !_values.length
                return this.set(0)
            if (firstitem:=_values[1]) is Math.Vector
                return this.set(firstitem*)
            loop this.__propslist__.length - _values.length
                _values.push 0
            return this.set(_values*)
        }
        Anon4(_method, _v1?, _v2?, _v3?, _v4?) {
            nt := this.__numtype__
            argmap := map(
                  "_v1", _v1 ?? "unset"
                , "_v2", _v2 ?? "unset"
                , "_v3", _v3 ?? "unset"
                , "_v4", _v4 ?? "unset"
            )
            argtst := argmap.where( (_k, _v, _i, _t)=> ( 
                    (this.__propslist__.length >= _i) and (_v != "unset") ) )
            argcnt := argtst.Count
            if !argcnt
                return this
            argkey := argtst.Keys()[1]
            argval := argtst[argkey]
            if (argcnt = 1) {
                if (argval is number) {
                    for _propname in this.__propslist__
                        this.%_propname% := _method(this.%_propname%, %nt%(argval))
                    return this
                } else if (argval is Math.Vector) {
                    for _propname in this.__propslist__
                        this.%_propname% := _method(this.%_propname%, %nt%(argval.%_propname%))
                    return this
                }
            }
            for _argname, _arg in argtst {
                propname := this.__propslist__[A_Index]
                prop := this.%propname%
                if _arg is number
                    this.%propname% := _method(prop, %nt%(_arg))
                else if %_argname% is math.vector
                    if objhasownprop(_arg, propname)
                        this.%propname% := _method(prop, %nt%(_arg.%propname%))
            }
            return this
        }
        Equals(_v2) {
            _v2isnum := _v2 is number
            for _crd in this.__propslist__
                if _v2isnum {
                    if (this.%_crd% != _v2)
                        return false
                } else if !objhasownprop(_v2, _crd) or !(_v2.%_crd% = this.%_crd%)
                    return false
            return true
        }
        HasOwnProp(_propname) => !(_propname.StartsWith("_") or !objhasownprop(this, _propname))
        OwnProps(*) => [objownprops(this)*].Filter((_v)=>(!_v.startswith("_")))
        Lerp(_v, _t)=> this.anon4((__v2,__v1)=>(Math.Lerp(__v2, __v1, _t)), _v)
        Bezier(_v, _t)=> this.anon4((__v2,__v1)=>(Math.Lerp.Bezier(__v2, __v1, _t)), _v)
        EaseOut(_v, _t)=> this.anon4((__v2,__v1)=>(Math.Lerp.EaseOut(__v2, __v1, _t)), _v)
        Sub(_v1, _v2?, _v3?, _v4?)=> this.anon4((__v2,__v1)=>(__v2 - __v1), _v1, _v2?, _v3?, _v4?)
        Add(_v1, _v2?, _v3?, _v4?)=> this.anon4((__v2,__v1)=>(__v2 + __v1), _v1, _v2?, _v3?, _v4?)
        Div(_v1, _v2?, _v3?, _v4?)=> this.anon4((__v2,__v1)=>(__v2 / __v1), _v1, _v2?, _v3?, _v4?)
        Mul(_v1, _v2?, _v3?, _v4?)=> this.anon4((__v2,__v1)=>(__v2 * __v1), _v1, _v2?, _v3?, _v4?)
        Min(_v1, _v2?, _v3?, _v4?)=> this.anon4((__v2,__v1)=>(__v2.min(__v1)), _v1, _v2?, _v3?, _v4?)
        Max(_v1, _v2?, _v3?, _v4?)=> this.anon4((__v2,__v1)=>(__v2.max(__v1)), _v1, _v2?, _v3?, _v4?)
        Set(_v1?, _v2?, _v3?, _v4?)=> this.anon4((__v2,__v1)=>(__v1), _v1?, _v2?, _v3?, _v4?)

        __enum(_vcnt:=2) {
            _enum_(_vcount, &_v1?, &_v2?, &_v3?, &_v4?) {
                static counter := 0
                if ++counter > this.__propslist__.length
                    counter:=0
                else {
                    switch _vcount {
                        case 1:
                            _v1 := this.%(this.__propslist__[counter])%
                        case 2:
                            _v1 := (this.__propslist__[counter])
                            _v2 := this.%(this.__propslist__[counter])%
                        case 3:
                            hasaltprop := counter <= this.__altpropslist__.length
                            _v1 := (this.__propslist__[counter])
                            _v2 := this.%(this.__propslist__[counter])%
                            _v3 := (hasaltprop and this.__altpropslist__[counter])
                        case 4:
                            hasaltprop := counter <= this.__altpropslist__.length
                            _v1 := (this.__propslist__[counter])
                            _v2 := this.%(this.__propslist__[counter])%
                            _v3 := (hasaltprop and this.__altpropslist__[counter])
                            _v4 := (hasaltprop and this.%(this.__altpropslist__[counter])%)
                    }
                }
                return !!counter
            }
            return _enum_.bind(_vcnt)
        }
    }

}

class Vector2 extends Math.Vector {
    x := 0
    y := 0
    __propslist__ => ["x", "y"]
    __new(_x?, _y?) {
        super.__new(_x ?? 0, _y?)
        this.deleteprop "w"
        this.deleteprop "z"
    }
    Sub(_vx, _y?) => super.Sub(_vx, _y?)
    Add(_vx, _y?) => super.Add(_vx, _y?)
    Div(_vx, _y?) => super.Div(_vx, _y?)
    Mul(_vx, _y?) => super.Mul(_vx, _y?)
    Min(_vx, _y?) => super.Min(_vx, _y?)
    Max(_vx, _y?) => super.Max(_vx, _y?)
    class Size extends Vector2 {
        w := 0
        h := 0
        __propslist__ => ["w", "h"]
        __new(_w?, _h?) {
            Math.Vector.Prototype.__new.call(this, _w ?? 0, _h?)
            this.deleteprop "x"
            this.deleteprop "y"
            this.deleteprop "z"
        }
        Sub(_vw, _h?) => super.Sub(_vw, _h?)
        Add(_vw, _h?) => super.Add(_vw, _h?)
        Div(_vw, _h?) => super.Div(_vw, _h?)
        Mul(_vw, _h?) => super.Mul(_vw, _h?)
        Min(_vw, _h?) => super.Min(_vw, _h?)
        Max(_vw, _h?) => super.Max(_vw, _h?)
    }
    class Pos extends Vector2 {
        __new(_x?, _y?) {
            super.__new(_x ?? 0, _y?)
        }
        Sub(_vx, _y?) => super.Sub(_vx, _y?)
        Add(_vx, _y?) => super.Add(_vx, _y?)
        Div(_vx, _y?) => super.Div(_vx, _y?)
        Mul(_vx, _y?) => super.Mul(_vx, _y?)
        Min(_vx, _y?) => super.Min(_vx, _y?)
        Max(_vx, _y?) => super.Max(_vx, _y?)
    }
}

class Vector3 extends Math.Vector {
    x := 0
    y := 0
    z := 0
    __propslist__ => ["x", "y", "z"]
    __new(_x?, _y?, _z?) {
        super.__new(_x ?? 0, _y?, _z?)
    }
    Sub(_vx, _y?, _z?) => super.Sub(_vx, _y?, _z?)
    Add(_vx, _y?, _z?) => super.Add(_vx, _y?, _z?)
    Div(_vx, _y?, _z?) => super.Div(_vx, _y?, _z?)
    Mul(_vx, _y?, _z?) => super.Mul(_vx, _y?, _z?)
    Min(_vx, _y?, _z?) => super.Min(_vx, _y?, _z?)
    Max(_vx, _y?, _z?) => super.Max(_vx, _y?, _z?)
}

class Vector4 extends Math.Vector {
    x := 0
    y := 0
    z := 0
    w := 0
    __propslist__ => ["x", "y", "z", "w"]
    __new(_x?, _y?, _z?, _w?) {
        super.__new(_x ?? 0, _y?, _z?, _w?)
    }
    Sub(_vx, _y?, _z?, _w?) => super.Sub(_vx, _y?, _z?, _w?)
    Add(_vx, _y?, _z?, _w?) => super.Add(_vx, _y?, _z?, _w?)
    Div(_vx, _y?, _z?, _w?) => super.Div(_vx, _y?, _z?, _w?)
    Mul(_vx, _y?, _z?, _w?) => super.Mul(_vx, _y?, _z?, _w?)
    Min(_vx, _y?, _z?, _w?) => super.Min(_vx, _y?, _z?, _w?)
    Max(_vx, _y?, _z?, _w?) => super.Max(_vx, _y?, _z?, _w?)

    class Rect extends Vector4 {
        x := 0
        y := 0
        w := 0
        h := 0
        __propslist__ => ["x", "y", "w", "h"]
        __altpropslist__ => vector4.rect.corners.prototype.__propslist__
        __new(_x?, _y?, _w?, _h?) {
            Math.Vector.Prototype.__new.call(this, _x ?? 0, _y?, _w?, _h?)
            this.deleteprop "z"
            this.defineprop "l", { get: (*)=> this.x }
            this.defineprop "t", { get: (*)=> this.y }
            this.defineprop "r", { get: (*)=> this.w + this.x }
            this.defineprop "b", { get: (*)=> this.h + this.y }
        }
        Cornered => vector4.rect.corners(this.l, this.t, this.r, this.b)
        Size => vector2.size(this.w, this.h)
        Pos => vector2.pos(this.x, this.y)
        Sub(_vx, _y?, _w?, _h?) => super.Sub(_vx, _y?, _w?, _h?)
        Add(_vx, _y?, _w?, _h?) => super.Add(_vx, _y?, _w?, _h?)
        Div(_vx, _y?, _w?, _h?) => super.Div(_vx, _y?, _w?, _h?)
        Mul(_vx, _y?, _w?, _h?) => super.Mul(_vx, _y?, _w?, _h?)
        Min(_vx, _y?, _w?, _h?) => super.Min(_vx, _y?, _w?, _h?)
        Max(_vx, _y?, _w?, _h?) => super.Max(_vx, _y?, _w?, _h?)

        class Corners extends Vector4 {
            l := 0
            t := 0
            r := 0
            b := 0
            __propslist__ => ["l", "t", "r", "b"]
            __altpropslist__ => vector4.rect.prototype.__propslist__
            __new(_l?, _t?, _r?, _b?, _numtype:="float") {
                this.__numtype__ := _numtype
                Math.Vector.Prototype.__new.call(this, _l ?? 0, _t?, _r?, _b?)
                for _propname in Vector4.Prototype.__propslist__
                    this.deleteprop _propname
                this.defineprop "x", { get: (*)=> this.l }
                this.defineprop "y", { get: (*)=> this.t }
                this.defineprop "w", { get: (*)=> this.r - this.l }
                this.defineprop "h", { get: (*)=> this.b - this.t }
            }
            Rectified => vector4.rect(this.x, this.y, this.w, this.h)
            Sub(_vl, _t?, _r?, _b?) => super.Sub(_vl, _t?, _r?, _b?)
            Add(_vl, _t?, _r?, _b?) => super.Add(_vl, _t?, _r?, _b?)
            Div(_vl, _t?, _r?, _b?) => super.Div(_vl, _t?, _r?, _b?)
            Mul(_vl, _t?, _r?, _b?) => super.Mul(_vl, _t?, _r?, _b?)
            Min(_vl, _t?, _r?, _b?) => super.Min(_vl, _t?, _r?, _b?)
            Max(_vl, _t?, _r?, _b?) => super.Max(_vl, _t?, _r?, _b?)
        }
    }
}
