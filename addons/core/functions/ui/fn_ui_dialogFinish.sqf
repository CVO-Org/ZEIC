#include "..\..\script_component.hpp"

/*
* Finishes a ZEIC dialog: a small row with "Description (?)" and "Shortcuts (?)" below the rows (the texts
* are their tooltips, so the dialog keeps its height in every language), Cancel and the confirm button below
* the background, then centers the dialog on screen. Enter confirms, Escape cancels.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Description, or [description, shortcuts]: tooltip texts, 1-2 lines each, "
" for a new line
*    <STRING or ARRAY of STRINGs> (empty: no label)
* 2: Text of the confirm button <STRING>
* 3: Code run on confirm, gets the display as _this; the dialog closes afterwards <CODE>
*
* Return Value:
* None
*
* Public: No
*/

params ["_ctx", ["_description", "", ["", []]], ["_confirmText", "OK", [""]], ["_onConfirm", {}, [{}]]];

private _display = _ctx get "display";

if (_description isEqualType "") then { _description = [_description] };
_description params [["_descriptionText", "", [""]], ["_shortcutsText", "", [""]]];

private _hints = [[LLSTRING(Description), _descriptionText], [LLSTRING(Shortcuts), _shortcutsText]] select { (_x select 1) != "" };
if (_hints isNotEqualTo []) then {
	// A gap above the row
	_ctx set ["y", (_ctx get "y") + UI_H(0.4)];
	{
		_x params ["_label", "_text"];
		private _ctrl = [_ctx, QPVAR(ctrlDescription), [(_ctx get "x") + _forEachIndex * UI_W(6.5), _ctx get "y", UI_W(6), UI_H(1)]] call PFUNC(ui_dialogAdd);
		_ctrl ctrlSetText format ["%1 (?)", _label];
		_ctrl ctrlSetTooltip _text;
	} forEach _hints;
	_ctx set ["y", (_ctx get "y") + UI_H(1.1)];
};

// The background ends half a row below the last row, the buttons follow with a small gap
private _background = _ctx get "background";
private _bottom = (_ctx get "y") - UI_H(0.1) + UI_H(0.5);
(_background getVariable QPVAR(relPos)) params ["_bx", "_by", "_bw"];
_background setVariable [QPVAR(relPos), [_bx, _by, _bw, _bottom - _by]];

private _buttonY = _bottom + UI_H(0.1);
private _cancel = [_ctx, QPVAR(ctrlButtonCancel), [0, _buttonY, UI_W(5), UI_H(1)]] call PFUNC(ui_dialogAdd);
private _confirm = [_ctx, QPVAR(ctrlButtonOK), [UI_W(22), _buttonY, UI_W(5), UI_H(1)]] call PFUNC(ui_dialogAdd);
_cancel ctrlSetText LLSTRING(Cancel);
_confirm ctrlSetText _confirmText;

_display setVariable [QPVAR(onConfirm), _onConfirm];
_confirm ctrlAddEventHandler ["ButtonClick", { [ctrlParent (_this select 0)] call PFUNC(ui_dialogConfirm) }];
_cancel ctrlAddEventHandler ["ButtonClick", { (ctrlParent (_this select 0)) closeDisplay 2 }];
_display displayAddEventHandler ["KeyDown", {
	params ["_display", "_key"];
	if (_key in [28, 156]) exitWith { [_display] call PFUNC(ui_dialogConfirm); true }; // Enter, numpad Enter
	false
}];

// Everything moves to the center of the screen
private _x0 = safeZoneX + (safeZoneW - UI_W(27)) / 2;
private _y0 = safeZoneY + (safeZoneH - _buttonY - UI_H(1)) / 2;

{
	(_x getVariable [QPVAR(relPos), [0, 0, 0, 0]]) params ["_rx", "_ry", "_rw", "_rh"];
	_x ctrlSetPosition [_x0 + _rx, _y0 + _ry, _rw, _rh];
	_x ctrlCommit 0;
} forEach (_ctx get "controls");

ctrlSetFocus _confirm;
