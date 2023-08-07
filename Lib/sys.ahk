; sys.ahk
; cSpell:enable

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include builtins_extended.ahk

class sys {
    static bm := {
            launch_env_vars : ObjBindMethod(sys.launch_env_vars, "call"),
            launch_env_path : ObjBindMethod(sys.launch_env_vars, "edit_usr_path")
        }
        , pc := 0
        , pcalias := ""
        , pcsuffix := 0
        , pcfullname := ""
        , defpcs := Map("primary",  { pc: 1, pcalias: "primary" , suffix: "HQ7DNU5", fullname: "DESKTOP-HQ7DNU5" } ;
                      , "optiplex", { pc: 2, pcalias: "optiplex", suffix: "HJ4S4Q2", fullname: "DESKTOP-HJ4S4Q2" } ;
                      , "laptop",   { pc: 3, pcalias: "laptop"  , suffix: "JJTV8BS", fullname: "DESKTOP-JJTV8BS" } )
    static __new() {
        this.pcsuffix := A_ComputerName.Replace("DESKTOP-")
        for _pcnm, _pc in this.defpcs
            if _pc.suffix = this.pcsuffix
                this.pc := _pc.pc, this.pcfullname := _pc.fullname, this.pcalias := _pcnm
    }
    class launch_env_vars {
        static sys_prop_adv_title := "System Properties"
            , sys_prop_adv_exe   := "C:\Windows\System32\SystemPropertiesAdvanced.exe"
            , env_vars_title     := "Environment Variables"
            , path_vars_title    := "Edit environment variable"
        static edit_usr_path(*) {
            env_vars_open := winexist(this.env_vars_title)
            path_vars_open := winexist(this.path_vars_title)
            if !env_vars_open or !winactive(this.env_vars_title)
                this.open_to_env_vars
            if !path_vars_open {
                winexist(this.env_vars_title)
                controlfocus "SysListView321"
                controlsend "{PgUp}p", "SysListView321"
                sleep 20
                send "{Tab 2}{Enter}"
            } else winclose(this.path_vars_title)
        }
        static open_to_env_vars(*) {
            sys_prop_open := winexist(this.sys_prop_adv_title)
            env_vars_open := winexist(this.env_vars_title)
            if not sys_prop_open
                run this.sys_prop_adv_exe
            winwait(this.sys_prop_adv_title,, 5)
            if not env_vars_open {
                winactivate this.sys_prop_adv_title
                if winwaitactive(,,5)
                    controlclick "button7"
            }
            winwait(this.env_vars_title,, 5)
            winactivate this.env_vars_title
            winwaitactive
        }
        static closeall(*) {
            if winexist(this.path_vars_title)
                winclose(), winwaitclose()
            if winexist(this.env_vars_title)
                winclose(), winwaitclose()
            if winexist(this.sys_prop_adv_title)
                winclose()
        }
        static call(*) {
            if not winexist(this.env_vars_title) {
                this.open_to_env_vars
            } else this.closeall()
        }
    }
}
