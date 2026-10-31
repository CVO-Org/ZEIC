#include "..\..\script_component.hpp"

/*
* Selects a segment of a segment row (see PFUNC(ui_dialogSegments)) and repaints the row.
*
* Arguments:
* 0: Display <DISPLAY>
* 1: Key <STRING>
* 2: Index <NUMBER>
*
* Return Value:
* None
*
* Public: No
*/

params [["_display", displayNull, [displayNull]], ["_key", "", [""]], ["_index", 0, [0]]];

_display setVariable [_key, _index];

{
	_x setVariable [QPVAR(selected), _forEachIndex == _index];
	[_x] call (_x getVariable QPVAR(paint));
} forEach (_display getVariable [format ["%1_buttons", _key], []]);
