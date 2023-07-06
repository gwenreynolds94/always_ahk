; volctrl.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include DEBUG\jk_debug.ahk
#Include winwiz.ahk

class volctrl {
        /**
         * @prop {Gui} gui
         */
    static gui := {}
        /**
         * @prop {Gui.Progress} progress
         */
        ,  progress := {}
        ,  _hidden_ := true
        ,  initialized := false
        ,  size := { w: 50, h: A_ScreenHeight }
        ,  position := { x: A_ScreenWidth-(this.size.w/2), y: 0 }
        ,  transparency := 215
        ,  orientation := "vertical"
        ,  sound_enabled_color := "c862d2d"
        ,  sound_disabled_color := "c502d2d"
        ,  progress_colors := { enabled : "c862d2d", disabled: "c502d2d" }
        ,  seed := 0
        ,  bm := {hide:{},decrease:{},increase:{}}
        ,  timeout := 2000
        ,  delta_volume := 2
        ,  _wheel_hotif_ := false
        ,  _wheel_enabled_ := false

    static __new() {
        this._wheel_hotif_ := ((*)=>(winwiz.mousewin["class"] ~= "Shell_(Secondary)?TrayWnd"))
        this.gui := gui("-Caption +Owner +AlwaysOnTop", "jkvolctl")
        this.gui.MarginX := this.gui.MarginY := 0
        this.progress := this.gui.add( "Progress", "Smooth"            " "  .
                                                   "range0-100"        " "  .
                                                   "BackgroundAAAAAA"  " "  .
                                                   "w" thiS.size.w     " "  .
                                                   "h" this.size.h     " "  .
                                                   this.orientation    " "  .
                                                   this.sound_enabled_color )
        this.update_progress
        this.update_color
        this.bm.hide := ObjBindMethod(this, "hide")
        this.bm.decrease := ObjBindMethod(this, "decrease")
        this.bm.increase := ObjBindMethod(this, "increase")
    }

    static wheel_enabled {
        get => this._wheel_enabled_
        set {
            if !!Value and !this._wheel_enabled_
                this.enable_wheel
            else if !Value and !!this._wheel_enabled_
                this.disable_wheel
            this._wheel_enabled_ := !!Value
        }
    }

    static enable_wheel(*) {
        hotwhlif := this._wheel_hotif_
        hotif hotwhlif
        hotkey "WheelDown", this.bm.decrease
        hotkey "WheelUp", this.bm.increase
        hotif
    }

    static disable_wheel(*) {
        hotwhlif := this._wheel_hotif_
        hotif hotwhlif
        hotkey "WheelDown", "Off"
        hotkey "WheelUp", "Off"
        hotif
    }

    static show(*) {
        this.update_progress
        this.update_color
        if !!this.hidden {
            guishow_opts := "NA"
            if !this.initialized
                guishow_opts .= " x" this.position.x " y" this.position.y
            this.gui.Show(guishow_opts)
            WinSetTransColor("AAAAAA " this.transparency, this.gui)
            this.initialized := true
            this._hidden_ := false
        }
        settimer this.bm.hide, Abs(this.timeout) * (-1)
    }

    static hide(*) {
        this.gui.Hide()
        this._hidden_ := true
    }

    static hidden => this._hidden_

    static update_color(*) {
        this.progress.Opt(!!SoundGetMute() ? this.sound_disabled_color : this.sound_enabled_color)
    }

    static update_progress(*) {
        this.progress.Value := Round( SoundGetVolume() )
    }

    static increase(*) {
        new_volume := Round(SoundGetVolume() + this.delta_volume)
        new_volume := (new_volume > 100) ? 100 : new_volume
        SoundSetVolume new_volume
        this.show
    }

    static decrease(*) {
        new_volume := Round(SoundGetVolume() - this.delta_volume)
        new_volume := (new_volume < 0) ? 0 : new_volume
        SoundSetVolume new_volume
        this.show
    }
}

