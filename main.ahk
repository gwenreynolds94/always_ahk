; main.ahk

#Requires AutoHotkey v2.0
#Warn All, OutputDebug
#Warn LocalSameAsGlobal, OutputDebug
#SingleInstance Force

outputdebug "
(ltrim
    |>|>|>|>|>__always_ahk__|>|>|>|>|>__starting__|>|>|>|>|>
)"

setwindelay 0

#Include <builtins_extended>
#Include <config_tool>
#Include <winwiz>
#Include <kitable>
#Include <quiktip>
#Include <volctrl>
#Include <sys>


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
    static kt:= kitable()
           /**
            * @prop {kileader} kl
            */
         , kl:= kileader("CapsLock")
           /**
            * @prop {kitable} ffkt
            */
         , ffkt:= kitable()
           /**
            * @prop {kitable} knto
            */
         , knto:= kitable()
           /**
            * @prop {object} anims
            */
         , anims:= {_:0
               ,           full: []
               ,       left_full: []
               ,   left_half_left: []
               ,  right_half_left: []
               , right_half_right: []
               ,  left_half_right: []
               ,      right_full: []
               ,       misc_anim: vector4.rect()
               ,          slide: winwiz.slide()
           }

    static __new() {
        anims:=this.anims
        anim_full:=anims.full:=[anims.misc_anim.set(5,5,a_screenwidth*2-10,a_screenheight-10)*]
        anim_left_full:=anims.left_full:=[anims.misc_anim.set(5,5,a_screenwidth-10,a_screenheight-10)*]
        anim_right_full:=anims.right_full:=[anims.misc_anim.set(anim_left_full*).add(a_screenwidth,0,0,0)*]
        anim_left_half_left:=anims.left_half_left:=[anims.misc_anim.set(anim_left_full*).mul(1,1,0.5,1)*]
        anim_left_half_right:=anims.left_half_right:=[anims.misc_anim.set(anim_left_half_left*).add(anim_left_half_left[3],0,0,0)*]
        anim_right_half_left:=anims.right_half_left:=[anims.misc_anim.set(anim_left_half_left*).add(a_screenwidth,0,0,0)*]
        anim_right_half_right:=anims.right_half_right:=[anims.misc_anim.set(anim_left_half_right*).add(a_screenwidth,0,0,0)*]

        kt := this.kt

        kt.hotki("XButton2 & LButton", winwiz.bm.loopwindows.bind(false, "", false, false))
        kt.hotki("XButton2 & RButton", winwiz.bm.loopwindows.bind(true, "", false, false))
        kt.hotki("XButton2 & MButton", ((*)=>(winactivate(twin:=winwiz.winfromzoffset[4]))))
        kt.hotki("$XButton2", "{XButton2}")
        kt.dblki("$XButton1", (*)=>(send("{Ctrl Down}c{Ctrl Up}")), 200, ((*)=>send("{XButton1}")))
        kt.hotki("XButton1 & LButton", "{Ctrl Down}v{Ctrl Up}")
        kt.hotki("XButton1 & RButton", "{Ctrl Down}x{Ctrl Up}")
        kt.hotki("AppsKey & RShift", winwiz.bm.loopwindows.bind(false, "" false, false))
        kt.hotki("AppsKey & RCtrl", winwiz.bm.loopwindows.bind(true, "" false, false))
        kt.hotki("#LButton", winwiz.swaponpress.bind("LButton"))

        winwiz.drag.setholdtomove("!+LButton")
        winwiz.drag.setholdtosize("!+RButton")

        kl := this.kl

        kl.pathki(["w", "w"], anims.slide.bm.call.bind(anims.full          ))
        kl.pathki(["w", "q"], anims.slide.bm.call.bind(anims.left_full      ))
        kl.pathki(["w", "e"], anims.slide.bm.call.bind(anims.right_full     ))
        kl.pathki(["w", "a"], anims.slide.bm.call.bind(anims.left_half_left  ))
        kl.pathki(["w", "s"], anims.slide.bm.call.bind(anims.left_half_right ))
        kl.pathki(["w", "d"], anims.slide.bm.call.bind(anims.right_half_left ))
        kl.pathki(["w", "f"], anims.slide.bm.call.bind(anims.right_half_right))

        kl.pathki(["t", "w", "e"], wez.kt.bm.toggle)
        kl.pathki(["a", "h", "h"], winwiz.bm.searchv2docs.bind(0, 0))
        kl.pathki(["a", "h", "+h"], winwiz.bm.searchv2docs.bind(0, 1))
        kl.pathki(["a", "o", "t"], (*)=>(wincache["A"].alwaysontop := 1))
        kl.pathki(["n", "o", "t"], (*)=>(wincache["A"].alwaysontop := 0))
        kl.pathki(["k", "l", "l"], winwiz.bm.winkillclass.bind("", 2))
        kl.progki(["o", "w", "e"], "wezterm-gui.exe")
        kl.progki(["o", "f", "f"], "firefox.exe")
        kl.progki(["o", "b", "c", "b"], A_ScriptDir "\Apps\BCV2\BCV2.exe")

        ffkt := this.ffkt
        ffkt.hotifexpr := ((*)=>WinActive("ahk_exe firefox.exe"))
        ffkt.hotki("XButton1 & XButton2", "{Ctrl Down}{PgUp}{Ctrl Up}")
        ffkt.hotki("XButton2 & XButton1", "{Ctrl Down}{PgDn}{Ctrl Up}")

        knto := this.knto
        knto.timeout := 60 * 1000

        knto.hotki(",", winwiz.bm.loopwindows.bind(0,"",0,0))
        knto.hotki(".", winwiz.bm.loopwindows.bind(1,"",0,0))

        kt.hotki("AppsKey & \", this.knto.bm.toggle)

        coordmode "tooltip", "screen"
    }

    swapwindowdims(*) {
         
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
        kt.hotki("$XButton1", "{Ctrl Down}o{Ctrl Up}")
        kt.hotki("$XButton2", "{Ctrl Down}i{Ctrl Up}")
        ; kt.hotki("XButton2 & LButton", winwiz.bm.loopwindows.bind(false, this.wintitle, true, false))
        ; kt.hotki("XButton2 & RButton", winwiz.bm.loopwindows.bind(true, this.wintitle, true, false))
        kt.dblki("LAlt & RAlt", "{Ctrl Down}[{Ctrl Up}:", 300, "{Ctrl Down}[{Ctrl Up}")
        kt.hotki("AppsKey", "{F13}")
        kt.hotki("!CapsLock", "{F13}")

;        kl := this.kl := kileader(">^AppsKey",, false,,kt.hotifexpr)
;        kl.hotki("RCtrl", winwiz.bm.loopwindows.bind(true, this.wintitle, false, false))
    }
}

gen.kt.enabled := true
gen.kl.enabled := true
gen.ffkt.enabled := true
volctrl.wheel_enabled := true
wez.kt.enabled := true
wez.kl.enabled := true

hotkey "<#sc029", (*)=>(keywait("LWin", "T2"), reload())
hotkey "^#0", (*)=>exitapp()


;;  class __s {

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
