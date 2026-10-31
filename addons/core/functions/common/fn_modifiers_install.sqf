#include "..\..\script_component.hpp"

/*
* Tracks the modifier keys (Shift, Ctrl, Alt) on the Zeus or Eden display, so a module can tell which
* ones were held while it was placed (see PFUNC(modifiers_get)). Every key and mouse event carries the
* full modifier state, so a key released while the game had no focus (Alt-Tab) can't get stuck.
* The handlers return false: Zeus and Eden still get all keys. Adds them once per display.
*
* Arguments:
* 0: Display (312 Zeus, 313 Eden) <DISPLAY>
*
* Return Value:
* None
*
* Public: No
*/

params [["_display", displayNull, [displayNull]]];

if (isNull _display || {_display getVariable [QPVAR(modifiersTracked), false]}) exitWith {};
_display setVariable [QPVAR(modifiersTracked), true];
uiNamespace setVariable [QPVAR(modifiers), [false, false, false]];

// Key events: the flags show the state before the key, the key itself is added or removed
_display displayAddEventHandler ["KeyDown", { [_this, true] call PFUNC(modifiers_onKey); false }];
_display displayAddEventHandler ["KeyUp", { [_this, false] call PFUNC(modifiers_onKey); false }];

{
	_display displayAddEventHandler [_x, {
		params ["", "", "", "", "_shift", "_ctrl", "_alt"];
		uiNamespace setVariable [QPVAR(modifiers), [_shift, _ctrl, _alt]];
		false
	}];
} forEach ["MouseButtonDown", "MouseButtonUp"];
