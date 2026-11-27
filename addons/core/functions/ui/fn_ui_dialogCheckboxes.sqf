#include "..\..\script_component.hpp"

/*
* Adds a row of checkboxes to a ZEIC dialog, e.g. to tick several categories: the label on the left, the options
* in columns on the right (a checkbox and its name each), as many rows as needed. The values of the checked
* options, in the order of the options, are stored on the display; the checkboxes as "<key>_ctrl" (in that order).
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Label <STRING>
* 3: Options [[name, value <STRING>, tooltip (optional)], ...] <ARRAY>
* 4: Checked values <ARRAY of STRINGs>
* 5: Tooltip of the label <STRING> (default: none)
* 6: Columns <NUMBER> (default: 2)
* 7: Code run on change, gets [display, checked values, checkbox] <CODE> (default: none)
*
* Return Value:
* Checkboxes <ARRAY of CONTROLs>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_options", [], [[]]], ["_checked", [], [[]]], ["_tooltip", "", [""]], ["_columns", 2, [0]], ["_onChange", {}, [{}]]];

private _display = _ctx get "display";
private _columnW = UI_W(15.9) / _columns;
private _checkboxes = [];

for "_row" from 0 to (ceil (count _options / _columns)) - 1 do {
	([_ctx, [_label, ""] select (_row > 0), [_tooltip, ""] select (_row > 0)] call PFUNC(ui_dialogRow)) params ["_cx", "_cy", "", "_ch"];
	{
		_x params ["_name", "_value", ["_optionTooltip", ""]];
		private _left = _cx + _forEachIndex * _columnW;
		private _checkbox = [_ctx, QPVAR(ctrlCheckbox), [_left, _cy, UI_W(1), _ch]] call PFUNC(ui_dialogAdd);
		_checkbox cbSetChecked (_value in _checked);
		_checkbox setVariable [QPVAR(value), _value];
		private _text = [_ctx, QPVAR(ctrlLabel), [_left + UI_W(1.1), _cy, _columnW - UI_W(1.2), _ch]] call PFUNC(ui_dialogAdd);
		_text ctrlSetText _name;
		// The tooltip shows the full name, in case it doesn't fit
		{ _x ctrlSetTooltip ([_name, _optionTooltip] select (_optionTooltip != "")) } forEach [_checkbox, _text];
		_checkboxes pushBack _checkbox;
	} forEach (_options select [_row * _columns, _columns]);
};

{
	_x setVariable [QPVAR(key), _key];
	_x setVariable [QPVAR(onChange), _onChange];
	_x ctrlAddEventHandler ["CheckedChanged", {
		params ["_checkbox"];
		private _display = ctrlParent _checkbox;
		private _key = _checkbox getVariable QPVAR(key);
		private _values = ((_display getVariable [format ["%1_ctrl", _key], []]) select { cbChecked _x }) apply { _x getVariable QPVAR(value) };
		_display setVariable [_key, _values];
		[_display, _values, _checkbox] call (_checkbox getVariable QPVAR(onChange));
	}];
} forEach _checkboxes;

_display setVariable [_key, (_checkboxes select { cbChecked _x }) apply { _x getVariable QPVAR(value) }];
_display setVariable [format ["%1_ctrl", _key], _checkboxes];
_checkboxes
