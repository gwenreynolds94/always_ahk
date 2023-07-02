; main.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

outputdebug "
(ltrim
    
)"
#Include <bultins_extended>
#Include <config_tool>
#Include <winwiz>
#Include <kitable>
#Include <quiktip>
#Include <volctrl>

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
    static ki := {}
        , methbinds := {
            cycle: {}
        }

    static __new() {

        ki := this.ki := kitable()

        ki.methbinds.cycle := objbindmethod(this, "wincycle")
        ki.bind("$+CapsLock", "{CapsLock}")
        ki.bind("XButton1 & MButton", winwiz.methbinds.loopwindows.bind(false, "", false))
        ki.bind("XButton2 & MButton", winwiz.methbinds.loopwindows.bind(true, "", false))
        ki.bind("XButton2 & LButton", winwiz.methbinds.cyclewindows.bind(false, "", false))
        ki.bind("XButton2 & RButton", winwiz.methbinds.cyclewindows.bind(true, "", false))
        ki.bindpath(["LAlt & Space", "w"], wez.ki.methbinds.toggle)

        coordmode "tooltip", "screen"
    }

    static wincycle(_zorder:=2,*) {
        winactivate winwiz.prevwin[,_zorder]
        winwiz._debug_wintitles((winwiz.winlist[,true])*)
    }
}

class wez {
    /**
     * @prop {kitable} ki
     */
    static ki := {}
        ,  wintitle := "ahk_exe wezterm-gui.exe"
        ,  methbinds := {
            cycle: {}
        }

    static __new() {

        ki := this.ki := kitable()
        ki.hotifexpr := (*)=>WinActive("ahk_exe wezterm-gui.exe")
    
        this.methbinds.cycle := ObjBindMethod(this, "wincycle")

        ki.bind("XButton1 & XButton2", "{Ctrl Down}{PgDn}{Ctrl Up}")
        ki.bind("XButton2 & XButton1", "{Ctrl Down}{PgUp}{Ctrl Up}")
        ki.bind("XButton2 & LButton", winwiz.methbinds.cyclewindows.bind(false, this.wintitle, false))
        ki.bind("XButton2 & RButton", winwiz.methbinds.cyclewindows.bind(true, this.wintitle, false))
    }

    static wincycle(_zorder:=2, *) {
        winactivate winwiz.prevwin[this.wintitle, _zorder]
    }
    
}

gen.ki.enabled := true
;;  wez.ki.enabled := true
volctrl.wheel_enabled := true


;;  HotIfWinactive "ahk_exe wezterm-gui.exe"
;;  Hotkey "XButton1 & XButton2", ((*)=> Send( "{Ctrl Down}{PgDn}{Ctrl Up}" )), "On"
;;  Hotkey "XButton2 & XButton1", ((*)=> Send( "{Ctrl Down}{PgUp}{Ctrl Up}" )), "On"
;;  Hotkey "XButton1 & LButton", ((*)=> WinActivate(winwiz.prevwin["ahk_exe wezterm-gui.exe"])), "On"
;;  Hotkey "XButton2 & LButton", ((*)=> WinActivate(winwiz.prevwin["ahk_exe wezterm-gui.exe", 3])), "On"
;;  Hotkey "$!CapsLock", ((*)=> Send( "{F13}" )), "On"
;;  HotIf


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
;;  __s.kgen.bind("LAlt & RCtrl", (*)=>Tooltip(A_TickCount))
;;  
;;  
;;  __s.ktst.bind("<^>^Up", (*)=>ToolTip("^^^"))
;;  __s.ktst.bind("<^>^Down", (*)=>ToolTip("vvv"))
;;  
;;  
;;  __s.kfo.bind("XButton1 & LButton", "{Shift Down}{LButton}{Shift Up}")
;;  __s.kfo.bind("XButton1 & RButton", "p")
;;  __s.kfo.bind("XButton1 & MButton", "{Tab}")
;;  
;;  __s.kfo.bind("XButton2 & LButton", "i")
;;  __s.kfo.bind("XButton2 & RButton", "{Escape}")
;;  __s.kfo.bind("XButton2 & MButton", "c")
;;  
;;  __s.kfo.bind("XButton1 & XButton2", "{Home}")
;;  __s.kfo.bind("XButton2 & XButton1", "s")
;;  
;;  
;;  __s.kgen.enabled := true
;;  __s.ktst.enabled := true
;;  __s.kfo.enabled := true
;;  
;;  Hotkey "LAlt & AppsKey", (*)=>(__s.kgen.enabled := true)
