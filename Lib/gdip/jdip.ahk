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
    gbm := 0x0
    hdc := 0x0
    hbm := 0x0
    gfx := 0x0
    drawqueue := funcarray()

    __new(   _options:="-Caption +ToolWindow +LastFound +OwnDialogs"
           , _title:=a_scriptname
           , _rect?
           , _bradius:=0
           , _bgcolor:="ccefda"
           , _evtobj?
         ) {

        super.__new("+E0x80000 " _options, _title, _evtobj?)
        this.MarginX := 0
        this.MarginY := 0

        this._rect_.__numtype__ := "int"
        this._rect_.set(_rect ?? this._rect_)

        this._bgcolor_ := _bgcolor
        this._bradius_ := _bradius
    }

    coordstring => "x" this._rect_.x " y" this._rect_.y " w" this._rect_.w " h" this._rect_.h

    rect => this._rect_

    _first_show_(*) {
        super.show("NA")
        this.drawbg
        this._is_init_ := true
    }

    openctx(*) {
        this.gbm := CreateDIBSection(this.rect.w, this.rect.h)
        this.hdc := CreateCompatibleDC()
        this.hbm := SelectObject(this.hdc, this.gbm)
        this.gfx := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode this.gfx, 2
    }

    closectx(*) {
        SelectObject this.hdc, this.hbm
        DeleteDC this.hdc
    }

    updatelayeredwindow(*)=>
        UpdateLayeredWindow(this.hwnd, this.hdc, this._rect_.x, this._rect_.y, this._rect_.w, this._rect_.h)

    drawbg(_bgcolor?, *) {
        this._bgcolor_ := _bgcolor ?? this._bgcolor_
        gbrush := Gdip_BrushCreateSolid(integer("0xff" this._bgcolor_))
        if this._bradius_
            Gdip_FillRoundedRectangle(this.gfx, gbrush, 0, 0, this._rect_.w, this._rect_.h, this._bradius_)
        else Gdip_FillRectangle(this.gfx, gbrush, 0, 0, this._rect_.w, this._rect_.h)
        Gdip_DeleteBrush gbrush
    }

    drawimage(_bitmap, _x?, _y?, _w?, _h?, *) =>
        Gdip_DrawImage(this.gfx, _bitmap, _x ?? 0, _y ?? 0, _w ?? this.rect.w, _h ?? this.rect.h)

    drawrect(_argb, _rect, _bradius:=0, *) {
        gbrush := Gdip_BrushCreateSolid(integer( "0x" _argb ))
        if this._bradius_
            Gdip_FillRoundedRectangle(this.gfx, gbrush, _rect.x, _rect.y, _rect.w, _rect.h, _bradius)
        else Gdip_FillRectangle(this.gfx, gbrush, _rect.x, _rect.y, _rect.w, _rect.h)
        Gdip_DeleteBrush gbrush
    }

    drawtext(_text, _opts, _width, _height, _font:="Consolas", _measure:=0) {
        Gdip_TextToGraphics(this.gfx, _text, _opts, _font, _width, _height, _measure)
    }

    clear(*) => Gdip_GraphicsClear(this.gfx)

    show(_opts:="", _args*) {
        ; if !this._is_init_
        ;     return this._first_show_()
        super.show(this.coordstring " " _opts, _args*)
    }
}

/**

ggui := gdipui()
ggui.show("NA")
ggui.openctx()
ggui.drawimage(Gdip_BitmapFromHWND(winexist("ahk_exe wezterm-gui.exe")))
(ggui.updatelayeredwindow)()
ggui.closectx()

^#e::ExitApp

*/
