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

private _onConfirm = _display getVariable [QPVAR(onConfirm), {}];
_display call _onConfirm;
_display closeDisplay 1;
