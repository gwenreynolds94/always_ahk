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
    _rect_ := vector4.Rect( A_ScreenWidth/2 - 800/2, A_ScreenHeight/2 - 600/2, 800, 600 )
    _bgcolor_ := ""
    _bradius_ := 0

    __new(   _options:="-Caption +ToolWindow +LastFound +OwnDialogs"
           , _title:=a_scriptname
           , _rect?
           , _bradius:=0
           , _bgcolor:="ccefda"
           , _evtobj?
         ) {

        super.__new("+E0x80000 " _options, _title, _evtobj?)

        this._rect_.__numtype__ := "int"
        this._rect_.set(_rect ?? this._rect_)

        this._bgcolor_ := _bgcolor
        this._bradius_ := _bradius
    }

    coordstring => "x" this._rect_.x " y" this._rect_.y " w" this._rect_.w " h" this._rect_.h

    _first_show_(*) {
        super.show("NA")
        this.drawbg
        this._is_init_ := true
    }

    drawbg(_bgcolor?, *) {
        this._bgcolor_ := _bgcolor ?? this._bgcolor_
        gbm := CreateDIBSection(this._rect_.w, this._rect_.h)
        dctx := CreateCompatibleDC()
        dcbm := SelectObject(dctx, gbm)
        gfx := Gdip_GraphicsFromHDC(dctx)
        Gdip_SetSmoothingMode gfx, 2
        gbrush := Gdip_BrushCreateSolid(integer("0xff" this._bgcolor_))
        if this._bradius_
            Gdip_FillRoundedRectangle(gfx, gbrush, 0, 0, this._rect_.w, this._rect_.h, this._bradius_)
        else Gdip_FillRectangle(gfx, gbrush, 0, 0, this._rect_.w, this._rect_.h)
        Gdip_DeleteBrush gbrush
        UpdateLayeredWindow(this.hwnd, dctx, this._rect_.x, this._rect_.y, this._rect_.w, this._rect_.h)
        SelectObject dctx, dcbm
        DeleteDC dctx
    }

    drawbitmap(_bitmap, *) {

    }

    drawrect(_color, _rect, *) {

    }

    show(*) {
        if !this._is_init_
            return this._first_show_()
        super.show(this.coordstring)
    }
}

ggui := gdipui()
ggui.show()


^#e::ExitApp
