
#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include config_tool.ahk

if (A_LineFile = A_ScriptFullPath) {
    test_conf := TestConf("C:\Users\" A_UserName "\.test_conf",
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
    test_conf.Validate()
    ; using .Ini ;
    test_conf.Ini.SectNew.A := "AyeAgain"
    test_conf.Ini.SectNew.B := "BeeAgain"
    ; using extended class 'shortcut' props
    test_conf.SectNew.C := "SeeAgain!"
    test_conf.KeyAB := "AyeBeeNew"
}

/**
 * Extend ConfTool so you can define properties to have shortcuts to
 * specific sections. To define shortcuts to specific keys, you have
 * to define both `get` and `set` methods
 */
Class TestConf extends ConfTool {
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
Class ConfTool {

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

    Validate() {
        retval := ""
        CreateDefaultFile() {
            for _sectname, _sect in this.defaults
                for _keyname, _keyvalue in _sect
                    this.Ini.%_sectname%.%_keyname% := _keyvalue
        }
        CheckKeys() {
            for _sectname, _sectmeat in this.defaults {
                section_keys := []
                Loop Parse, IniRead(this.fpath, _sectname), "`n", "`r" {
                    RegExMatch A_LoopField, "([^=]+)=(.+)", &_re_match
                    section_keys.Push _re_match.1
                }
                for _keyname, _keyvalue in _sectmeat
                    if not section_keys.IndexOf(_keyname)
                        this.Ini.%_sectname%.%_keyname% := _keyvalue
            }
        }
        if FileExist(this.fpath) {
            CheckKeys()
            return "exists"
        }
        SplitPath this.fpath, &_fname, &_fdir
        _fdir := _fdir ? _fdir : "."
        if DirExist(_fdir) {
            CreateDefaultFile()
            return "file"
        } else {
            SplitPath _fdir, &_dname, &_ddir
            _ddir := _ddir ? _ddir : "."
            if DirExist(_ddir) {
                DirCreate(_fdir)
                CreateDefaultFile()
                return "dir"
            } else return ""
        }
    }

    Ini {
        Get {
            ConfTool.SettingSection.CurrentFilePath := this.fpath
            Return ConfTool.SettingSection()
        }
    }

    Class Setting {
        Static CurrentSection := "",
               CurrentFilePath := ""

        __Get(Key, Params) {
            Return IniRead(ConfTool.Setting.CurrentFilePath,
                            ConfTool.Setting.CurrentSection, Key, "")
        }

        __Set(Key, Params, Value) {
            IniWrite(Value, ConfTool.Setting.CurrentFilePath,
                            ConfTool.Setting.CurrentSection, Key)
        }
    }

    Class SettingSection {
        Static CurrentFilePath := ""

        __Get(Key, Params) {
            ConfTool.Setting.CurrentFilePath :=
                ConfTool.SettingSection.CurrentFilePath
            ConfTool.Setting.CurrentSection := Key
            Return ConfTool.Setting()
        }

        __Set(Key, Params, Value) {
            Return
        }
    }

    Class SectionEdit {

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

        /**
         * @param {ConfTool} _conftool instance of ConfTool to edit
         * @param {String} _section section in configuration file to edit
         * @param {"bool"|"string"} _value_type types of values in section 
         *  [STRING NOT IMPLEMENTED]
         */
        __New(_conftool, _section, _value_type:="bool") {
            this._conftool := _conftool
            this._section := _section
            this._value_type := _value_type
            this.methbound.show := ObjBindMethod(this, "Show")
            this.methbound.hide := ObjBindMethod(this, "Hide")
            this.SetupGui()
        }

        /**
         *
         */
        SetupGui() {
            this._gui := Gui("+AlwaysOnTop", "Edit" this._section "Gui", this)
            this.UpdateContent()
            for _key, _value in this._content {
                if this._value_type ~= "bool" {
                    this._guictrls[_key] :=
                        this._gui.AddCheckbox("xp+0 y+10 w" this._item_width, _key)
                    this._guictrls[_key].Value := _value
                    this._guictrls[_key].OnEvent("Click", "CheckBox_OnClick")
                }
            }

            this._gui_exit_btn :=
                this._gui.AddButton("xp+0 y+10 w" this._item_width, "Close")
            this._gui_exit_btn.OnEvent("Click", "ExitButton_OnClick")

            /** 
             * @var {Menu} _tray 
             */
            _tray := A_TrayMenu
            _tray.Add("Edit " this._section, this.methbound.show)
        }

        /**
         *
         */
        UpdateContent() {
            this._content.Clear()
            Loop Parse, IniRead(this._conftool.fpath, this._section), "`n", "`r" {
                RegExMatch A_LoopField, "([^=]+)=(.+)", &_re_match
                this._content[_re_match.1] := _re_match.2
            }
        }

        /**
         *
         */
        ExitButton_OnClick(*) {
            this.Hide()
        }

        /** 
         * @param {Gui.Control} _guictrl 
         */
        CheckBox_OnClick(_guictrl, *) {
            this._conftool.Ini.%(this._section)%.%(_guictrl.Text)% := _guictrl.Value
        }

        /**
         *
         */
        Show(*) {
            this._gui.Show()
        }

        /**
         *
         */
        Hide(*) {
            this._gui.Hide()
        }

    }

}


