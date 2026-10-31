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
* Click areas, one per option <ARRAY of CONTROLs>
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
private _h = 4.6 * UI_GH;
private _y = _ctx get "y";

private _hits = [];
{
	private _pos = [
		_pad + (_forEachIndex mod _columns) * (_w + _gap),
		_y + (floor (_forEachIndex / _columns)) * (_h + UI_GH),
		_w,
		_h
	];

	private _pieces = [_ctx, _pos, 0.8 * UI_GH, UI_C_FIELD] call PFUNC(ui_dialogPanel);
	private _text = [_ctx, QPVAR(ctrlTextCenter), _pos] call PFUNC(ui_dialogAdd);
	_text ctrlSetText _x;

	private _hit = [_ctx, _pos, _pieces, _text, "segment"] call PFUNC(ui_dialogHit);
	if (_forEachIndex < count _tooltips) then { _hit ctrlSetTooltip (_tooltips select _forEachIndex) };
	_hit setVariable [QPVAR(key), _key];
	_hit setVariable [QPVAR(index), _forEachIndex];
	_hit ctrlAddEventHandler ["ButtonClick", {
		params ["_hit"];
		[ctrlParent _hit, _hit getVariable QPVAR(key), _hit getVariable QPVAR(index)] call PFUNC(ui_dialogSelect);
	}];
	_hits pushBack _hit;
} forEach _options;

_display setVariable [format ["%1_buttons", _key], _hits];
[_display, _key, (_selected min (count _options - 1)) max 0] call PFUNC(ui_dialogSelect);

_ctx set ["y", _y + (ceil (count _options / _columns)) * (_h + UI_GH) + 1.4 * UI_GH];
_hits
