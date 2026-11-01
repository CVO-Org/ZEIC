#include "..\..\script_component.hpp"

/*
* Picks the buildings to garrison around a position: all buildings with building positions within the radius
* that aren't garrisoned yet, then a random share of them (see PFUNC(misc_selectShare)).
*
* Arguments:
* 0: Center <POSITION or OBJECT>
* 1: Radius in meters <NUMBER>
* 2: Share of buildings to occupy in percent, 1-100 <NUMBER> (default: 50; 100 returns all of them)
*
* Return Value:
* Buildings, at least one if any were found <ARRAY of OBJECTs>
*
* Public: No
*/

params [["_center", [0,0,0], [[], objNull]], ["_radius", 50, [0]], ["_percent", 50, [0]]];

private _buildings = (nearestObjects [_center, ["Building"], _radius, true]) select {
	(_x buildingPos -1) isNotEqualTo []
	&& {!(_x getVariable [QPVAR(garrisoned), false])}
};

if (_buildings isEqualTo []) exitWith { [] };

[_buildings, _percent] call PFUNC(misc_selectShare)
