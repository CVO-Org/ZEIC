#include "..\..\script_component.hpp"

/*
* Picks the buildings to garrison around a position: all buildings with building positions within the radius
* that aren't garrisoned yet, then a random share of them.
*
* Arguments:
* 0: Center <POSITION or OBJECT>
* 1: Radius in meters <NUMBER>
* 2: Share of buildings to occupy in percent, 1-100 <NUMBER>
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

private _count = 1 max (ceil ((count _buildings) * ((_percent min 100) max 1) / 100));
(_buildings call BIS_fnc_arrayShuffle) select [0, _count]
