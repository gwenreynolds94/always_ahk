; .scratch.1.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <DEBUG\jk_debug>

class asd {
    qwe := "xvxcvxcv"
    __new() {
        this.qwe := 678
    }
}

asdasd:=asd()
asdasd.qwe := 666

dbgln({__o__:1,nestlvlmax:8}, asd.Prototype.Base)

