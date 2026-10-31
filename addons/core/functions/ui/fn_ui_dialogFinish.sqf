#include "..\..\script_component.hpp"

/*
* Finishes a ZEIC dialog: an optional description below the rows, Cancel and the confirm button below the background,
* then centers the dialog on screen. Enter confirms, Escape cancels.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Description: what the module does and how to use it, as many lines as it needs; several paragraphs
*    (e.g. a shortcut) get a gap between them <STRING or ARRAY of STRINGs> (empty: none)
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
{
	// A gap above the description and between its paragraphs
	_ctx set ["y", (_ctx get "y") + UI_H(0.4)];
	private _ctrl = [_ctx, QPVAR(ctrlDescription), [_ctx get "x", _ctx get "y", UI_W(26), UI_H(1)]] call PFUNC(ui_dialogAdd);
	_ctrl ctrlSetText _x;
	// The text wraps: its height is known once the control has its width
	_ctrl ctrlSetPosition [0, 0, UI_W(26), UI_H(1)];
	_ctrl ctrlCommit 0;
	private _h = (ctrlTextHeight _ctrl) max UI_H(1);
	_ctrl setVariable [QPVAR(relPos), [_ctx get "x", _ctx get "y", UI_W(26), _h]];
	_ctx set ["y", (_ctx get "y") + _h + UI_H(0.1)];
} forEach (_description select { _x != "" });

// The background ends half a row below the last row, the buttons follow with a small gap
private _background = _ctx get "background";
private _bottom = (_ctx get "y") - UI_H(0.1) + UI_H(0.5);
(_background getVariable QPVAR(relPos)) params ["_bx", "_by", "_bw"];
_background setVariable [QPVAR(relPos), [_bx, _by, _bw, _bottom - _by]];

private _buttonY = _bottom + UI_H(0.1);
private _cancel = [_ctx, QPVAR(ctrlButtonCancel), [0, _buttonY, UI_W(5), UI_H(1)]] call PFUNC(ui_dialogAdd);
private _confirm = [_ctx, QPVAR(ctrlButtonOK), [UI_W(22), _buttonY, UI_W(5), UI_H(1)]] call PFUNC(ui_dialogAdd);
_cancel ctrlSetText LLSTRING(UI_Cancel);
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
