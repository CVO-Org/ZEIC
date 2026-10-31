#include "..\..\script_component.hpp"

/*
* Adds a labelled row of segment buttons (one choice out of a few) to a ZEIC dialog.
* Wraps into more rows if there are more options than columns. The selected index is stored on the display.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key (display variable that holds the selected index) <STRING>
* 2: Label <STRING>
* 3: Options <ARRAY of STRINGs>
* 4: Selected index <NUMBER>
* 5: Tooltips, one per option <ARRAY of STRINGs> (default: none)
* 6: Columns <NUMBER> (default: 3)
*
* Return Value:
* Buttons <ARRAY of CONTROLs>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_options", [], [[]]], ["_selected", 0, [0]], ["_tooltips", [], [[]]], ["_columns", 3, [0]]];

[_ctx, _label] call PFUNC(ui_dialogLabel);

private _display = _ctx get "display";
private _pad = _ctx get "pad";
private _gap = UI_GW;
private _columns = _columns min (count _options) max 1;
private _w = ((_ctx get "w") - 2 * _pad - (_columns - 1) * _gap) / _columns;
private _h = 6 * UI_GH;
private _y = _ctx get "y";

private _buttons = [];
{
	private _text = _x;
	private _px = _pad + (_forEachIndex mod _columns) * (_w + _gap);
	private _py = _y + (floor (_forEachIndex / _columns)) * (_h + UI_GH);

	private _button = [_ctx, QPVAR(ctrlSegment), [_px, _py, _w, _h]] call PFUNC(ui_dialogAdd);
	_button ctrlSetText _text;
	if (_forEachIndex < count _tooltips) then { _button ctrlSetTooltip (_tooltips select _forEachIndex) };

	// Accent bar under the selected segment
	private _bar = [_ctx, QPVAR(ctrlAccentLine), [_px, _py + _h - 0.5 * UI_GH, _w, 0.5 * UI_GH]] call PFUNC(ui_dialogAdd);
	_button setVariable [QPVAR(bar), _bar];
	_button setVariable [QPVAR(key), _key];
	_button setVariable [QPVAR(index), _forEachIndex];
	_button ctrlAddEventHandler ["ButtonClick", {
		params ["_button"];
		[ctrlParent _button, _button getVariable QPVAR(key), _button getVariable QPVAR(index)] call PFUNC(ui_dialogSelect);
	}];
	_buttons pushBack _button;
} forEach _options;

_display setVariable [format ["%1_buttons", _key], _buttons];
[_display, _key, (_selected min (count _options - 1)) max 0] call PFUNC(ui_dialogSelect);

private _rows = ceil (count _options / _columns);
_ctx set ["y", _y + _rows * (_h + UI_GH) + 2 * UI_GH];
_buttons
