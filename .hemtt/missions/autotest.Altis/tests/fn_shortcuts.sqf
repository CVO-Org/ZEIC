#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* the module shortcuts (modifier tracking, category shortcuts).
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["shortcuts"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The module shortcuts (modifier tracking, category shortcuts)", {
        params ["_ctx"];

        // T19 shortcuts (#6)
        private _shortcutOf = {
            params ["_class"];
            ((call PFUNC(interiorFill_categories)) select { (_x select 1) == _class }) param [0, ["", "", "?"]] select 2
        };
        ["category shortcuts from config", (["mil"] call _shortcutOf) == "ctrl" && {(["civ"] call _shortcutOf) == "shift"} && {(["cbrn"] call _shortcutOf) == "ctrl+shift"},
            [["mil"] call _shortcutOf, ["civ"] call _shortcutOf, ["cbrn"] call _shortcutOf]] call autotest_fnc_check;

        private _saved = uiNamespace getVariable [QPVAR(modifiers), [false, false, false]];

        // Pressing Ctrl: the KeyDown flags still show the state before the key
        [[displayNull, 29, false, false, false], true] call PFUNC(modifiers_onKey);
        ["Ctrl pressed", (call PFUNC(modifiers_get)) == "ctrl", call PFUNC(modifiers_get)] call autotest_fnc_check;
        [[displayNull, 42, false, true, false], true] call PFUNC(modifiers_onKey);
        ["Ctrl and Shift pressed", (call PFUNC(modifiers_get)) == "ctrl+shift", call PFUNC(modifiers_get)] call autotest_fnc_check;
        [[displayNull, 29, true, true, false], false] call PFUNC(modifiers_onKey);
        ["Ctrl released, Shift still held", (call PFUNC(modifiers_get)) == "shift", call PFUNC(modifiers_get)] call autotest_fnc_check;
        [[displayNull, 42, true, false, false], false] call PFUNC(modifiers_onKey);
        ["nothing held", (call PFUNC(modifiers_get)) == "", call PFUNC(modifiers_get)] call autotest_fnc_check;

        uiNamespace setVariable [QPVAR(modifiers), _saved];

        if (!isNull findDisplay 312) then {
            ["tracking installed on the Zeus display", (findDisplay 312) getVariable [QPVAR(modifiersTracked), false]] call autotest_fnc_check;
        } else {
            diag_log text "[ZEIC TEST] SKIP T19.6 Zeus is not open";
        };
    }, 180]
]
