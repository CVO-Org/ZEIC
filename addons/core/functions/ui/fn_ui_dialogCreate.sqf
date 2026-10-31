#include "..\..\script_component.hpp"

/*
* Starts a ZEIC dialog on an (empty) display: background card and header.
* Rows are added top to bottom with PFUNC(ui_dialogLabel), _dialogSegments, _dialogSlider and _dialogToggle,
* PFUNC(ui_dialogFinish) adds the footer and centers the dialog. Sizes use the UI grid, so they follow
* the game's UI size setting. Values of the rows are stored on the display (getVariable with their key).
*
* Arguments:
* 0: Display <DISPLAY>
* 1: Title <STRING>
* 2: Subtitle <STRING>
* 3: Width in grid units <NUMBER> (default: 76)
*
* Return Value:
* Dialog context <HASHMAP>
*
* Public: No
*/

params [["_display", displayNull, [displayNull]], ["_title", "", [""]], ["_subtitle", "", [""]], ["_width", 76, [0]]];

private _ctx = createHashMapFromArray [
	["display", _display],
	["w", _width * UI_GW],
	["pad", 3 * UI_GW],
	["y", 0],
	["controls", []]
];

// Its height is set by PFUNC(ui_dialogFinish)
_ctx set ["background", [_ctx, QPVAR(ctrlBackground), [0, 0, _ctx get "w", 0]] call PFUNC(ui_dialogAdd)];

private _inner = (_ctx get "w") - 2 * (_ctx get "pad");
([_ctx, QPVAR(ctrlTitle), [_ctx get "pad", 1.5 * UI_GH, _inner, 5 * UI_GH]] call PFUNC(ui_dialogAdd)) ctrlSetText _title;
([_ctx, QPVAR(ctrlSubtitle), [_ctx get "pad", 6 * UI_GH, _inner, 4 * UI_GH]] call PFUNC(ui_dialogAdd)) ctrlSetText _subtitle;
[_ctx, QPVAR(ctrlLine), [0, 11 * UI_GH, _ctx get "w", pixelH]] call PFUNC(ui_dialogAdd);

_ctx set ["y", 13.5 * UI_GH];
_ctx
