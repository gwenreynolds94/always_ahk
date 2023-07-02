; uncertainty.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include DEBUG\jk_debug.ahk

class randy {
    class any {
        class char {
            static _alpha_str := "abcdefghijklmnopqrstuvwxyz"
                ,  _num_str   := "0123456789"
                ,  _alnum_str := this._alpha_str . this._num_str
            
            static alpha => this._alpha_str.Sub(Random(1, this._alpha_str.Length()), 1)
            static   num =>   this._num_str.Sub(Random(1, this._num_str.Length())  , 1)
            static alnum => this._alnum_str.Sub(Random(1, this._alnum_str.Length()), 1)
        }
    }
}


