; .scratch.1.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <DEBUG\jk_debug>

key := "$XButton1"


onxbtn1(*) {
    static triggered := 0
        ,  onxbtn1to := onxbtn1timeout.bind(&triggered)
        ,  timeout := 100
        ,  ostr := ""
    onxbtn1timeout(&_triggered, *) {
        ostr := "timeout`n" ostr
        if _triggered = 1
            send("{XButton1}"), ostr := "sent`n" ostr
        _triggered := 0
        settimer(,0)
        tooltip ostr
    }
    ostr := "xbtn1`n" ostr
    triggered++
    if triggered > 1
        msgbox("dblclk"), settimer(onxbtn1to,triggered:=0), ostr := "dblclk`n" ostr
    else settimer(onxbtn1to, timeout.neg()), ostr := "settimer`n" ostr

    tooltip ostr
}

asd := [1,2,43,567]
qwe := 666
zcx := 0
ert := ""

for _var in [asd, [qwe], [zcx], [ert]]
    dbgln(_var*)
