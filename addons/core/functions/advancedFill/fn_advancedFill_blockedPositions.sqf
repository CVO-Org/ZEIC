#include "..\..\script_component.hpp"

/*
* Collision check of an Advanced Fill: which building positions are blocked by fill objects.
* A position is blocked by an object if, in the object's model space, the horizontal distance from the position to
* its bounding box is below COLLISION_RADIUS and the box reaches into COLLISION_HEIGHT above the position:
* a table next to the spot doesn't count, one on it does. Works with simple objects and Eden entities.
*
* Arguments:
* 0: Positions <ARRAY of POSITIONs AGL> - e.g. from buildingPos
* 1: Objects <ARRAY of OBJECTs>
*
* Return Value:
* Indices of the blocked positions, ascending <ARRAY of NUMBERs>
*
* Example:
* [cursorObject buildingPos -1, nearestObjects [cursorObject, [], 20]] call ZEIC_fnc_advancedFill_blockedPositions
*
* Public: No
*/

params [["_positions", [], [[]]], ["_objects", [], [[]]]];

COLLISION_HEIGHT params ["_low", "_high"];
private _boxes = (_objects select { !isNull _x }) apply { [_x, 0 boundingBoxReal _x] };

private _blocked = [];
{
	private _pos = _x;
	if (_boxes findIf {
		_x params ["_obj", "_box"];
		_box params ["_min", "_max"];
		private _rel = _obj worldToModel _pos;
		private _dx = (((_min select 0) - (_rel select 0)) max ((_rel select 0) - (_max select 0))) max 0;
		private _dy = (((_min select 1) - (_rel select 1)) max ((_rel select 1) - (_max select 1))) max 0;
		(_dx ^ 2 + _dy ^ 2) < COLLISION_RADIUS ^ 2
		&& {(_max select 2) > (_rel select 2) + _low}
		&& {(_min select 2) < (_rel select 2) + _high}
	} != -1) then { _blocked pushBack _forEachIndex };
} forEach _positions;

_blocked
