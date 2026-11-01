#include "..\..\script_component.hpp"

/*
* Self test: the module shortcuts (modifier tracking, category shortcuts).
* Part of PFUNC(dev_selfTest), needs its scheduled environment.
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

// T19 shortcuts (#6)
private _shortcutOf = {
	params ["_class"];
	((call PFUNC(interiorFill_categories)) select { (_x select 1) == _class }) param [0, ["", "", "?"]] select 2
};
["T19.1 category shortcuts from config", (["mil"] call _shortcutOf) == "ctrl" && {(["civ"] call _shortcutOf) == "shift"} && {(["cbrn"] call _shortcutOf) == "ctrl+shift"},
	[["mil"] call _shortcutOf, ["civ"] call _shortcutOf, ["cbrn"] call _shortcutOf]] call PFUNC(dev_check);

private _saved = uiNamespace getVariable [QPVAR(modifiers), [false, false, false]];

// Pressing Ctrl: the KeyDown flags still show the state before the key
[[displayNull, 29, false, false, false], true] call PFUNC(modifiers_onKey);
["T19.2 Ctrl pressed", (call PFUNC(modifiers_get)) == "ctrl", call PFUNC(modifiers_get)] call PFUNC(dev_check);
[[displayNull, 42, false, true, false], true] call PFUNC(modifiers_onKey);
["T19.3 Ctrl and Shift pressed", (call PFUNC(modifiers_get)) == "ctrl+shift", call PFUNC(modifiers_get)] call PFUNC(dev_check);
[[displayNull, 29, true, true, false], false] call PFUNC(modifiers_onKey);
["T19.4 Ctrl released, Shift still held", (call PFUNC(modifiers_get)) == "shift", call PFUNC(modifiers_get)] call PFUNC(dev_check);
[[displayNull, 42, true, false, false], false] call PFUNC(modifiers_onKey);
["T19.5 nothing held", (call PFUNC(modifiers_get)) == "", call PFUNC(modifiers_get)] call PFUNC(dev_check);

uiNamespace setVariable [QPVAR(modifiers), _saved];

if (!isNull findDisplay 312) then {
	["T19.6 tracking installed on the Zeus display", (findDisplay 312) getVariable [QPVAR(modifiersTracked), false]] call PFUNC(dev_check);
} else {
	diag_log text "[ZEIC TEST] SKIP T19.6 Zeus is not open";
};
