; jdip.ahk

#requires autohotkey v2.0
#warn all, stdout
#singleinstance force

#include <builtins_extended>
#include <maths>
#include <gdip\gdijk>
#include <debug\jk_debug>

class gdipui extends gui {
    _x_ := 0
    _y_ := 0
    _w_ := 0
    _h_ := 0
    _xy_ := vector2.pos()
    _wh_ := vector2.size()
    _is_init_ := false
    
    __new(_options:="-Caption +ToolWindow +E0x80000 +LastFound +OwnDialogs", _title:=a_scriptname, _evtobj?) {
        super.__new(_options, _title, _evtobj?)
    }

    _first_show_(*) {
        
        super.show("NA")
        this._is_init_ := true
    }

    show(*) {
        if !this._is_init_
            return this._first_show_
        super.show()
    }

    x[_calc:=true] {
        get => _calc ? (this.getpos(&_x_), _x_) : this._x_
        set => (this.move(this._x_:=value))
    }
    y[_calc:=true] {
        get => _calc ? (this.getpos(,&_y_), _y_) : this._y_
        set => (this.move(,this._y_:=value))
    }
    w[_calc:=true] {
        get => _calc ? (this.getpos(,,&_w_), _w_) : this._w_
        set => (this.move(,,this._w_:=value))
    }
    h[_calc:=true] {
        get => _calc ? (this.getpos(,,,&_h_), _h_) : this._h_
        set => (this.move(,,,this._h_:=value))
    }
    xy {
        get => (this.getpos(&_x_, &_y_), this._xy_.set(_x_, _y_))
        set => (this.move(this._x_:=value.x, this._y_:=value.y))
    }
    wh {
        get => (this.getpos(&_w_, &_h_), this._wh_.set(_w_, _h_))
        set => (this.move(,,this._w_:=value.w, this._h_:=value.h))
    }
}
