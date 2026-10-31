#include "..\..\script_component.hpp"

/*
* Finishes a ZEIC dialog: footer with a hint, Cancel and the confirm button, then centers the dialog on screen.
* Enter confirms, Escape cancels.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Hint, shown on the left of the footer <STRING>
* 2: Text of the confirm button <STRING>
* 3: Code run on confirm, gets the display as _this; the dialog closes afterwards <CODE>
*
* Return Value:
* None
*
* Public: No
*/

params ["_ctx", ["_hint", "", [""]], ["_confirmText", "OK", [""]], ["_onConfirm", {}, [{}]]];

private _display = _ctx get "display";
private _w = _ctx get "w";
private _pad = _ctx get "pad";
private _bodyHeight = (_ctx get "y") + UI_GH;
private _footerHeight = 10 * UI_GH;
private _buttonW = 18 * UI_GW;
private _buttonH = 6 * UI_GH;
private _buttonY = _bodyHeight + 2 * UI_GH;

[_ctx, QPVAR(ctrlFooter), [0, _bodyHeight, _w, _footerHeight]] call PFUNC(ui_dialogAdd);
[_ctx, QPVAR(ctrlLine), [0, _bodyHeight, _w, pixelH]] call PFUNC(ui_dialogAdd);
([_ctx, QPVAR(ctrlHint), [_pad, _buttonY, _w - 2 * _pad - 2 * _buttonW - 2 * UI_GW, _buttonH]] call PFUNC(ui_dialogAdd)) ctrlSetText _hint;

private _confirm = [_ctx, QPVAR(ctrlButtonPrimary), [_w - _pad - _buttonW, _buttonY, _buttonW, _buttonH]] call PFUNC(ui_dialogAdd);
_confirm ctrlSetText _confirmText;
private _cancel = [_ctx, QPVAR(ctrlButton), [_w - _pad - 2 * _buttonW - UI_GW, _buttonY, _buttonW, _buttonH]] call PFUNC(ui_dialogAdd);
_cancel ctrlSetText LLSTRING(UI_Cancel);

_display setVariable [QPVAR(onConfirm), _onConfirm];
_confirm ctrlAddEventHandler ["ButtonClick", { [ctrlParent (_this select 0)] call PFUNC(ui_dialogConfirm) }];
_cancel ctrlAddEventHandler ["ButtonClick", { (ctrlParent (_this select 0)) closeDisplay 2 }];
_display displayAddEventHandler ["KeyDown", {
	params ["_display", "_key"];
	if (_key in [28, 156]) exitWith { [_display] call PFUNC(ui_dialogConfirm); true }; // Enter, numpad Enter
	false
}];

// Background height, then move everything to the center of the screen
private _height = _bodyHeight + _footerHeight;
((_ctx get "background") getVariable QPVAR(relPos)) set [3, _bodyHeight];
private _x0 = safeZoneX + (safeZoneW - _w) / 2;
private _y0 = safeZoneY + (safeZoneH - _height) / 2;

{
	(_x getVariable [QPVAR(relPos), [0, 0, 0, 0]]) params ["_rx", "_ry", "_rw", "_rh"];
	_x ctrlSetPosition [_x0 + _rx, _y0 + _ry, _rw, _rh];
	_x ctrlCommit 0;
} forEach (_ctx get "controls");

ctrlSetFocus _confirm;
