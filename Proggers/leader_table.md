
leadertable
----

- method of binding the leader key

- steps 
    - - set hotkey for leader key, combining the desired action
            with a function that sets a timer to disable the hotkey
            after a set time
    - - enable leader hotkey
    - - press leader
    - - set hotkey for first hotkey in path, combining the action
            with a timeout function
    - - press first hotkey in path
    - - set hotkey for next key; include the timeout function
    - - ...repeat... up until the last hotkey in the path
    - - set hotkey for last key, including timeout, 

- ???
    - - should each key in the path be represented by a keytable class, 
            a keytable.binding class, or a new designated class, possibly
            inheriting an existing class? what should the first and last
            keys in a keypath be represented by? is it different? if a key
            is represented by a keytable, the keytable will have to integrate
            a oneshot functionality, disabling the keytable when the key is triggered

---------------------------------------------------



keytable
----

- integrate timeout and oneshots

---------------------------------------------------
