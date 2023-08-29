; pixwin.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#include <builtins_extended>
#Include <quiktip>
#include <maths>
#Include <wincache>
#include <gdip\gdijk>
#include <debug\jk_debug>

class pixwin extends gui {
    _x_ := 0
    _y_ := 0
    _w_ := 0
    _h_ := 0
    _xy_ := vector2.pos()
    _wh_ := vector2.size()
    is_init := false
    win := {}
    bitmap := 0
    bitmap_size := vector2.Size()
    bitmap_out := 0
    bitmap_pix := 0
    block_size := 15
    dib := 0
    hbm := 0
    hdc := 0
    obm := 0
    ug  := 0
    rect := vector4.Rect()
    __new(_wintitle:="A", _options:="", _evtobj?) {
        this.win := wincache[_wintitle]
        super.__new("-Caption +ToolWindow +E0x80000 +LastFound +OwnDialogs" _options
                  , "pixwin." A_Min "." A_Sec, _evtobj?)
        this.bitmap_size.__numtype__ := "int"
        this.rect.__numtype__ := "int"
        onexit objbindmethod(this, "__Delete")
    }

    _first_show_(*) {
        super.show("NA")
        this.bitmap := Gdip_BitmapFromHWND(this.win.hwnd)
        Gdip_GetImageDimensions(this.bitmap, &_bmw, &_bmh)
        this.bitmap_size.set(_bmw, _bmh)
        this.bitmap_out := Gdip_CreateBitmap(this.bitmap_size*)
        this.hbm := CreateDIBSection(this.bitmap_size*)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.ug := Gdip_GraphicsFromHDC(this.hdc)
        this.is_init := true
    }

    pixelate(_block_size?, *) {
        bitmap_out := this.bitmap_pix
        Gdip_PixelateBitmap(this.bitmap, &bitmap_out, this.block_size)
        this.bitmap_pix := bitmap_out
        Gdip_DrawImage(this.ug, this.bitmap_pix
                     , this.bitmap_size.w, this.bitmap_size.h, 0, 0
                     , this.bitmap_size.w, this.bitmap_size.h, 0, 0)
    }

    Update(_x?, _y?, _w?, _h?) {
        UpdateLayeredWindow(this.hwnd, this.hdc, _x?, _y?, _w?, _h?)
    }

    __Delete(*) {
        if !this.is_init
            return
        Gdip_DisposeImage(this.bitmap_out)
        Gdip_DisposeImage(this.bitmap)
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gdip_DeleteGraphics(this.ug)
        this.is_init := false
    }

    show(*) {
        this.rect.set(wincache["A"].rect)
        if !this.is_init
            this._first_show_
        quiktool this.bitmap_size.w ":" this.bitmap_size.h
        super.show("x" this.rect.x " y" this.rect.y " w" this.bitmap_size.w " h" this.bitmap_size.h)
        this.Update(this.rect*)
        this.pixelate()
        this.Update()
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


asd := pixwin()
asd.show()
sleep 5000
asd.Destroy()
asd.__Delete()
sleep 1000
exitapp
