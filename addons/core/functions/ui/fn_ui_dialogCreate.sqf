#include "..\..\script_component.hpp"

/*
* Starts a ZEIC dialog on an (empty) display: the rounded window and its header.
* Rows are added top to bottom with PFUNC(ui_dialogLabel), _dialogSegments, _dialogSlider and _dialogToggle,
* PFUNC(ui_dialogFinish) adds the footer and centers the dialog. Sizes are relative to the screen height
* (UI_GH = 1 %). Values of the rows are stored on the display (getVariable with their key).
*
* Arguments:
* 0: Display <DISPLAY>
* 1: Title <STRING>
* 2: Subtitle <STRING>
* 3: Width in units <NUMBER> (default: 60)
*
* Return Value:
* Dialog context <HASHMAP>
*
* Public: No
*/

params [["_display", displayNull, [displayNull]], ["_title", "", [""]], ["_subtitle", "", [""]], ["_width", 60, [0]]];

private _ctx = createHashMapFromArray [
	["display", _display],
	["w", _width * UI_GW],
	["pad", 3 * UI_GW],
	["y", 0],
	["controls", []],
	// code run once the controls are in place, gets the display
	["onLayout", []]
];

// Its height is set by PFUNC(ui_dialogFinish)
_ctx set ["window", [_ctx, [0, 0, _ctx get "w", 0], 1.2 * UI_GH, UI_C_WINDOW] call PFUNC(ui_dialogPanel)];

private _inner = (_ctx get "w") - 2 * (_ctx get "pad");
([_ctx, QPVAR(ctrlTitle), [_ctx get "pad", 2 * UI_GH, _inner, 3.6 * UI_GH]] call PFUNC(ui_dialogAdd)) ctrlSetText _title;
([_ctx, QPVAR(ctrlSubtitle), [_ctx get "pad", 5.4 * UI_GH, _inner, 3 * UI_GH]] call PFUNC(ui_dialogAdd)) ctrlSetText _subtitle;
[_ctx, [0, 9.6 * UI_GH, _ctx get "w", pixelH], 0, UI_C_LINE] call PFUNC(ui_dialogPanel);

_ctx set ["y", 11.6 * UI_GH];
_ctx
