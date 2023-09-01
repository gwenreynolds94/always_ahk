; apptree.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <builtins_extended>
#Include <winwiz>
#Include <gdip\jdip>

class wintree {
    static bgcolor := "1f2f30"
        ,  sidebar := wintree._sidebar_()
        ,  preview := wintree._preview_()
        ,  width := 500
        ,  pscale := 0.4
        ,  tbmargin := 16
        ,  tbwidth := 200
        ,  tbhlwidth := 4
        ,  tbhlcolor := 'ffaaddff'
    static __new(_tbwidth:=500, _bgcolor:="1f2f30") {
        this.sidebar._bgcolor_ := _bgcolor or this.bgcolor
        this.tbwidth := _tbwidth or this.tbwidth
        this.sidebar.rect.set(0, 0, (_tbwidth or this.tbwidth) + (this.tbmargin * 2), A_ScreenHeight)
        this.preview.rect.set(this.sidebar.rect.w, 0, A_ScreenWidth * this.pscale, A_ScreenHeight * this.pscale)
    }
    static show() {
        this.sidebar.show()
    }
    static hide() {
        this.sidebar.hide()
    }
    class _sidebar_ extends gdipui {
        hwnds := []
        windows := []
        __new() {
            super.__new(,"wintree.ahk.sidebar",,,, this)
        }
        updatelist(*) {
            this.hwnds := winwiz.winlist
            this.windows.Capacity := 0
            prevrect := false
            this.openctx
            this.drawbg
            for _hwnd in this.hwnds {
                wbm := GdipBitmap.FromHwnd(_hwnd)
                _rect := !prevrect ? (prevrect:=vector4.Rect(wintree.tbmargin,wintree.tbmargin, wbm.w * 0.1, wbm.h * 0.1))
                                   : (prevrect.add(0, prevrect.h + wintree.tbmargin))
                this.windows.push({
                    rect : vector4.Rect(_rect*)
                  , hwnd : _hwnd
                  , bm   : wbm
                })
                this.drawimage(wbm._bm_, _rect*)
            }
            (this.updatelayeredwindow)()
            this.closectx
        }
        show(*) {
            super.show()
        }
        class thumbnail {
            hwnd := 0x0
            __new(_hwnd) {
                this.hwnd := _hwnd
            }
        }
    }
    class _preview_ extends gdipui {
        __new() {
            super.__new(,"wintree.ahk.preview",,,, this)
        }
    }
}


0::ExitApp
7::Reload
9::{
    wintree.sidebar.updatelist
    wintree.show()
}
8::{
    wintree.hide()
}
