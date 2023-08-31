; apptree.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <winwiz>
#Include <gdip\jdip>

class wintree {
    static bgcolor := "1f2f30"
        ,  sidebar := wintree._sidebar_()
        ,  preview := wintree._preview_()
        ,  width := 500
        ,  pscale := 0.4
    static __new(_width:=500, _bgcolor:="1f2f30") {
        this.sidebar._bgcolor_ := _bgcolor or this.bgcolor
        this.sidebar.rect.set(0, 0, _width or this.width, A_ScreenHeight)
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
            this.hwnds := wingetlist()
            this.windows.Capacity := 0
            prevrect := false
            for _hwnd in this.hwnds {
                _bm := Gdip_BitmapFromHWND(_hwnd)
                _bmw := Gdip_GetImageWidth(_bm)
                _bmh := Gdip_GetImageHeight(_bm)
                _rect := !prevrect ? (prevrect:=vector4.Rect(10,10, _bmw * 0.1, _bmh * 0.1))
                                   : (prevrect.add(0, prevrect.h + 10))
                this.windows.push({
                    rect : vector4.Rect(_rect*)
                  , hwnd : _hwnd
                  , bm   : _bm
                })
            }
        }
        drawlist(*) {
            this.openctx
            this.drawbg
            loop 3 {
                _win := this.windows[A_Index]
                this.drawbitmap(_win.bm, _win.rect*)
            }
            (this.updatelayeredwindow)()
            this.closectx
        }
        show(*) {
            super.show()
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
    wintree.sidebar.drawlist
    wintree.show()
}
8::{
    wintree.hide()
}
