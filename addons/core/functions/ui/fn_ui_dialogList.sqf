#include "..\..\script_component.hpp"

/*
* Adds a list to a ZEIC dialog: the label across the full width, the list below it (like ZEN's lists).
* The selected index (-1: none) is stored on the display; the caller fills the list.
* With column positions it is a multi-column list (ListNBox, filled with lnbAddRow), otherwise a plain list box.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Label <STRING>
* 3: Height of the list in rows <NUMBER>
* 4: Tooltip <STRING> (default: none)
* 5: Code run on change, gets [display, index, control] <CODE> (default: none)
* 6: Column [left, width] in grid units, for lists side by side <ARRAY> (default: [0, 26], the full width)
* 7: Start a new row below the list <BOOL> (default: true; false for all but the last list side by side)
* 8: Column positions, 0-1 of the list's width <ARRAY of NUMBERs> (default: [], a plain list box)
*
* Return Value:
* List box or ListNBox <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_rows", 5, [0]], ["_tooltip", "", [""]], ["_onChange", {}, [{}]], ["_column", [0, 26], [[]], 2], ["_advance", true, [true]], ["_columns", [], [[]]]];
_column params ["_left", "_width"];

private _display = _ctx get "display";
private _x0 = (_ctx get "x") + UI_W(_left);
private _y = _ctx get "y";

private _labelCtrl = [_ctx, QPVAR(ctrlLabel), [_x0, _y, UI_W(_width), UI_H(1)]] call PFUNC(ui_dialogAdd);
_labelCtrl ctrlSetText _label;
if (_tooltip != "") then { _labelCtrl ctrlSetTooltip _tooltip };

private _list = [_ctx, [QPVAR(ctrlList), QPVAR(ctrlListN)] select (_columns isNotEqualTo []), [_x0, _y + UI_H(1), UI_W(_width), UI_H(_rows)]] call PFUNC(ui_dialogAdd);
if (_columns isNotEqualTo []) then { _list lnbSetColumnsPos _columns };
_list setVariable [QPVAR(key), _key];
_list setVariable [QPVAR(onChange), _onChange];
_list ctrlAddEventHandler ["LBSelChanged", {
	params ["_list", "_index"];
	private _display = ctrlParent _list;
	_display setVariable [_list getVariable QPVAR(key), _index];
	[_display, _index, _list] call (_list getVariable QPVAR(onChange));
}];

_display setVariable [_key, -1];
_display setVariable [format ["%1_ctrl", _key], _list];

if (_advance) then { _ctx set ["y", _y + UI_H(1 + _rows) + UI_GAP] };
_list
