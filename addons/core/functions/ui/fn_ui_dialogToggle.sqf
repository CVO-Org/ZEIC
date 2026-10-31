#include "..\..\script_component.hpp"

/*
* Adds a switch with its text to a ZEIC dialog. The state is stored on the display.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Text <STRING>
* 3: On <BOOL>
* 4: Tooltip <STRING> (default: none)
*
* Return Value:
* Click area <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_text", "", [""]], ["_checked", false, [false]], ["_tooltip", "", [""]]];

private _pad = _ctx get "pad";
private _y = _ctx get "y";
private _trackH = 2.4 * UI_GH;
private _trackW = 4.6 * UI_GW;

private _track = [_ctx, [_pad, _y, _trackW, _trackH], _trackH / 2, UI_C_FIELD_HOVER] call PFUNC(ui_dialogPanel);
private _knob = [_ctx, QPVAR(ctrlCorner), [_pad, _y, 0, 0]] call PFUNC(ui_dialogAdd);
_knob ctrlSetText UI_TEX(circle_ca);
private _label = [_ctx, QPVAR(ctrlText), [_pad + _trackW + 1.4 * UI_GW, _y, (_ctx get "w") - 2 * _pad - _trackW - 1.4 * UI_GW, _trackH]] call PFUNC(ui_dialogAdd);
_label ctrlSetText _text;

private _hit = [_ctx, [_pad, _y, (_ctx get "w") - 2 * _pad, _trackH], _track, _label, {
	params ["_hit"];
	private _on = _hit getVariable [QPVAR(selected), false];
	private _hover = _hit getVariable [QPVAR(hover), false];
	[_hit getVariable QPVAR(pieces), [[UI_C_FIELD_HOVER, UI_C_RAISED] select _hover, [UI_C_ACCENT, UI_C_ACCENT_HOVER] select _hover] select _on] call PFUNC(ui_panelColor);
	(_hit getVariable QPVAR(text)) ctrlSetTextColor ([UI_C_TEXT2, UI_C_TEXT] select (_on || _hover));

	// Knob on the left or right end of the track (set up after the first paint, placed once laid out)
	if (isNil {_hit getVariable QPVAR(knob)}) exitWith {};
	(ctrlPosition _hit) params ["_hx", "_hy", "", "_hh"];
	private _knobH = _hh * 0.72;
	private _knobW = _knobH * pixelW / pixelH;
	private _inset = (_hh - _knobH) / 2 * pixelW / pixelH;
	private _knob = _hit getVariable QPVAR(knob);
	_knob ctrlSetTextColor ([UI_C_TEXT, UI_C_ON_ACCENT] select _on);
	_knob ctrlSetPosition [[_hx + _inset, _hx + (_hit getVariable QPVAR(trackW)) - _inset - _knobW] select _on, _hy + (_hh - _knobH) / 2, _knobW, _knobH];
	_knob ctrlCommit 0;
}] call PFUNC(ui_dialogHit);

if (_tooltip != "") then { _hit ctrlSetTooltip _tooltip };
_hit setVariable [QPVAR(knob), _knob];
_hit setVariable [QPVAR(trackW), _trackW];
_hit setVariable [QPVAR(key), _key];
_hit setVariable [QPVAR(selected), _checked];
(_ctx get "display") setVariable [_key, _checked];

_hit ctrlAddEventHandler ["ButtonClick", {
	params ["_hit"];
	private _on = !(_hit getVariable [QPVAR(selected), false]);
	_hit setVariable [QPVAR(selected), _on];
	(ctrlParent _hit) setVariable [_hit getVariable QPVAR(key), _on];
	[_hit] call (_hit getVariable QPVAR(paint));
}];

(_ctx get "onLayout") pushBack [_hit, { params ["_hit"]; [_hit] call (_hit getVariable QPVAR(paint)) }];

_ctx set ["y", _y + _trackH + 2.2 * UI_GH];
_hit
