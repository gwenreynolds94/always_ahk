; drowzi.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include builtins_extended.ahk

class drowzi {
    sleep_dur := 1
    period := 3
    iterations := 666
    tickstart := 0

    __new(_iterations, _sleep_dur:=1, _time_period:=5) {
        this.sleep_dur := _sleep_dur
        this.period := _time_period
        this.iterations := _iterations
        this.tickstart := A_TickCount
    }

    bmbegin => dllcall.bind("timeBeginPeriod", "UInt")
    bmend   => dllcall.bind("timeEndPeriod", "UInt")
    bmsleep => dllcall.bind("Sleep", "UInt")

    sleep(_duration?)=>(this.bmsleep.bind(_duration ?? this.sleep_dur))
    begin(_period?)=>(this.bmbegin.bind(_period ?? this.period))
    end(_period?)=>(this.bmend.bind(_period ?? this.period))
}
