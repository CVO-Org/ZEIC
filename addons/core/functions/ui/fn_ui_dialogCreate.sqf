#include "..\..\script_component.hpp"

/*
* Starts a ZEIC dialog on an (empty) display, laid out like the dialogs of Zeus Enhanced: a title bar
* in the profile colour and a dark background. Rows are added top to bottom with PFUNC(ui_dialogCombo),
* _dialogSlider, _dialogToolbox and _dialogCheckbox; PFUNC(ui_dialogFinish) adds the buttons and
* centers the dialog. Values of the rows are stored on the display (getVariable with their key),
* their controls as "<key>_ctrl".
*
* Arguments:
* 0: Display <DISPLAY>
* 1: Title <STRING>
*
* Return Value:
* Dialog context <HASHMAP>
*
* Public: No
*/

params [["_display", displayNull, [displayNull]], ["_title", "", [""]]];

private _ctx = createHashMapFromArray [
	["display", _display],
	// left edge of the rows and the next row's top, relative to the dialog's top left corner
	["x", UI_W(0.5)],
	["y", UI_H(1.6)],
	["controls", []]
];

([_ctx, QPVAR(ctrlTitle), [0, 0, UI_W(27), UI_H(1)]] call PFUNC(ui_dialogAdd)) ctrlSetText _title;
// Its height is set by PFUNC(ui_dialogFinish)
_ctx set ["background", [_ctx, QPVAR(ctrlBackground), [0, UI_H(1) + UI_GAP, UI_W(27), 0]] call PFUNC(ui_dialogAdd)];

_ctx
