
#requires autohotkey v2.0
#warn all, outputdebug
#singleinstance force

#include <debug\jk_debug>
#Include <builtins_extended>

class grid extends array {

    static __new() {

    }

    horiz_cells := 16
    vert_cells := 10
    xoffset := 0
    yoffset := 0
    width := A_ScreenWidth
    height := A_ScreenHeight
    zero_based := false
    forceread := false

    __new(_horiz_cells:=16, _vert_cells:=10, _xoffset?, _yoffset?, _width?, _height?, _zero_based:=false, *) {
        this.horiz_cells := _horiz_cells
        this.vert_cells := _vert_cells
        this.length := this.horiz_cells * this.vert_cells
        this.xoffset := _xoffset ?? this.xoffset
        this.yoffset := _yoffset ?? this.yoffset
        this.width := _width ?? this.width
        this.height := _height ?? this.height
        this.zero_based := _zero_based
    }

    empty() {
    }

    __item[_x, _y?] {
        get => super[_y ? (this.horiz_cells * (_y-1) + _x) : _x]
        set => super[_y ? (this.horiz_cells * (_y-1) + _x) : _x] := value
    }

    has(_index, _index2?) {
        if _index2 ?? false
            return super.has(this.horiz_cells * (_index2-1) + _index)
        else return superhas := super.has(_index)
    }

    cellwidth {
        get => (this.width /  this.horiz_cells)
        set => (this.width := this.horiz_cells * value)
    }

    cellheight {
        get => (this.height /  this.vert_cells)
        set => (this.height := this.vert_cells * value)
    }

    __enum(_varcount:=3) {
        _enum(_vcnt:=3, &_x?, &_y?, &_obj?) {
            static _prevx := 1
                 , _prevy := 1

            step(&__prevx, &__prevy) {
                if (++__prevy) > this.vert_cells {
                    __prevy:=1
                    if (++__prevx) > this.horiz_cells
                        return !(__prevx:=1)
                }
                return true
            }

            while not this.has(_prevx, _prevy)
                if !step(&_prevx, &_prevy)
                    return false

            switch _vcnt {
                case 3:
                    _x := _prevx
                    _y := _prevy
                    _obj := this[_prevx,_prevy]
                case 2:
                    _x := _prevx
                    _y := _prevy
                case 1:
                    _x := this[_prevx, _prevy]
            }

            step(&_prevx, &_prevy)

            return true
        }
        return _enum.bind(_varcount)
    }

    class cell {

    }
}

asd := grid(24, 12)
asd[2,2] := 334
asd[1,3] := 2354
dbgln {__o__:1,opendebugview:1}, asd.base
for _x in asd
    dbgln(_x,"...", "...")
for _x, _y in asd
    dbgln(_x, _y,"...", "...")
for _x, _y, _z in asd
    dbgln(_x, _y,"...", _z, "...")
