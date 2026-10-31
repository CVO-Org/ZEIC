#include "..\..\script_component.hpp"

/*
* Adds a dropdown row to a ZEIC dialog. The selected index is stored on the display.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Label <STRING>
* 3: Options <ARRAY of STRINGs>
* 4: Selected index <NUMBER>
* 5: Tooltip <STRING> (default: none)
*
* Return Value:
* Combo <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_options", [], [[]]], ["_selected", 0, [0]], ["_tooltip", "", [""]]];

private _display = _ctx get "display";
private _combo = [_ctx, QPVAR(ctrlCombo), [_ctx, _label, _tooltip] call PFUNC(ui_dialogRow)] call PFUNC(ui_dialogAdd);
{ _combo lbAdd _x } forEach _options;

_selected = (_selected min (count _options - 1)) max 0;
_combo lbSetCurSel _selected;
_combo setVariable [QPVAR(key), _key];
_combo ctrlAddEventHandler ["LBSelChanged", {
	params ["_combo", "_index"];
	(ctrlParent _combo) setVariable [_combo getVariable QPVAR(key), _index];
}];

_display setVariable [_key, _selected];
_display setVariable [format ["%1_ctrl", _key], _combo];
_combo
