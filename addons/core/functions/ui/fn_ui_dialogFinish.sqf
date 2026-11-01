#include "..\..\script_component.hpp"

/*
* Finishes a ZEIC dialog: a grey help bar below the background with "Description (?)" and "Shortcuts (?)"
* (the texts are their tooltips, so the dialog keeps its height in every language), Cancel and the confirm
* button below it, then centers the dialog on screen. Enter confirms, Escape cancels.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Description, or [description, shortcuts]: tooltip texts, 1-2 lines each, "\n" for a new line
*    <STRING or ARRAY of STRINGs> (no shortcuts: the tooltip says "None", so every dialog has the same bar)
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

if (_shortcutsText == "") then { _shortcutsText = LLSTRING(Shortcuts_None) };

// The background ends half a row below the last row
private _background = _ctx get "background";
private _bottom = (_ctx get "y") - UI_H(0.1) + UI_H(0.5);
(_background getVariable QPVAR(relPos)) params ["_bx", "_by", "_bw"];
_background setVariable [QPVAR(relPos), [_bx, _by, _bw, _bottom - _by]];

// The help bar follows with the same gap as between the title and the background: two halves, a divider between them
private _helpY = _bottom + UI_H(0.1);
[_ctx, QPVAR(ctrlHelpBar), [0, _helpY, UI_W(27), UI_H(1)]] call PFUNC(ui_dialogAdd);
{
	_x params ["_label", "_text"];
	private _ctrl = [_ctx, QPVAR(ctrlHelp), [_forEachIndex * UI_W(13.5), _helpY, UI_W(13.5), UI_H(1)]] call PFUNC(ui_dialogAdd);
	_ctrl ctrlSetText format ["%1 (?)", _label];
	_ctrl ctrlSetTooltip _text;
} forEach [[LLSTRING(Description), _descriptionText], [LLSTRING(Shortcuts), _shortcutsText]];
[_ctx, QPVAR(ctrlHelpDivider), [UI_W(13.5), _helpY, pixelW, UI_H(1)]] call PFUNC(ui_dialogAdd);

private _buttonY = _helpY + UI_H(1.1);
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
