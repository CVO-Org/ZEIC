#include "..\..\script_component.hpp"

/*
* EachFrame handler: draws the wireframe boxes. Only in Eden or while in the Zeus camera.
*
* Public: No
*/

if (!is3DEN && {isNull curatorCamera}) exitWith {};

{
	_x params ["", "_lines", "_color", "_width"];
	{ drawLine3D [_x select 0, _x select 1, _color, _width] } forEach _lines;
} forEach PVAR(feedback);
