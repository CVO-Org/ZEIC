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
	// An even number, so the dashes alternate all the way round
	private _segments = 2 * ((ceil (_radius / 6)) max 12 min 90);
	private _step = 360 / _segments;
	private _points = [];
	for "_i" from 0 to _segments do {
		_points pushBack [_cx + _radius * cos (_i * _step), _cy + _radius * sin (_i * _step), 0.3];
	};
	// The dark outline first, the dashes on top
	for "_i" from 1 to _segments do {
		drawLine3D [_points select (_i - 1), _points select _i, RADIUS_PREVIEW_OUTLINE_COLOR, RADIUS_PREVIEW_OUTLINE_WIDTH];
	};
	private _colors = RADIUS_PREVIEW_COLORS;
	for "_i" from 1 to _segments do {
		drawLine3D [_points select (_i - 1), _points select _i, _colors select (_i mod 2), RADIUS_PREVIEW_WIDTH];
	};
}, [_slider, _center]];
_slider setVariable [QPVAR(previewEH), _eh];
_eh
