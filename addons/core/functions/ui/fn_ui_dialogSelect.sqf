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
	private _selected = _forEachIndex == _index;
	_x ctrlSetBackgroundColor ([UI_COLOR_FIELD, UI_COLOR_FIELD_ON] select _selected);
	_x ctrlSetTextColor ([UI_COLOR_MUTED, UI_COLOR_TEXT] select _selected);
	(_x getVariable [QPVAR(bar), controlNull]) ctrlShow _selected;
} forEach (_display getVariable [format ["%1_buttons", _key], []]);
