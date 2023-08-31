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
#Include <aktions>
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
    ktblapp => this.ini.ktblapp
}

__always_config.config_defaults := Map(
    "enabled", Map(
        "fuck_cortana"    , true ,
        "bcv2_on_startup" , true ,
        "pcnm_hotstrings" , true ,
    ),
    "ktblgen", Map(
        "leadercaps"       , true ,
        "firefox"          , true ,
        "wezterm"          , true ,
        "winmode"          , true ,
        "winleader"        , true ,
        "debuglead"        , true ,
        "debugtbl"         , true ,
        "default"          , true ,
    ),
    "ktblapp", Map(
        "death_stranding" , true ,
        "dying_light"     , true ,
        "kenshi"          , true ,
        "fallout"         , true ,
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
            * @prop {kitable} antiffkt
            */
         , antiffkt:= kitable()
           /**
            * @prop {kitable} wzkt
            */
         , wzkt := kitable()
           /**
            * @prop {kitable} antiffkt
            */
         , antiwzkt:= kitable()
           /**
            * @prop {kitable} knto
            */
         , knto:= kitable()
           /**
            * @prop {kitable} dlkt
            */
         , dlkt:= kitable()
           /**
            * @prop {kitable} kshkt
            */
         , kshkt:= kitable()
           /**
            * @prop {kitable} dskt
            */
         , dskt:= kitable()
           /**
            * @prop {kitable} fokt
            */
         , fokt:= kitable()
           /**
            * @prop {kileader} wkl
            */
         , wkl:= kileader("LAlt & Space")
           /**
            * @prop {kileader} dbgkl
            */
         , dbgkl:= kileader("sc029 & Space")
           /**
            * @prop {kitable} dbgkt
            */
         , dbgkt:= kitable()
           /**
            * @prop {kitable} scrkt
            */
         , scrkt:= kitable()
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
        anim_btm_half_left:=anims.btm_half_left:=[anims.misc_anim.mul(1,1,0.5,1)*]
        anim_btm_half_right:=anims.btm_half_right:=[anims.misc_anim.add(anims.btm_half_left[3],0,0,0)*]
        anim_top_half_right:=anims.top_half_right:=[anims.misc_anim.sub(0,a_screenheight,0,0)*]
        anim_top_half_left:=anims.top_half_left:=[anims.misc_anim.sub(anims.top_half_right[3],0,0,0)*]
        anim_top_full:=anims.top_full:=[anims.misc_anim.set(anims.btm_full*).sub(0,a_screenheight,0,0)*]

        kt := this.kt
        kt.hotifexpr := (*)=>( !!__k.ktblgen.default and ;
            !winactive("ahk_exe DyingLightGame.exe") and ;
            !winactive("ahk_exe kenshi_x64.exe")     and ;
            !winactive("ahk_exe ds.exe")             and ;
            !winactive("ahk_exe FALLOUTW.exe")           )

        kt.dblki("$XButton2", wintrans.tgui.inst.bmtoggle, 244, "{XButton2}")
        kt.hotki("XButton2 & LButton", winwiz.bm.loopwindows.bind(false, "", false, false))
        kt.hotki("XButton2 & RButton", winwiz.bm.loopwindows.bind(true, "", false, false))
        kt.hotki("XButton2 & MButton", ((*)=>(winactivate(twin:=winwiz.winfromzoffset[4]))))

        kt.dblki("XButton1", "{Ctrl Down}c{Ctrl Up}", 244, "{XButton1}")
        kt.hotki("XButton1 & LButton", "{Ctrl Down}v{Ctrl Up}")
        kt.hotki("XButton1 & RButton", "{Ctrl Down}x{Ctrl Up}")
        kt.hotki("+RButton", "{Shift Down}{RButton}{Shift Up}")
        kt.hotki("AppsKey", "{AppsKey}")

        kt.hotki("#LButton", winwiz.swaponpress.bind("LButton"))
        kt.hotki("<#f", wintrans.fade.bm.stepactive.bind(true))
        kt.hotki("<!<#f", wintrans.fade.bm.stepactive.bind(false))
        kt.hotki "<^<#f", wintrans.tgui.inst.bmtoggle
        kt.hotki "~<+<#f", wintrans.bm.removeactivestep

        winwiz.drag.setholdtomove("!+LButton")
        winwiz.drag.setholdtosize("!+RButton")

        kl := this.kl
        kl.hotifexpr := (*)=>( !!__k.ktblgen.leadercaps)

        kl.pathki( [ "t", "w", "e" ],                     gen.wzkt.bm.toggle )
        kl.pathki( [ "a", "h", "h" ],      winwiz.bm.searchv2docs.bind(0, 0) )
        kl.pathki( [ "a", "h", "+h"],      winwiz.bm.searchv2docs.bind(0, 1) )
        kl.pathki( [ "a", "o", "t" ],  (*)=>(wincache["A"].alwaysontop := 1) )
        kl.pathki( [ "n", "o", "t" ],  (*)=>(wincache["A"].alwaysontop := 0) )
        kl.pathki( [ "k", "l", "l" ],     winwiz.bm.winkillclass.bind("", 2) )
        kl.pathki( [ "m", "n" ], "{Media_Prev}" )
        kl.pathki( [ "m", "m" ], "{Media_Play_Pause}" )
        kl.pathki( [ "m", "," ], "{Media_Next}" )
        kl.hotki "k & CapsLock", (*)=>(WinKill("A"))

        kl.pathki( [ "o", "e", "n", "v" ], sys.bm.launch_env_vars )
        kl.pathki( [ "o", "e", "n", "p" ], sys.bm.launch_env_path )

        kl.progki( [ "o", "w", "e" ], "wezterm-gui.exe" )
        kl.progki( [ "o", "f", "f" ], "firefox.exe"     )
        kl.progki( [ "o", "l", "s" ], "Logseq.exe"      )
        kl.progki( [ "o", "i", "t" ], "iTunes.exe"      )
        kl.progki( [ "o", "p", "t", "o", "y" ], "C:\Program Files\PowerToys\PowerToys.exe" )
        kl.progki( [ "o", "f", "a", "l", "l" ]
                 , "`"Z:\SteamLibrary\steamapps\common\Fallout\Fallout Fixt\Play Fallout Fixt.lnk`"" )

        kl.progki( [ "o", "b", "c", "b" ], (A_ScriptDir "\Apps\BCV2\BCV2.exe On")  )
        kl.progki( [ "k", "b", "c", "b" ], (A_ScriptDir "\Apps\BCV2\BCV2.exe Off") )

        kl.fflinkki( [ "l", "p", "a", "y" ]      , "paypal.com")
        kl.fflinkki( [ "l", "t", "x", "t" ]      , "textnow.com")
        kl.fflinkki( [ "l", "y", "o", "u" ]      , "youtube.com")
        kl.fflinkki( [ "l", "a", "n", "i" ]      , "aniwave.to")
        kl.fflinkki( [ "l", "f", "m", "v" ]      , "fmovies.llc")
        kl.fflinkki( [ "l", "d", "d", "g" ]      , "duckduckgo.com")
        kl.fflinkki( [ "l", "z", "e", "n" ]      , "zenni.com")
        kl.fflinkki( [ "l", "h", "u", "m" ]      , "humblebundle.com")
        kl.fflinkki( [ "l", "g", "m", "l" ]      , "gmail.com")
        kl.fflinkki( [ "l", "h", "u", "l", "u" ] , "hulu.com")
        kl.fflinkki( [ "l", "i", "a", "s", "i",  "p" ]
                   , "https://fmovies.llc/tv/its-always-sunny-in-philadelphia-fmovies-39280")

        wkl := this.wkl
        wkl.hotifexpr := (*)=>(!!__k.ktblgen.winleader)
        wkl.pathki( [".", "."], anims.slide.bm.call.bind(anim.win.rect.presets[1].full  ) )
        wkl.pathki( [".", ","], anims.slide.bm.call.bind(anim.win.rect.presets[1].bot   ) )
        wkl.pathki( [".", "/"], anims.slide.bm.call.bind(anim.win.rect.presets[1].top   ) )
        wkl.pathki( [",", ","], anims.slide.bm.call.bind(anim.win.rect.presets[1].left  ) )
        wkl.pathki( ["/", "/"], anims.slide.bm.call.bind(anim.win.rect.presets[1].right ) )
        wkl.pathki( [",", ";"], anims.slide.bm.call.bind(anim.win.rect.presets[1].lefttop ) )
        wkl.pathki( [",", "."], anims.slide.bm.call.bind(anim.win.rect.presets[1].leftbot ) )
        wkl.pathki( ["/", ";"], anims.slide.bm.call.bind(anim.win.rect.presets[1].righttop ) )
        wkl.pathki( ["/", "."], anims.slide.bm.call.bind(anim.win.rect.presets[1].rightbot ) )
        if sys.mon.count > 1 {
            wkl.pathki( [";", ";"], anims.slide.bm.call.bind(anim.win.rect.presets[2].full  ) )
            wkl.pathki( [";", "l"], anims.slide.bm.call.bind(anim.win.rect.presets[2].bot   ) )
            wkl.pathki( [";", "'"], anims.slide.bm.call.bind(anim.win.rect.presets[2].top   ) )
            wkl.pathki( ["l", "l"], anims.slide.bm.call.bind(anim.win.rect.presets[2].left  ) )
            wkl.pathki( ["'", "'"], anims.slide.bm.call.bind(anim.win.rect.presets[2].right ) )
            wkl.pathki( ["l", ";"], anims.slide.bm.call.bind(anim.win.rect.presets[2].lefttop ) )
            wkl.pathki( ["l", "."], anims.slide.bm.call.bind(anim.win.rect.presets[2].leftbot ) )
            wkl.pathki( ["'", ";"], anims.slide.bm.call.bind(anim.win.rect.presets[2].righttop ) )
            wkl.pathki( ["'", "."], anims.slide.bm.call.bind(anim.win.rect.presets[2].rightbot ) )
        }
        wkl.hotki( "Space & LAlt"   , wkl.root.bm.toggle )

        ffkt := this.ffkt
        ffkt.hotifexpr := (*)=>(WinActive("ahk_exe firefox.exe") and !!__k.ktblgen.firefox)
        ffkt.hotki( "XButton1 & XButton2", "{Ctrl Down}{PgUp}{Ctrl Up}" )
        ffkt.hotki( "XButton2 & XButton1", "{Ctrl Down}{PgDn}{Ctrl Up}" )
        ffkt.hotki "^!LButton", aktions.repeatpress("LButton", 50, 30).toggle

        antiffkt := this.antiffkt

        wzkt := this.wzkt
        wzkt.hotifexpr := (*)=>(WinActive("ahk_exe wezterm-gui.exe") and !!__k.ktblmisc.wezterm)
        wzkt.hotki("XButton1", "{Ctrl Down}o{Ctrl Up}")
        wzkt.dblki("XButton2", wintrans.tgui.inst.bmtoggle, 242, "{Ctrl Down}i{Ctrl Up}")
        wzkt.hotki("XButton1 & XButton2", "{Ctrl Down}{PgDn}{Ctrl Up}")
        wzkt.hotki("XButton2 & XButton1", "{Ctrl Down}{PgUp}{Ctrl Up}")
        wzkt.dblki("LAlt & RAlt", "{F13}", 200, "{Ctrl Down}[{Ctrl Up}")
        wzkt.hotki("LWin & LAlt", "{Ctrl Down}{[}{Ctrl Up}")
        wzkt.hotki("!CapsLock", "{F13}")
        wzkt.hotki("F11", (*)=>(_wlist:=wingetlist("ahk_exe wezterm-gui.exe"), (_wlist.length >= 2) and winactivate(_wlist[2])))
        wzkt.hotki("F12", (*)=>(_wlist:=wingetlist("ahk_exe wezterm-gui.exe"), (_wlist.length >= 2) and winactivate(_wlist[_wlist.Length])))
        antiwzkt := this.antiwzkt

        knto := this.knto
        knto.hotifexpr := (*)=>(!!__k.ktblgen.winmode)

        knto.hotki("q", winwiz.bm.loopwindows.bind(0,"",0,0))
        knto.hotki("e", winwiz.bm.loopwindows.bind(1,"",0,0))
        knto.hotki("w", wintrans.fade.bm.stepall.bind(true))
        knto.hotki("s", wintrans.fade.bm.stepall.bind(false))
        knto.hotki("r", wintrans.fade.bm.setall.bind(255))
        knto.hotki("Escape", (*)=>(this.knto.enabled := false))
        knto.hotki("Backspace", (*)=>(this.knto.enabled := false))
        knto.hotki("Delete", (*)=>(this.knto.enabled := false))

        kt.hotki("sc029 & 1", this.knto.bm.toggle)

        scrkt := this.scrkt
        scrkt.hotki "q", (*)=>( !!(ffhwnd:=winexist("ahk_exe firefox.exe"))
                                ? ControlClick(,ffhwnd,,"WD",1)
                                : false )
        scrkt.hotki "e", (*)=>( !!(ffhwnd:=winexist("ahk_exe firefox.exe"))
                                ? ControlClick(,ffhwnd,,"WU",1)
                                : false )
        kt.hotki("sc029 & 2", this.scrkt.bm.toggle)

        kshkt := this.kshkt
        kshkt.hotifexpr := (*)=>( !!winactive("ahk_exe kenshi_x64.exe") and !!__k.ktblapp.kenshi )
        kshkt.hotki "XButton2", "m"
        kshkt.hotki "XButton2 & LButton", "b"
        kshkt.hotki "XButton1", "{Space}"
        kshkt.hotki "XButton1 & LButton", "i"
        kshkt.hotki "XButton1 & RButton", "{LShift Down}{RButton}{LShift Up}"
        kshkt.hotki "XButton1 & WheelUp", gen.kenshi.bm.incrgamespeed
        kshkt.hotki "XButton1 & WheelDown", gen.kenshi.bm.decrgamespeed
        kshkt.hotki "XButton2 & WheelUp", gen.kenshi.bm.incrcharselect
        kshkt.hotki "XButton2 & WheelDown", gen.kenshi.bm.decrcharselect
        kshkt.hotki "LShift & Space", gen.kenshi.bm.cyclegamespeed

        dskt := this.dskt
        dskt.hotifexpr := (*)=>( !!winactive("ahk_exe ds.exe") and !!__k.ktblapp.death_stranding )
        dskt.hotki "XButton1 & XButton2", aktions.togglepress("w").toggle
        dskt.hotki "XButton2", aktions.holdpress("v").press
        dskt.hotki "XButton1", aktions.holdpress("Space").press
        dskt.hotki "XButton1 & LButton", aktions.holdpress("c").press
        dskt.hotki "XButton1 & RButton", aktions.holdpress("LShift").press
        dskt.hotki "XButton2 & RButton", aktions.holdpress("Escape").press
        dskt.hotki "+5", aktions.repeatpress("5", 30, 15).toggle

        fokt := this.fokt
        fokt.hotifexpr := (*)=>( !!winactive("ahk_exe FALLOUTW.exe") and !!__k.ktblapp.fallout )
        fokt.hotki "XButton2 & RButton", "{Escape}"
        fokt.hotki "XButton1 & XButton2", "a"

        dbgkl := this.dbgkl
        dbgkl.hotifexpr := (*)=>( !!__k.ktblgen.debuglead )
        dbgkl.pathki([ "h", "w", "n", "d" ], (*)=>(msgbox(a_clipboard:=winexist("a"))))
        dbgkl.pathki([ "c", "l", "s" ], (*)=>(msgbox(a_clipboard:=wingetclass(winexist("a")))))
        dbgkl.pathki([ "e", "x", "e" ], (*)=>(msgbox(a_clipboard:=wingetprocessname(winexist("a")))))
        dbgkl.pathki([ "t", "t", "l" ], (*)=>(msgbox(a_clipboard:=wingettitle(winexist("a")))))
        dbgkl.pathki([ "a", "c", "t" ], (*)=>(dbgln({__o__:1,nestlvlmax:7},wincache["A"])))
        dbgkl.pathki([ "d", "e", "s", "k" ], quiktool.call.bind( quiktool                  ;
                                                         , A_Clipboard:=A_ComputerName
                                                         , { x : A_ScreenWidth - 50  ;
                                                           , y : A_ScreenHeight - 25 }
                                                         , 6666                      ))

        dbgkt := this.dbgkt
        dbgkt.hotifexpr := (*)=>( !!__k.ktblgen.debugtbl )
        dbgkt.hotki "sc029 & r", (*)=>(keywait("sc029", "T2"), reload())
        dbgkt.hotki "sc029 & e", (*)=>__k.edit_enabled_gui.bm.toggle()
        dbgkt.hotki "sc029 & q", (*)=>exitapp()
        dbgkt.hotki "sc029 & h", (*)=>ListHotkeys()
        dbgkt.hotki "sc029 & l", (*)=>ListLines()
        dbgkt.hotki "sc029 & v", (*)=>ListVars()
        dbgkt.hotki "sc029 & k", (*)=>KeyHistory()
        dbgkt.hotki "sc029 & s", (*)=>Suspend()
        dbgkt.hotki "sc029 & F1", __k.edit_ktblgen_gui.bm.toggle
        dbgkt.hotki "sc029 & F2", __k.edit_ktblapp_gui.bm.toggle
        dbgkt.hotki "sc029 & F3", __k.edit_misc_gui.bm.toggle
        dbgkt.hotki "$sc029", (*)=>(send("{sc029}"))
        dbgkt.hotki "$+sc029", (*)=>(send("{Shift Down}{sc029}{Shift Up}"))

        dlkt := this.dlkt
        dlkt.hotifexpr := (*)=>( !!winactive("ahk_exe DyingLightGame.exe") and !!__k.ktblapp.dying_light )
        dlkt.hotki("XButton1 & RButton", gen.dyinglight.bm.togglerapidx1)

        coordmode "tooltip", "screen"
    }

    class deathstranding {
       static bm := { toggleautowalk : objbindmethod(this, "toggleautowalk") }
            , isautowalking := false
        static toggleautowalk(*) {
            if !!this.isautowalking
                send("{w Up}"), this.isautowalking := false
            else send("{w Down}"), this.isautowalking := true
        }
    }

    class dyinglight {
       static bm := { togglerapidx1 : objbindmethod(this, "togglerapidx1") ;
                    , looprapidx1   : objbindmethod(this,   "looprapidx1") ;
                    , startrapidx1  : objbindmethod(this,  "startrapidx1") ;
                    , stoprapidx1   : objbindmethod(this,   "stoprapidx1") }
            , rapidx1_enabled := false
            , rapidx1_interval := 50
        static looprapidx1(*) {
            send "{XButton1}"
        }
        static startrapidx1(*) {
            if !!this.rapidx1_enabled
                return
            this.rapidx1_enabled := true
            settimer(this.bm.looprapidx1, this.rapidx1_interval.abs())
        }
        static stoprapidx1(*) {
            if !this.rapidx1_enabled
                return
            this.rapidx1_enabled := false
            settimer(this.bm.looprapidx1, 0)
        }
        static togglerapidx1(*) {
            if !!this.rapidx1_enabled
                this.stoprapidx1
            else this.startrapidx1()
            quiktool(!!this.rapidx1_enabled, {x: A_ScreenWidth / 2, y: A_ScreenHeight / 2})
        }
    }

    class kenshi {
       static bm := { cyclegamespeed  : objbindmethod( this,  "cyclegamespeed" ) ;
                    , incrgamespeed   : objbindmethod( this,   "incrgamespeed" ) ;
                    , decrgamespeed   : objbindmethod( this,   "decrgamespeed" ) ;
                    , cyclecharselect : objbindmethod( this, "cyclecharselect" ) ;
                    , incrcharselect  : objbindmethod( this,  "incrcharselect" ) ;
                    , decrcharselect  : objbindmethod( this,  "decrcharselect" ) }
            , gamespeeds := [ "Space", "F2", "F3", "F4" ]
            , gamespeed := 0
            , gamespeedreset := 1000
            , gamespeedprev := 0
            , charselect := 0
            , charcount := 6
            , charselectprev := 0
            , charselectreset := 1000
            , charselectcycle := true
        static cyclecharselect(*) {
            csprev := this.charselectprev
            cscurr := A_TickCount
            if ((cscurr - csprev) > this.charselectreset) or (++this.charselect > this.charcount)
                this.charselect := 1
            send this.charselect
            this.charselectprev := cscurr
        }
        static incrcharselect(*) {
            if ++this.charselect > this.charcount
                this.charselect := this.charselectcycle ? 1 : this.charcount
            send this.charselect
        }
        static decrcharselect(*) {
            if --this.charselect < 1
                this.charselect := this.charselectcycle ? this.charcount : 1
            send this.charselect
        }
        static cyclegamespeed(*) {
            gsprev := this.gamespeedprev
            gscurr := A_TickCount
            if ((gscurr - gsprev) > this.gamespeedreset) or (++this.gamespeed > this.gamespeeds.length)
                    this.gamespeed := 1
            send "{" this.gamespeeds[this.gamespeed] "}"
            this.gamespeedprev := gscurr
        }
        static incrgamespeed(*) {
            if ++this.gamespeed > this.gamespeeds.length
                this.gamespeed := this.gamespeeds.length
            send "{" this.gamespeeds[this.gamespeed] "}"
        }
        static decrgamespeed(*) {
            if --this.gamespeed < 1
                this.gamespeed := 1
            send "{" this.gamespeeds[this.gamespeed] "}"
        }
    }
}

;; class dskt extends kitable {
;;
;;     /**
;;      * @prop {dskt} instance
;;      */
;;     static bm := {
;;             toggle_forward : objbindmethod(this, "toggle_forward")
;;         }
;;         , _moving_forward := false
;;         , _holding_left := false
;;         , _holding_right := false
;;         , instance := this()
;;
;;     static toggle_forward(*) {
;;         if (this._moving_forward:=!this._moving_forward)
;;             send "{w Down}"
;;         else send("{w Up}")
;;     }
;;
;;     static toggle_leftrighthold(*) {
;;         if not (this._holding_left and this._holding_right) {
;;             this._holding_left := this._holding_right := true
;;         }
;;         else {
;;             this._holding_left := this._holding_right := false
;;             ; ...
;;         }
;;     }
;;
;;     __new() {
;;         super.__new()
;;         this.hotifexpr := (*)=>(!!winactive("ahk_exe ds.exe") and !!__k.ktblmisc.death_stranding)
;;         this.hotki "MButton", "{LButton Down}{RButton Down}"
;;         this.hotki "MButton Up", "{RButton Up}{LButton Up}"
;;         this.hotki "!q", dskt.bm.toggle_forward
;;         this.hotki "w", ((*)=>(send("{w Down}")))
;;         this.hotki "w Up", ((*)=>(send("{w Up}"), dskt._moving_forward:=false))
;;         this.hotki "XButton1", "{w}"
;;         this.hotki "XButton1 Up", "{w Up}"
;;         this.dblki "XButton2", ((*)=>(send("{Shift Down}"),sleep(20),send("{Shift Up}"))), 245, dskt.bm.toggle_forward
;;     }
;; }


class on_main_start {
    static bm := {
            start_bcv2: objbindmethod(this, "start_bcv2")
        }

    static __new() {
        gen.kt.enabled := true
        gen.kl.enabled := true
        gen.wkl.enabled := true
        gen.ffkt.enabled := true
        gen.wzkt.enabled := true
        gen.dlkt.enabled := true
        gen.dskt.enabled := true
        gen.kshkt.enabled := true
        gen.fokt.enabled := true
        gen.dbgkt.enabled := true
        gen.dbgkl.enabled := true
        volctrl.wheel_enabled := true

        hotkey "sc029 & r", (*)=>(keywait("sc029", "T2"), reload())
        hotkey "sc029 & e", (*)=>__k.edit_enabled_gui.bm.toggle()
        hotkey "sc029 & q", (*)=>exitapp()
        hotkey "sc029 & h", (*)=>ListHotkeys()
        hotkey "sc029 & l", (*)=>ListLines()
        hotkey "sc029 & v", (*)=>ListVars()
        hotkey "sc029 & k", (*)=>KeyHistory()
        hotkey "sc029 & s", (*)=>Suspend()
        hotkey "sc029 & w", (*)=>(dbgln({__o__:1,nestlvlmax:7},wincache["A"]))
        hotkey "sc029 & F1", quiktool.call.bind(
                quiktool, A_Clipboard:=A_ComputerName, { x:A_ScreenWidth - 50
                                                     ,   y:A_ScreenHeight - 25 }, 6666 )
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


hotif (*)=>!!__k.enabled.pcnm_hotstrings
hotstring ":*?:cmpnm", (*)=>send(A_ComputerName)
hotstring ":*?:cmppr", (*)=>send(sys.defpcs["primary"].fullname)
hotstring ":*?:cmpop", (*)=>send(sys.defpcs["optiplex"].fullname)
hotstring ":*?:cmplp", (*)=>send(sys.defpcs["laptop"].fullname)
hotif

