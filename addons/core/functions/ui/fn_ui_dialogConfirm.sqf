#include "..\..\script_component.hpp"

/*
* Confirms a ZEIC dialog: runs its confirm code (see PFUNC(ui_dialogFinish)) and closes it.
*
* Arguments:
* 0: Display <DISPLAY>
*
* Return Value:
* None
*
* Public: No
*/

params [["_display", displayNull, [displayNull]]];

if (isNull _display || {_display getVariable [QPVAR(confirmed), false]}) exitWith {};
_display setVariable [QPVAR(confirmed), true];

// The confirm code can return false to keep the dialog open (e.g. something still has to be picked)
private _onConfirm = _display getVariable [QPVAR(onConfirm), {}];
if ((_display call _onConfirm) isEqualTo false) exitWith {
	_display setVariable [QPVAR(confirmed), false];
};
_display closeDisplay 1;
