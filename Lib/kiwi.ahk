; kiwi.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

class kiwi {
    static previd := 0
    id := 0,
    timeout := 0,
    hotifexpr := 0,
    oneshot := 0,
    child_timeout := 0

    __new(_timeout, _hotifexpr, _oneshot, _child_timeout) {
        this.id := ++kiwi.previd
    }
}
