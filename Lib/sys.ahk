; sys.ahk
; cSpell:enable

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include builtins_extended.ahk

class sys {
    class launch_env_vars {
        static sys_prop_adv_title := "System Properties"
            , sys_prop_adv_exe   := "C:\Windows\System32\SystemPropertiesAdvanced.exe"
            , env_vars_title     := "Environment Variables"
        static click_sys_prop_adv_btn7(*) {
            if not winwait(this.sys_prop_adv_title,, 5)
                return false
            winactivate
            this.sys_prop_adv_hwnd := winwaitactive(this.sys_prop_adv_title,, 5)
            if !!sys_prop_adv_hwnd
                controlclick("button7")
            return true
        }
        static call(*) {
            if not winexist(this.sys_prop_adv_title) {
                run this.sys_prop_adv_exe
                this.click_sys_prop_adv_btn7
            } else {
                if not winexist(this.env_vars_title) {
                    this.click_sys_prop_adv_btn7
                } else {
                    winclose this.env_vars_title
                    winwaitclose
                    winclose this.sys_prop_adv_title
                }
            }
        }
    }
}
