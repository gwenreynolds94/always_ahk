
#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <bultins_extended>
#Include <config_tool>

Class _AlwaysAhkConf extends ConfTool {
    /** 
     * @prop {Map} config_defaults
     */
    static config_defaults := Map()

    edit_enabled_gui := {}

    __New() {
        super.__New(".\.ahkonf", _AlwaysAhkConf.config_defaults)
        this.Validate()
        this.edit_enabled_gui := ConfTool.SectionEdit(this, "Enabled", "bool")
    }

    Enabled => this.Ini.Enabled
    Misc => this.Ini.Misc
}

_AlwaysAhkConf.config_defaults := Map(
    "Enabled", Map(
        "FuckCortana", True,
    ),
    "Misc", Map(
        "FuckCortanaInterval", 6666,
    )
)

/**
 * 
 */
_C := _AlwaysAhkConf()

/**
 * Contains various properties to store non-persistent script configurations
 */
Class _S {

}
