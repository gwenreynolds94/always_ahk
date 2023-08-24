; aktions.ahk

#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <builtins_extended>
#Include <quiktip>

class aktions {
    class repeatpress {
        toggle := objbindmethod(this, "_toggle_")
        press  := objbindmethod(this, "_press_" )
        key := ""
        interval := 50
        pressduration := 30
        _active_ := false
        /**
         * @param {string} _key
         * @param {integer} [_interval=50]
         * @param {integer} [_pressduration=30]
         *
         * ----
         *
         * ```autohotkey
         * send "{" this.key " Down}"
         * ```
         */
        __new(_key, _interval:=50, _pressduration:=30) {
            this.key := _key
            this.interval := _interval
            this.pressduration := _pressduration
        }
        _press_(*) {
            send "{" this.key " Down}"
            settimer (*)=>(send("{" this.key " Up}")), this.pressduration.neg()
        }
        _toggle_(*) {
            this._active_ := !this._active_
            settimer this.press, (!!this._active_ ? this.interval.abs() : 0)
            quiktool this._active_
        }
    }
    class togglepress {
        toggle := objbindmethod(this, "_toggle_")
        key := ""
        _active_ := false
        /**
         * @param {string} _key
         *
         * ----
         *
         * ```autohotkey
         * send "{" _key " " (!!this._active_ ? "Down" : "Up") "}"
         * ```
         */
        __new(_key) {
            this.key := _key
        }
        _toggle_(*) {
            this._active_ := !this._active_
            send "{" this.key " " (!!this._active_ ? "Down" : "Up") "}"
            quiktool this._active_
        }
    }
    class holdpress {
        press := objbindmethod(this, "_press_")
        key := ""
        duration := 50
        /**
         * @param {string} _key
         * @param {integer} [_duration=50]
         *
         * ----
         *
         * ```autohotkey
         * send "{" this.key " Down}"
         * ```
         */
        __new(_key, _duration:=50) {
            this.key := _key
            this.duration := _duration
        }
        _press_(*) {
            send "{" this.key " Down}"
            settimer((*)=>(send("{" this.key " Up}")), this.duration.neg())
        }
    }
}
