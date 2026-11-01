#include "..\..\script_component.hpp"

/*
* Picks the building positions of a garrison in the given order, skipping any position closer than GARRISON_SPACING
* to one already picked (some buildings have positions almost on top of each other).
*
* Arguments:
* 0: Positions of the building <ARRAY of POSITIONs> - e.g. from buildingPos -1
* 1: Indices of the positions to pick from, in order of preference <ARRAY of NUMBERs>
* 2: How many to pick at most <NUMBER>
*
* Return Value:
* Picked indices <ARRAY of NUMBERs>
*
* Example:
* [[[0,0,0], [0.5,0,0], [2,0,0]], [0, 1, 2], 3] call ZEIC_fnc_garrisonBuilding_spreadPositions // [0, 2]
*
* Public: No
*/

params [["_positions", [], [[]]], ["_indices", [], [[]]], ["_count", 0, [0]]];

private _picked = [];
{
	if (count _picked >= _count) exitWith {};
	private _pos = _positions select _x;
	if (_picked findIf { ((_positions select _x) distance _pos) < GARRISON_SPACING } == -1) then { _picked pushBack _x };
} forEach _indices;

_picked
