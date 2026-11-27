#include "..\..\script_component.hpp"

/*
* Sets the value of a row of a ZEIC dialog from script, like picking it by hand: the control shows it and the
* display stores it (key as for the PFUNC(ui_dialogCombo) etc. rows). Works for checkboxes, a list of checkboxes
* (PFUNC(ui_dialogCheckboxes), value: the ticked values), sliders, toolboxes, dropdowns and text fields.
* A slider runs its code on change, as when dragged.
*
* Arguments:
* 0: Display <DISPLAY>
* 1: Key <STRING>
* 2: Value <BOOL, NUMBER, STRING or ARRAY>
*
* Return Value:
* Set (false: the dialog has no such row) <BOOL>
*
* Public: No
*/

params [["_display", displayNull, [displayNull]], ["_key", "", [""]], "_value"];

private _ctrl = _display getVariable [format ["%1_ctrl", _key], controlNull];

// A list of checkboxes
if (_ctrl isEqualType []) exitWith {
	if !(_value isEqualType []) exitWith { false };
	{ _x cbSetChecked ((_x getVariable QPVAR(value)) in _value) } forEach _ctrl;
	_display setVariable [_key, (_ctrl select { cbChecked _x }) apply { _x getVariable QPVAR(value) }];
	true
};
if (isNull _ctrl || {isNil "_value"}) exitWith { false };

private _type = ctrlType _ctrl;
switch (true) do {
	case (_type == 77 && {_value isEqualType true}): { // checkbox
		_ctrl cbSetChecked _value;
		_display setVariable [_key, _value];
		true
	};
	case (_type in [3, 43] && {_value isEqualType 0}): { // slider and its text field
		_ctrl sliderSetPosition _value;
		private _stored = [_ctrl, sliderPosition _ctrl] call (_ctrl getVariable QPVAR(store));
		(_ctrl getVariable QPVAR(edit)) ctrlSetText str _stored;
		true
	};
	case (_type in [4, 6] && {_value isEqualType 0}): { // dropdown, toolbox
		_value = (_value min (lbSize _ctrl - 1)) max 0;
		_ctrl lbSetCurSel _value;
		_display setVariable [_key, _value];
		true
	};
	case (_type == 2 && {_value isEqualType ""}): { // text field
		_ctrl ctrlSetText _value;
		_display setVariable [_key, _value];
		true
	};
	default { false };
}
