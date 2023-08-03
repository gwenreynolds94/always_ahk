; main.ahk

#Requires AutoHotkey v2.0
#Warn All, OutputDebug
#Warn LocalSameAsGlobal, OutputDebug
#SingleInstance Force

outputdebug A_Hour "." A_Min "." A_Sec "." A_MSec "`n" . "
(ltrim
    |>|>|>|>|>__always_ahk__|>|>|>|>|>__starting__|>|>|>|>|>
)"

setwindelay 0

#Include <builtins_extended>
#Include <config_tool>
#Include <wincache>
#Include <wintrans>
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
        this.edit_ktblgen_gui := conf_tool.section_edit(this, "ktblgen", "bool")
        this.edit_ktblapp_gui := conf_tool.section_edit(this, "ktblapp", "bool")
        this.edit_misc_gui := conf_tool.section_edit(this, "misc", "string")
    }

    misc => this.ini.misc
    enabled => this.ini.enabled
    ktblgen => this.ini.ktblgen
    ktblmisc => this.ini.ktblapp
}

__always_config.config_defaults := Map(
    "enabled", Map(
        "fuck_cortana"    , true ,
        "bcv2_on_startup" , true ,
    ),
    "ktblgen", Map(
        "leadercaps"       , true ,
        "firefox"          , true ,
        "winmode"          , true ,
        "winleader"        , true ,
        "default"          , true ,
    ),
    "ktblapp", Map(
        "wezterm"         , true ,
        "death_stranding" , true ,
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
            * @prop {kileader} wkl
            */
         , wkl:= kileader("LAlt & Space")
           /**
            * @prop {object} anims
            */
         , anims:= {         _:0
               ,           full: []
               ,        left_full: []
               ,    left_half_left: []
               ,   right_half_left: []
               ,  right_half_right: []
               ,   left_half_right: []
               ,       right_full: []
               ,       misc_anim: vector4.rect()
               ,        margins: vector4.rect(5, 5, 5, 5)
               ,       bounds: vector4.rect()
               ,    slide: winwiz.slide()
           }

    static __new() {
        anims:=this.anims
        marg := anims.margins
        anim_full:=anims.full:=[anims.misc_anim.set(marg.x ,marg.y - A_ScreenHeight, (a_screenwidth - marg.x - marg.w) , ((2 * a_screenheight) - marg.y - marg.h))*]
        anim_btm_full:=anims.btm_full:=[anims.misc_anim.set(marg.x, marg.y, a_screenwidth - marg.x - marg.w, a_screenheight - marg.y - marg.h)*]
        anim_btm_half_left:=anims.btm_half_left:=[anims.misc_anim.mul(1,1,0.5,1).sub(0,0,(marg.x + marg.w) / 2,0)*]
        anim_btm_half_right:=anims.btm_half_right:=[anims.misc_anim.add(anims.btm_half_left[3],0,0,0)*]
        anim_top_half_right:=anims.top_half_right:=[anims.misc_anim.sub(0,a_screenheight,0,0)*]
        anim_top_half_left:=anims.top_half_left:=[anims.misc_anim.sub(anims.top_half_right[3],0,0,0)*]
        anim_top_full:=anims.top_full:=[anims.misc_anim.set(anims.btm_full*).sub(0,a_screenheight,0,0)*]

        kt := this.kt
        kt.hotifexpr := (*)=>(!!__k.ktblgen.default)

        kt.dblki("$XButton2", wintrans.tgui.inst.bmtoggle, 244, "{XButton2}")
        kt.hotki("XButton2 & LButton", winwiz.bm.loopwindows.bind(false, "", false, false))
        kt.hotki("XButton2 & RButton", winwiz.bm.loopwindows.bind(true, "", false, false))
        kt.hotki("XButton2 & MButton", ((*)=>(winactivate(twin:=winwiz.winfromzoffset[4]))))

        kt.dblki("$XButton1", "{Ctrl Down}c{Ctrl Up}", 244, "{XButton1}")
        kt.hotki("XButton1 & LButton", "{Ctrl Down}v{Ctrl Up}")
        kt.hotki("XButton1 & RButton", "{Ctrl Down}x{Ctrl Up}")

;        kt.hotki("AppsKey & RShift", winwiz.bm.loopwindows.bind(false, "" false, false))
;        kt.hotki("AppsKey &  RCtrl", winwiz.bm.loopwindows.bind(true, "" false, false))
        kt.hotki("#LButton", winwiz.swaponpress.bind("LButton"))
        kt.hotki("<#f", wintrans.fade.bm.stepactive.bind(true))
        kt.hotki("<!<#f", wintrans.fade.bm.stepactive.bind(false))
        kt.hotki "<^<#f", wintrans.tgui.inst.bmtoggle
        kt.hotki "~<+<#f", wintrans.bm.removeactivestep
        ; kt.hotki "~Alt & /", ((*)=>(winactivate(winwiz.winfromzoffset[2,,!!GetKeyState("Shift")])))
;; ; ;; ; When MWB hooks into the keyboard/mouse, hotkeys don't work on other computers, 
;; ; ;; ; ;; ; so no hooking hotkeys set in MWB (CTRL+ALT+[F1,F2,F3,F4], etc.)
;; ;        kt.hotki "sc029 & Left", (*)=>(keywait("sc029"), send("{Ctrl Down}{Alt Down}{F1}{Alt Up}{Ctrl Up}"))
;; ;        kt.hotki "sc029 & Down", (*)=>(keywait("sc029"), send( "{Ctrl Down}{Alt Down}{F3}{Alt Up}{Ctrl Up}"))
;; ;        kt.hotki "sc029 & Right", (*)=>(keywait("sc029"), send( "{Ctrl Down}{Alt Down}{F4}{Alt Up}{Ctrl Up}"))
;; ;        kt.hotki "sc029 & LButton", (*)=>(keywait("sc029"), send( "{Ctrl Down}{Alt Down}{F1}{Alt Up}{Ctrl Up}"))
;; ;        kt.hotki "sc029 & MButton", (*)=>(keywait("sc029"), send( "{Ctrl Down}{Alt Down}{F3}{Alt Up}{Ctrl Up}"))
;; ;        kt.hotki "sc029 & RButton", (*)=>(keywait("sc029"), send( "{Ctrl Down}{Alt Down}{F4}{Alt Up}{Ctrl Up}"))


        winwiz.drag.setholdtomove("!+LButton")
        winwiz.drag.setholdtosize("!+RButton")

        kl := this.kl
        kl.hotifexpr := (*)=>( !!__k.ktblgen.leadercaps)

        kl.pathki(["t", "w", "e"], wez.kt.bm.toggle)
        kl.pathki(["a", "h", "h"], winwiz.bm.searchv2docs.bind(0, 0))
        kl.pathki(["a", "h", "+h"], winwiz.bm.searchv2docs.bind(0, 1))
        kl.pathki(["a", "o", "t"], (*)=>(wincache["A"].alwaysontop := 1))
        kl.pathki(["n", "o", "t"], (*)=>(wincache["A"].alwaysontop := 0))
        kl.pathki(["k", "l", "l"], winwiz.bm.winkillclass.bind("", 2))

        kl.pathki(["o", "e", "n", "v"], sys.bm.launch_env_vars)
        kl.pathki(["o", "e", "n", "p"], sys.bm.launch_env_path)

        kl.progki(["o", "w", "e"], "wezterm-gui.exe")
        kl.progki(["o", "f", "f"], "firefox.exe")
        kl.progki(["o", "l", "s"], "Logseq.exe")
        kl.progki(["o", "i", "t"], "iTunes.exe")

        kl.progki(["o", "b", "c", "b"], (A_ScriptDir "\Apps\BCV2\BCV2.exe On"))
        kl.progki(["k", "b", "c", "b"], (A_ScriptDir "\Apps\BCV2\BCV2.exe Off"))


        kl.fflinkki(["l", "p", "a", "y"], "paypal.com")
        kl.fflinkki(["l", "t", "x", "t"], "textnow.com")
        kl.fflinkki(["l", "y", "o", "u"], "youtube.com")
        kl.fflinkki(["l", "d", "d", "g"], "duckduckgo.com")

        
        wkl := this.wkl
        wkl.hotifexpr := (*)=>(!!__k.ktblgen.winleader)
        wkl.pathki( ["Space" , "AppsKey" ], anims.slide.bm.call.bind(anims.full     ) )
        wkl.pathki( ["Space" , "." ], anims.slide.bm.call.bind(anims.btm_full       ) )
        wkl.pathki( ["Space" , "," ], anims.slide.bm.call.bind(anims.btm_half_left  ) )
        wkl.pathki( ["Space" , ";" ], anims.slide.bm.call.bind(anims.top_full       ) )
        wkl.pathki( ["Space" , "/" ], anims.slide.bm.call.bind(anims.btm_half_right ) )
        wkl.pathki( ["Space" , "l" ], anims.slide.bm.call.bind(anims.top_half_left  ) )
        wkl.pathki( ["Space" , "'" ], anims.slide.bm.call.bind(anims.top_half_right ) )



        ffkt := this.ffkt
        ffkt.hotifexpr := (*)=>(WinActive("ahk_exe firefox.exe") and !!__k.ktblgen.firefox)
        ffkt.hotki("XButton1 & XButton2", "{Ctrl Down}{PgUp}{Ctrl Up}")
        ffkt.hotki("XButton2 & XButton1", "{Ctrl Down}{PgDn}{Ctrl Up}")

        knto := this.knto
        knto.hotifexpr := (*)=>(!!__k.ktblgen.winmode)

        knto.hotki(",", winwiz.bm.loopwindows.bind(0,"",0,0))
        knto.hotki(".", winwiz.bm.loopwindows.bind(1,"",0,0))
        knto.hotki(";", wintrans.fade.bm.stepall.bind(true))
        knto.hotki("'", wintrans.fade.bm.stepall.bind(false))
        knto.hotki("!;", wintrans.fade.bm.setall.bind(255))

        ; knto.hotki "AppsKey", (*)=>(winactivate(winwiz.winfromzoffset[2,,!!(GetKeyState("Shift", "P"))]))

        kt.hotki("AppsKey & /", this.knto.bm.toggle)



        coordmode "tooltip", "screen"
    }
}

class dskt extends kitable {

    /**
     * @prop {dskt} instance
     */
    static bm := {
            toggle_forward : objbindmethod(this, "toggle_forward")
        }
        , _moving_forward := false
        , _holding_left := false
        , _holding_right := false
        , instance := this()

    static toggle_forward(*) {
        if (this._moving_forward:=!this._moving_forward)
            send "{w Down}"
        else send("{w Up}")
    }

    static toggle_leftrighthold(*) {
        if not (this._holding_left and this._holding_right) {
            this._holding_left := this._holding_right := true
        }
        else {
            this._holding_left := this._holding_right := false
            ; ...
        }
    }

    __new() {
        super.__new()
        this.hotifexpr := (*)=>(winactive("ahk_exe ds.exe") and !!__k.ktblmisc.death_stranding)
        this.hotki "MButton", "{LButton Down}{RButton Down}"
        this.hotki "MButton Up", "{RButton Up}{LButton Up}"
        this.hotki "!q", dskt.bm.toggle_forward
        this.hotki "w", ((*)=>(send("{w Down}")))
        this.hotki "w Up", ((*)=>(send("{w Up}"), dskt._moving_forward:=false))
        this.hotki "XButton1", "{w}"
        this.dblki "XButton2", ((*)=>(send("{Shift Down}"),sleep(20),send("{Shift Up}"))), 245, dskt.bm.toggle_forward
        this.hotki "XButton1 Up", "{w Up}"
    }
}

class wez {
    /**
     * @prop {kitable} kt
     */
   static kt := {}
        , kl := {}

    static __new() {

        kt := this.kt := kitable()
        kt.hotifexpr := (*)=>(WinActive("ahk_exe wezterm-gui.exe") and !!__k.ktblmisc.wezterm)


        kt.hotki("XButton1", "{Ctrl Down}o{Ctrl Up}")
        kt.dblki("XButton2", wintrans.tgui.inst.bmtoggle, 242, "{Ctrl Down}i{Ctrl Up}")
        kt.hotki("XButton1 & XButton2", "{Ctrl Down}{PgDn}{Ctrl Up}")
        kt.hotki("XButton2 & XButton1", "{Ctrl Down}{PgUp}{Ctrl Up}")
        kt.hotki("~XButton1", "{XButton1}")
        kt.hotki("~XButton2", "{XButton2}")
        kt.hotki("XButton2 & XButton1", "{Ctrl Down}{PgUp}{Ctrl Up}")
        ; kt.hotki("XButton2 & LButton", winwiz.bm.loopwindows.bind(false, this.wintitle, true, false))
        ; kt.hotki("XButton2 & RButton", winwiz.bm.loopwindows.bind(true, this.wintitle, true, false))
        kt.dblki("~LAlt & RAlt", "{Ctrl Down}[{Ctrl Up}:", 300, "{Ctrl Down}[{Ctrl Up}")
        kt.hotki("*AppsKey", "{F13}")
        kt.hotki("!CapsLock", "{F13}")

;        kl := this.kl := kileader(">^AppsKey",, false,,kt.hotifexpr)
;        kl.hotki("RCtrl", winwiz.bm.loopwindows.bind(true, this.wintitle, false, false))
    }
}

class on_main_start {
    static bm := {
            start_bcv2: objbindmethod(this, "start_bcv2")
        }

    static __new() {
        gen.kt.enabled := true
        gen.kl.enabled := true
        gen.wkl.enabled := true
        gen.ffkt.enabled := true
        volctrl.wheel_enabled := true
        wez.kt.enabled := true
        wez.kl.enabled := true

        hotkey "sc029 & r", (*)=>(keywait("sc029", "T2"), reload())
        hotkey "sc029 & e", (*)=>(keywait("sc029", "T2"), __k.edit_enabled_gui.bm.toggle())
        hotkey "sc029 & q", (*)=>exitapp()
        hotkey "sc029 & h", (*)=>ListHotkeys()
        hotkey "sc029 & 1", __k.edit_ktblgen_gui.bm.toggle
        hotkey "sc029 & 2", __k.edit_ktblapp_gui.bm.toggle
        hotkey "sc029 & 3", __k.edit_misc_gui.bm.toggle
        hotkey "$sc029", (*)=>(send("{sc029}"))
        hotkey "$+sc029", (*)=>(send("{Shift Down}{sc029}{Shift Up}"))
        if !!__k.enabled.bcv2_on_startup
            this.start_bcv2
    }

    static start_bcv2(*) {
        if not processexist("BCV2.exe")
            Run(A_ScriptDir "\Apps\BCV2\BCV2.exe On")
    }
}



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
