#include "..\..\script_component.hpp"

/*
* Adds a slider row with a number field to a ZEIC dialog, like ZEN's sliders: drag the slider or type
* the value. The value, rounded to the step, is stored on the display.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Label <STRING>
* 3: Range [min, max, step] <ARRAY>
* 4: Value <NUMBER>
* 5: Tooltip <STRING> (default: none)
* 6: Radius preview: while the dialog is open, a circle of the slider's value is drawn around this
*    position or object (nothing at 0) <ARRAY or OBJECT> (default: [], none)
*
* Return Value:
* Slider <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_range", [0, 100, 1], [[]], 3], ["_value", 0, [0]], ["_tooltip", "", [""]], ["_previewCenter", [], [[], objNull]]];
_range params ["_min", "_max", "_step"];

private _display = _ctx get "display";
([_ctx, _label, _tooltip] call PFUNC(ui_dialogRow)) params ["_cx", "_cy", "", "_ch"];
private _slider = [_ctx, QPVAR(ctrlSlider), [_cx, _cy, UI_W(13.5), _ch]] call PFUNC(ui_dialogAdd);
private _edit = [_ctx, QPVAR(ctrlEdit), [_cx + UI_W(13.6), _cy + pixelH, UI_W(2.3), _ch - pixelH]] call PFUNC(ui_dialogAdd);

_value = (_value max _min) min _max;
_slider sliderSetRange [_min, _max];
_slider sliderSetSpeed [_step, _step];
_slider sliderSetPosition _value;
_edit ctrlSetText str _value;
if (_tooltip != "") then { _slider ctrlSetTooltip _tooltip; _edit ctrlSetTooltip _tooltip };

{ _slider setVariable _x } forEach [[QPVAR(key), _key], [QPVAR(step), _step], [QPVAR(edit), _edit]];
_edit setVariable [QPVAR(slider), _slider];

// Rounds a position to the step, stores it and returns it
_slider setVariable [QPVAR(store), {
	params ["_slider", "_position"];
	private _step = _slider getVariable QPVAR(step);
	private _value = (round (_position / _step)) * _step;
	(ctrlParent _slider) setVariable [_slider getVariable QPVAR(key), _value];
	_value
}];

_slider ctrlAddEventHandler ["SliderPosChanged", {
	params ["_slider", "_position"];
	private _value = [_slider, _position] call (_slider getVariable QPVAR(store));
	(_slider getVariable QPVAR(edit)) ctrlSetText str _value;
}];
_edit ctrlAddEventHandler ["KeyUp", {
	params ["_edit"];
	private _slider = _edit getVariable QPVAR(slider);
	_slider sliderSetPosition parseNumber ctrlText _edit;
	[_slider, sliderPosition _slider] call (_slider getVariable QPVAR(store));
}];
// Shows the value that is used, after typing something out of range or between steps
_edit ctrlAddEventHandler ["KillFocus", {
	params ["_edit"];
	private _slider = _edit getVariable QPVAR(slider);
	_edit ctrlSetText str ((ctrlParent _edit) getVariable (_slider getVariable QPVAR(key)));
}];

if (_previewCenter isNotEqualTo []) then {
	[_slider, _previewCenter] call PFUNC(ui_radiusPreview);
};

_display setVariable [_key, _value];
_display setVariable [format ["%1_ctrl", _key], _slider];
_slider
