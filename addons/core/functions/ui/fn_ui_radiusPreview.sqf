#include "..\..\script_component.hpp"

/*
* Draws a circle on the ground for a radius slider while its dialog is open (Zeus and Eden),
* like ZEN does for its radius sliders. The circle follows the value stored on the display; at 0 nothing is drawn.
* The handler removes itself once the dialog is closed.
*
* Arguments:
* 0: Slider (see PFUNC(ui_dialogSlider)) <CONTROL>
* 1: Center: position AGL or object <ARRAY or OBJECT>
*
* Return Value:
* Event handler ID, -1 without a center <NUMBER>
*
* Public: No
*/

params [["_slider", controlNull, [controlNull]], ["_center", [], [[], objNull]]];

if (isNull _slider || {_center isEqualTo objNull} || {_center isEqualTo []}) exitWith { -1 };

private _eh = addMissionEventHandler ["EachFrame", {
	_thisArgs params ["_slider", "_center"];
	if (isNull _slider) exitWith { removeMissionEventHandler [_thisEvent, _thisEventHandler] };

	private _radius = (ctrlParent _slider) getVariable [_slider getVariable QPVAR(key), 0];
	if (_radius <= 0) exitWith {};

	if (_center isEqualType objNull) then { _center = ASLToAGL getPosASLVisual _center };
	_center params ["_cx", "_cy"];

	// About one segment per 3 m, so large circles stay round
	private _segments = (ceil (_radius / 3)) max 24 min 180;
	private _step = 360 / _segments;
	private _from = [_cx + _radius, _cy, 0.3];
	for "_i" from 1 to _segments do {
		private _to = [_cx + _radius * cos (_i * _step), _cy + _radius * sin (_i * _step), 0.3];
		drawLine3D [_from, _to, RADIUS_PREVIEW_COLOR, RADIUS_PREVIEW_WIDTH];
		_from = _to;
	};
}, [_slider, _center]];
_slider setVariable [QPVAR(previewEH), _eh];
_eh
