#include "..\..\script_component.hpp"

/*
* Adds a labelled slider with its current value on the right to a ZEIC dialog. The value is stored on the display.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Label <STRING>
* 3: Range [min, max, step] <ARRAY>
* 4: Value <NUMBER>
* 5: Formatter: code that gets the value as _this and returns the text to show <CODE> (default: the number)
*
* Return Value:
* Slider <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_range", [0, 100, 1], [[]], 3], ["_value", 0, [0]], ["_formatter", { str _this }, [{}]]];
_range params ["_min", "_max", "_step"];

private _pad = _ctx get "pad";
private _inner = (_ctx get "w") - 2 * _pad;
private _y = _ctx get "y";

private _labelCtrl = [_ctx, QPVAR(ctrlLabel), [_pad, _y, _inner * 0.6, 3.5 * UI_GH]] call PFUNC(ui_dialogAdd);
_labelCtrl ctrlSetText toUpper _label;
private _valueCtrl = [_ctx, QPVAR(ctrlValue), [_pad + _inner * 0.6, _y - 0.25 * UI_GH, _inner * 0.4, 4 * UI_GH]] call PFUNC(ui_dialogAdd);
private _slider = [_ctx, QPVAR(ctrlSlider), [_pad, _y + 4 * UI_GH, _inner, 4.5 * UI_GH]] call PFUNC(ui_dialogAdd);

_value = (_value max _min) min _max;
_slider sliderSetRange [_min, _max];
_slider sliderSetSpeed [_step, _step];
_slider sliderSetPosition _value;

_slider setVariable [QPVAR(key), _key];
_slider setVariable [QPVAR(step), _step];
_slider setVariable [QPVAR(value), _valueCtrl];
_slider setVariable [QPVAR(formatter), _formatter];

private _fnc_update = {
	params ["_slider", "_position"];
	private _step = _slider getVariable QPVAR(step);
	private _value = (round (_position / _step)) * _step;
	(ctrlParent _slider) setVariable [_slider getVariable QPVAR(key), _value];
	(_slider getVariable QPVAR(value)) ctrlSetText (_value call (_slider getVariable QPVAR(formatter)));
};
_slider setVariable [QPVAR(update), _fnc_update];
_slider ctrlAddEventHandler ["SliderPosChanged", { _this call ((_this select 0) getVariable QPVAR(update)) }];
[_slider, _value] call _fnc_update;

_ctx set ["y", _y + 11 * UI_GH];
_slider
