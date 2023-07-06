; main.ahk

#Requires AutoHotkey v2.0
#Warn All, OutputDebug
#Warn LocalSameAsGlobal, OutputDebug
#SingleInstance Force

outputdebug "
(ltrim
    |>|>|>|>|>__always_ahk__|>|>|>|>|>__starting__|>|>|>|>|>
)"

#Include <builtins_extended>
#Include <config_tool>
#Include <winwiz>
#Include <kitable>
#Include <quiktip>
#Include <volctrl>


exitaction(_exit_reason:="", *) {
    quiktray _exit_reason "ing...", "<always_ahk.main>", 1750
    sleep 1750
} onexit exitaction


Class __always_config extends conf_tool {
    /**
     * @prop {Map} config_defaults
     */
    static config_defaults := Map()

    edit_enabled_gui := {}

    __New() {
        super.__New(".\.ahkonf", __always_config.config_defaults)
        this.validate()
        this.edit_enabled_gui := conf_tool.section_edit(this, "Enabled", "bool")
    }

    enabled => this.ini.enabled
    misc => this.ini.misc
}

Class __s {
    static __new() {
    }
}

__always_config.config_defaults := Map(
    "enabled", Map(
        "fuck_cortana", true,
        "armored_core", true,
        "fallout"     , true
    ),
    "misc", Map(
        "fuck_cortana_interval", 6666,
    )
)

/**
 * #### `__k` for **konfiguration**
 * Interface to get and set .ini style configurations in an .ahkonf file
 */
__k := __always_config()


class fuck_cortana {
    static bound_fucks := { fuck_off: {} }

    static __New() {
        this.bound_fucks.fuck_off := ObjBindMethod(this, "fuck_off")
        SetTimer this.bound_fucks.fuck_off, Abs(__k.misc.fuck_cortana_interval)
    }

    static fuck_off() {
        if __k.enabled.fuck_cortana
            if processexist("Cortana.exe")
                processclose("Cortana.exe")
    }
}

class gen {
           /**
            * @prop {kitable} kt
            */
    static kt := {},
           /**
            * @prop {kileader} kl
            */
           kl := {}

    static __new() {


        kt := this.kt := kitable()


        kt.hotki("XButton2 & LButton", winwiz.bm.loopwindows.bind(false, "", false))
        kt.hotki("XButton2 & RButton", winwiz.bm.loopwindows.bind(true, "", false))
        kt.hotki("XButton2 & MButton", ((*)=>(winactivate(twin:=winwiz.winfromzoffset[4]))))
        kt.hotki("$XButton2", "{XButton2}")
        kt.dblki("$XButton1", quiktool.call.bind(quiktool, "dbl", {}, 2250), 200, ((*)=>send("{XButton1}")))

        kl := this.kl := kileader("CapsLock")
        kl.hotki("w", wez.kt.bm.toggle)
        kl.pathki(["a", "h", "h"], winwiz.bm.searchv2docs.bind(0, 0))
        kl.pathki(["a", "h", "+h"], winwiz.bm.searchv2docs.bind(0, 1))
        kl.pathki(["k", "l", "l"], winwiz.bm.winkillclass.bind("", 2))
        kl.progki(["o", "w", "e"], "wezterm-gui.exe")
        kl.progki(["o", "f", "f"], "firefox.exe")
;        kl.focuski(["f", "f", "x"], "ahk_exe firefox.exe")

        coordmode "tooltip", "screen"
    }
}

class wez {
    /**
     * @prop {kitable} kt
     */
   static kt := {}
        , kl := {}
        , wintitle := "ahk_exe wezterm-gui.exe"

    static __new() {

        kt := this.kt := kitable()
        kt.hotifexpr := (*)=>WinActive(this.wintitle)


        kt.hotki("XButton1 & XButton2", "{Ctrl Down}{PgDn}{Ctrl Up}")
        kt.hotki("XButton2 & XButton1", "{Ctrl Down}{PgUp}{Ctrl Up}")
        kt.hotki("XButton2 & LButton", winwiz.bm.loopwindows.bind(false, this.wintitle, false))
        kt.hotki("XButton2 & RButton", winwiz.bm.loopwindows.bind(true, this.wintitle, false))
        kt.dblki("LAlt & RAlt", "{Ctrl Down}[{Ctrl Up}", 300, "{Ctrl Down}[{Ctrl Up}:")

        kt.hotki("AppsKey", "{F13}")
        kt.hotki("!CapsLock", "{F13}")

        kl := this.kl := kileader(">^AppsKey",, false,,kt.hotifexpr)
        kl.hotki("RCtrl", winwiz.bm.loopwindows.bind(true, this.wintitle, false))
    }
}

gen.kt.enabled := true
gen.kl.enabled := true
volctrl.wheel_enabled := true
wez.kt.enabled := true
wez.kl.enabled := true

hotkey "<#sc029", (*)=>(keywait("LWin", "T2"), reload())
hotkey "^#0", (*)=>exitapp()

;;  class __s {
;;      static keys := Map()
;;
;;      static __new() {
;;          this.keys["gen"] := kitable(unset,unset,true,2000)
;;          this.keys["tst"] := kitable()
;;          this.keys["fallout"] := kitable(unset, ((*)=>WinActive("ahk_exe falloutwHR.exe")))
;;      }
;;
;;      static kgen => this.keys["gen"]
;;      static ktst => this.keys["tst"]
;;      static kfo  => this.keys["fallout"]
;;  }
;;
;;
;;  __s.kgen.hotki("LAlt & RCtrl", (*)=>Tooltip(A_TickCount))
;;
;;
;;  __s.ktst.hotki("<^>^Up", (*)=>ToolTip("^^^"))
;;  __s.ktst.hotki("<^>^Down", (*)=>ToolTip("vvv"))
;;
;;
;;  __s.kfo.hotki("XButton1 & LButton", "{Shift Down}{LButton}{Shift Up}")
;;  __s.kfo.hotki("XButton1 & RButton", "p")
;;  __s.kfo.hotki("XButton1 & MButton", "{Tab}")
;;
;;  __s.kfo.hotki("XButton2 & LButton", "i")
;;  __s.kfo.hotki("XButton2 & RButton", "{Escape}")
;;  __s.kfo.hotki("XButton2 & MButton", "c")
;;
;;  __s.kfo.hotki("XButton1 & XButton2", "{Home}")
;;  __s.kfo.hotki("XButton2 & XButton1", "s")
;;
;;
;;  __s.kgen.enabled := true
;;  __s.ktst.enabled := true
;;  __s.kfo.enabled := true
;;
;;  Hotkey "LAlt & AppsKey", (*)=>(__s.kgen.enabled := true)
