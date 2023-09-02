; config_tool.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force


if (A_LineFile = A_ScriptFullPath) {
    test_config := test_conf("C:\Users\" A_UserName "\.test_conf",
        Map(
            "SectA", Map(
                "A", "Aye",
                "B", "Bee",
                "C", "See"
            ),
            "SectB", Map(
                "A", "Aye",
                "B", "Bee",
                "C", "See"
            )
        )
    )
    test_config.validate()
    ; using .Ini ;
    test_config.ini.SectNew.A := "AyeAgain"
    test_config.ini.SectNew.B := "BeeAgain"
    ; using extended class 'shortcut' props
    test_config.SectNew.C := "SeeAgain!"
    test_config.KeyAB := "AyeBeeNew"
}

/**
 * Extend ConfTool so you can define properties to have shortcuts to
 * specific sections. To define shortcuts to specific keys, you have
 * to define both `get` and `set` methods
 */
Class test_conf extends conf_tool {
    SectA => this.Ini.SectA
    SectB => this.Ini.SectB
    SectNew => this.Ini.SectNew
    KeyAB {
        set => this.Ini.SectA.B := Value
        get => this.Ini.SectA.B
    }
}

/**
 * This class implements an object-oriented interface for loading and saving
 * configuration files using the IniRead and IniWrite functions.
 *
 * The constructor (__New) can be used to set a custom filepath for the
 * configuration file, as well as a set of default values. The Validate method
 * can be used to check if a configuration file already exists and either create
 * a new file or just return "exists". The Sett method provides accessor methods
 * for each section and key in the file. The Ini method provides access to the
 * entire file in one call. The Setting and SettingSection classes provide static
 * methods to access sections and keys from the configuration file.
 *
 * Finally, the SectionEdit class provides a graphical interface for editing
 * a particular section of the file.
 */
Class conf_tool {

    /**
     * @param {String} fpath 
     */
    fpath := ".\.ahkonf"

    /**
     *
     */
    defaults := Map()

    /**
     * @param {String} _confpath path to configuration file to be read/written
     * @param {Map} _defaults a nest of maps in the following format:
     *
     * ```
     *  _defaults := Map(
     *      "SectionA", Map(
     *          "KeyAA", "ValueAA",
     *          "KeyAB", "ValueAB",
     *          "KeyAC", "ValueAC"
     *      ),
     *      "SectionB", Map(
     *          "KeyBA", "ValueBA",
     *          "KeyBB", "ValueBB",
     *          "KeyBC", "ValueBC"
     *      )
     *      ; ...
     *  )
     * ```
     */
    __New(_confpath:="", _defaults:="") {
        this.fpath := _confpath ? _confpath : this.fpath
        this.defaults := _defaults ? _defaults : this.defaults
    }

    validate() {
        retval := ""
        create_default_file() {
            for _sectname, _sect in this.defaults
                for _keyname, _keyvalue in _sect
                    this.ini.%_sectname%.%_keyname% := _keyvalue
        }
        check_keys() {
            for _sectname, _sectmeat in this.defaults {
                section_keys := []
                has_section := false
                loop parse, iniread(this.fpath), "`n", "`r"
                    if _sectname = A_LoopField
                        has_section := true
                if not has_section
                    iniwrite("", this.fpath, _sectname)
                Loop Parse, IniRead(this.fpath, _sectname), "`n", "`r" {
                    _re_found := RegExMatch(A_LoopField, "([^=]+)=(.+)?", &_re_match)
                    if not !_re_found
                        continue
                    section_keys.Push _re_match.1
                    if _re_match.Count < 2
                        iniwrite(false, this.fpath, _sectname, _re_match.1)
                }
                for _keyname, _keyvalue in _sectmeat
                    if not section_keys.IndexOf(_keyname)
                        this.ini.%_sectname%.%_keyname% := _keyvalue
            }
        }
        if FileExist(this.fpath) {
            check_keys()
            return "exists"
        }
        SplitPath this.fpath, &_fname, &_fdir
        _fdir := _fdir ? _fdir : "."
        if DirExist(_fdir) {
            create_default_file()
            return "file"
        } else {
            SplitPath _fdir, &_dname, &_ddir
            _ddir := _ddir ? _ddir : "."
            if DirExist(_ddir) {
                DirCreate(_fdir)
                create_default_file()
                return "dir"
            } else return ""
        }
    }

    ini {
        get {
            conf_tool.setting_section.current_file_path := this.fpath
            Return conf_tool.setting_section()
        }
    }

    Class setting {
        Static current_section := "",
               current_file_path := ""

        __get(Key, Params) {
            Return IniRead(conf_tool.setting.current_file_path,
                            conf_tool.setting.current_section, Key, false)
        }

        __set(Key, Params, Value) {
            IniWrite(Value, conf_tool.setting.current_file_path,
                            conf_tool.setting.current_section, Key)
        }
    }

    Class setting_section {
        Static current_file_path := ""

        __get(Key, Params) {
            conf_tool.setting.current_file_path :=
                conf_tool.setting_section.current_file_path
            conf_tool.setting.current_section := Key
            Return conf_tool.setting()
        }

        __set(Key, Params, Value) {
            Return
        }
    }

    Class section_edit {

        /**
         * @prop {ConfTool} _conftool instance of ConfTool to edit
         */
        _conftool := ""

        /**
         * @prop {String} _section section to edit
         */
        _section := "",

        /**
         * @prop {"bool"|"string"} types of values in section
         */
        _value_type := {}

        /**
         * @prop {Map} _content contents of ini section
         */
        _content := Map()

        /**
         * @prop {Gui} _gui instance of gui used to edit section
         */
        _gui := {}

        /**
         * @prop {Map} _guictrls <String, Gui.Control> 
         */
        _guictrls := Map()

        /**
         * @prop {Gui.Control} _gui_exit_btn gui exit button lol
         */
        _gui_exit_btn := {}
        
        /**
         * @param {Integer|Number} _item_width width of key items
         */
        _item_width := 150

        /**
         * @param {Object} methbound stores various instance-bound methods
         */
        methbound := {}
        bm := {
            show: objbindmethod(this, "show"),
            hide: objbindmethod(this, "hide"),
            toggle: objbindmethod(this, "toggle"),
            isactive: objbindmethod(this, "isactive"),
            textedit_on_submit: objbindmethod(this, "textedit_on_submit"),
            textedit_on_enter: objbindmethod(this, "textedit_on_enter")
        }
        _hidden_ := true
        /**
         * @prop {Map} updateactions
         */
        updateactions := Map()
        editfocuscache := Map()
        editsubmitcache := map()
        /**
         * @param {ConfTool} _conftool instance of ConfTool to edit
         * @param {String} _section section in configuration file to edit
         * @param {"bool"|"string"} _value_type types of values in section 
         */
        __New(_conftool, _section, _value_type:="bool") {
            this._conftool := _conftool
            this._section := _section
            this._value_type := _value_type
            this.methbound.show := ObjBindMethod(this, "Show")
            this.methbound.hide := ObjBindMethod(this, "Hide")
            this.setup_gui()
        }

        isactive(*) => !!winactive(this._gui)

        /**
         *
         */
        setup_gui() {
            hasbools := this._value_type ~= "bool"
            hasprimitives := this._value_type ~= "str|mix|num"
            this._gui := Gui("+AlwaysOnTop", "Edit" this._section "Gui", this)
            this._gui.OnEvent("Close", "hide")
            this.update_content()
            ctrlopts := "xp+0 y+10 w" this._item_width
            hotif this.bm.isactive ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
                hotkey "Escape", this.bm.hide
                if hasbools
                    hotkey "Enter", this.bm.hide
                else if hasprimitives
                    hotkey "Enter", this.bm.textedit_on_enter
            hotif ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
            for _key, _value in this._content {
                if hasbools {
                    this._guictrls[_key] :=
                        this._gui.AddCheckbox(ctrlopts, _key)
                    this._guictrls[_key].Value := _value
                    this._guictrls[_key].OnEvent("Click", "checkbox_on_click")
                }
                else if hasprimitives {
                    this._guictrls[_key "title"] := this._gui.AddText("v" _key "_text " ctrlopts, _key)
                    this._guictrls[_key "title"].SetFont(,"FiraCode Nerd Font Mono")
                    this._guictrls[_key] := this._gui.AddEdit("v" _key " " ctrlopts, _value)
                    this._guictrls[_key].OnEvent("Change", "textedit_on_change")
                    this._guictrls[_key].OnEvent("Focus", "textedit_on_focus")
                }
            }

            this._gui_exit_btn :=
                this._gui.AddButton("xp+0 y+10 w" this._item_width, "Close")
            this._gui_exit_btn.OnEvent("Click", "exit_btn_on_click")

            /** 
             * @var {Menu} _tray 
             */
            _tray := A_TrayMenu
            _tray.Add("Edit " this._section, this.methbound.show)
        }

        /**
         *
         */
        update_content() {
            this._content.Clear()
            Loop Parse, IniRead(this._conftool.fpath, this._section), "`n", "`r" {
                RegExMatch A_LoopField, "([^=]+)=(.+)", &_re_match
                this._content[_re_match.1] := _re_match.2
                this.updateactions[_re_match.1] := false
            }
        }

        /**)
         *
         */
        exit_btn_on_click(*) {
            this.hide()
        }

        /** 
         * @param {Gui.Control} _guictrl 
         */
        checkbox_on_click(_guictrl, *) {
            this._conftool.ini.%this._section%.%_guictrl.Text% := _guictrl.Value
        }

        textedit_on_change(_guictrl, *) {
            settimer(this.editsubmitcache[_guictrl.name], (-500))
        }
        textedit_on_submit(_guictrl, *) {
            this._gui.Submit(false)
            this._conftool.ini.%this._section%.%_guictrl.Name% := _guictrl.Value or false
            if !!this.updateactions[_guictrl.name]
                (this.updateactions[_guictrl.name])()
        }
        textedit_on_focus(_guictrl, *) {
            this.editfocuscache[_guictrl.name] := _guictrl.value or false
            if !this.editsubmitcache.has(_guictrl.name)
                this.editsubmitcache[_guictrl.name] := objbindmethod(this, "textedit_on_submit", _guictrl)
        }
        textedit_on_enter(*) {
            _guictrl := this._gui.FocusedCtrl
            this.textedit_on_submit(_guictrl)
            this.hide()
        }

        show(*) {
            this._hidden_ := false
            this._gui.show()
        }

        hide(*) {
            this._hidden_ := true
            this._gui.hide()
        }

        toggle(*) {
            if this._hidden_
                this.show()
            else this.hide()
        }

        /**
         *
        Show(*) {
            this._gui.Show()
        }

        Hide(*) {
            this._gui.Hide()
        }
         */

    }

}


