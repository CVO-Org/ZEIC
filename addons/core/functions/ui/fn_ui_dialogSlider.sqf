#include "..\..\script_component.hpp"

/*
* Adds a labelled slider with its current value on the right to a ZEIC dialog. The value is stored on the display.
* Drawn as a rounded track with an amber fill and a round thumb; an invisible vanilla slider on top takes the input.
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
* Slider (input) <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_range", [0, 100, 1], [[]], 3], ["_value", 0, [0]], ["_formatter", { str _this }, [{}]]];
_range params ["_min", "_max", "_step"];

private _pad = _ctx get "pad";
private _inner = (_ctx get "w") - 2 * _pad;
private _y = _ctx get "y";
private _trackH = 0.9 * UI_GH;
private _trackY = _y + 4.4 * UI_GH;
private _inputOffset = 1.6 * UI_GH;

([_ctx, QPVAR(ctrlLabel), [_pad, _y, _inner * 0.6, 2.6 * UI_GH]] call PFUNC(ui_dialogAdd)) ctrlSetText toUpper _label;
private _valueCtrl = [_ctx, QPVAR(ctrlValue), [_pad + _inner * 0.4, _y - 0.3 * UI_GH, _inner * 0.6, 3.2 * UI_GH]] call PFUNC(ui_dialogAdd);

[_ctx, [_pad, _trackY, _inner, _trackH], _trackH / 2, UI_C_FIELD] call PFUNC(ui_dialogPanel);
private _fill = [_ctx, QPVAR(ctrlRect), [_pad, _trackY, 0, _trackH]] call PFUNC(ui_dialogAdd);
_fill ctrlSetBackgroundColor UI_C_ACCENT;
private _cap = [_ctx, QPVAR(ctrlCorner), [_pad, _trackY, 0, _trackH]] call PFUNC(ui_dialogAdd);
_cap ctrlSetText UI_TEX(circle_ca);
_cap ctrlSetTextColor UI_C_ACCENT;
private _thumb = [_ctx, QPVAR(ctrlCorner), [_pad, _trackY, 0, 0]] call PFUNC(ui_dialogAdd);
_thumb ctrlSetText UI_TEX(circle_ca);
_thumb ctrlSetTextColor UI_C_TEXT;

private _slider = [_ctx, QPVAR(ctrlSliderInput), [_pad, _trackY - _inputOffset, _inner, _trackH + 2 * _inputOffset]] call PFUNC(ui_dialogAdd);
_value = (_value max _min) min _max;
_slider sliderSetRange [_min, _max];
_slider sliderSetSpeed [_step, _step];
_slider sliderSetPosition _value;

{ _slider setVariable _x } forEach [
	[QPVAR(key), _key], [QPVAR(step), _step], [QPVAR(min), _min], [QPVAR(max), _max],
	[QPVAR(value), _valueCtrl], [QPVAR(formatter), _formatter],
	[QPVAR(fill), _fill], [QPVAR(cap), _cap], [QPVAR(thumb), _thumb],
	[QPVAR(trackOffset), _inputOffset], [QPVAR(trackH), _trackH]
];

private _fnc_update = {
	params ["_slider", "_position"];
	private _step = _slider getVariable QPVAR(step);
	private _min = _slider getVariable QPVAR(min);
	private _max = _slider getVariable QPVAR(max);
	private _value = (((round (_position / _step)) * _step) max _min) min _max;
	(ctrlParent _slider) setVariable [_slider getVariable QPVAR(key), _value];
	(_slider getVariable QPVAR(value)) ctrlSetText (_value call (_slider getVariable QPVAR(formatter)));

	// Track geometry from the input's on-screen position
	(ctrlPosition _slider) params ["_sx", "_sy", "_sw"];
	private _trackH = _slider getVariable QPVAR(trackH);
	private _trackY = _sy + (_slider getVariable QPVAR(trackOffset));
	private _capW = _trackH * pixelW / pixelH;
	private _thumbH = 2.6 * UI_GH;
	private _thumbW = _thumbH * pixelW / pixelH;
	private _fraction = if (_max > _min) then { (_value - _min) / (_max - _min) } else { 0 };
	private _center = _sx + _capW / 2 + _fraction * (_sw - _capW);

	{
		_x params ["_ctrl", "_pos"];
		_ctrl ctrlSetPosition _pos;
		_ctrl ctrlCommit 0;
	} forEach [
		[_slider getVariable QPVAR(cap), [_sx, _trackY, _capW, _trackH]],
		[_slider getVariable QPVAR(fill), [_sx + _capW / 2, _trackY, _center - _sx - _capW / 2, _trackH]],
		[_slider getVariable QPVAR(thumb), [_center - _thumbW / 2, _trackY + _trackH / 2 - _thumbH / 2, _thumbW, _thumbH]]
	];
};
_slider setVariable [QPVAR(update), _fnc_update];
_slider ctrlAddEventHandler ["SliderPosChanged", { _this call ((_this select 0) getVariable QPVAR(update)) }];

// The drawn parts need the final position
(_ctx get "onLayout") pushBack [_slider, { params ["_slider"]; [_slider, sliderPosition _slider] call (_slider getVariable QPVAR(update)) }];
(_ctx get "display") setVariable [_key, _value];

_ctx set ["y", _trackY + _trackH + 3 * UI_GH];
_slider
