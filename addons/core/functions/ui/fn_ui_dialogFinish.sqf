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
private _bodyHeight = (_ctx get "y") + 0.6 * UI_GH;
private _buttonW = 13 * UI_GW;
private _buttonH = 4.6 * UI_GH;
private _buttonY = _bodyHeight + 2 * UI_GH;
private _height = _buttonY + _buttonH + 2 * UI_GH;

[_ctx, [0, _bodyHeight, _w, pixelH], 0, UI_C_LINE] call PFUNC(ui_dialogPanel);
([_ctx, QPVAR(ctrlHint), [_pad, _buttonY, _w - 2 * _pad - 2 * _buttonW - 2 * UI_GW, _buttonH]] call PFUNC(ui_dialogAdd)) ctrlSetText _hint;

private _fnc_button = {
	params ["_bx", "_text", "_kind"];
	private _pos = [_bx, _buttonY, _buttonW, _buttonH];
	private _pieces = [_ctx, _pos, 0.8 * UI_GH, UI_C_FIELD] call PFUNC(ui_dialogPanel);
	private _label = [_ctx, QPVAR(ctrlTextCenter), _pos] call PFUNC(ui_dialogAdd);
	_label ctrlSetText _text;
	if (_kind == "primary") then { _label ctrlSetFont "RobotoCondensedBold" };
	[_ctx, _pos, _pieces, _label, _kind] call PFUNC(ui_dialogHit)
};
private _cancel = [_w - _pad - 2 * _buttonW - UI_GW, LLSTRING(UI_Cancel), "secondary"] call _fnc_button;
private _confirm = [_w - _pad - _buttonW, _confirmText, "primary"] call _fnc_button;

_display setVariable [QPVAR(onConfirm), _onConfirm];
_confirm ctrlAddEventHandler ["ButtonClick", { [ctrlParent (_this select 0)] call PFUNC(ui_dialogConfirm) }];
_cancel ctrlAddEventHandler ["ButtonClick", { (ctrlParent (_this select 0)) closeDisplay 2 }];
_display displayAddEventHandler ["KeyDown", {
	params ["_display", "_key"];
	if (_key in [28, 156]) exitWith { [_display] call PFUNC(ui_dialogConfirm); true }; // Enter, numpad Enter
	false
}];

// The window gets its height, then everything moves to the center of the screen, on whole pixels
[_ctx get "window", [0, 0, _w, _height], 1.2 * UI_GH] call PFUNC(ui_panelLayout);
private _x0 = safeZoneX + (round ((safeZoneW - _w) / 2 / pixelW)) * pixelW;
private _y0 = safeZoneY + (round ((safeZoneH - _height) / 2 / pixelH)) * pixelH;

{
	(_x getVariable [QPVAR(relPos), [0, 0, 0, 0]]) params ["_rx", "_ry", "_rw", "_rh"];
	_x ctrlSetPosition [_x0 + _rx, _y0 + _ry, _rw, _rh];
	_x ctrlCommit 0;
} forEach (_ctx get "controls");

{
	_x params ["_ctrl", "_code"];
	[_ctrl] call _code;
} forEach (_ctx get "onLayout");

ctrlSetFocus _confirm;
