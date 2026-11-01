#include "..\..\script_component.hpp"

/*
* Picks the buildings of an Advanced Fill around a position: the buildings within the radius that are left to
* furnish (see PFUNC(interiorFill_isCandidate)) or to garrison (with building positions), then a random share of them.
*
* Arguments:
* 0: Center <POSITION or OBJECT>
* 1: Radius in meters <NUMBER>
* 2: Share of the buildings in percent, 1-100 <NUMBER>
* 3: Interior category, "" without interior <STRING>
* 4: Garrison <BOOL>
*
* Return Value:
* Buildings, at least one if any were found <ARRAY of OBJECTs>
*
* Public: No
*/

params [["_center", [0,0,0], [[], objNull]], ["_radius", 50, [0]], ["_percent", 100, [0]], ["_category", "", [""]], ["_garrison", true, [true]]];

private _buildings = (nearestObjects [_center, ["Building"], _radius, true]) select {
	(_category != ""
		&& {isNull (_x getVariable [QPVAR(furnished), objNull])}
		&& {!(_x getVariable [QPVAR(queued), false])}
		&& {[_x, _category] call PFUNC(interiorFill_isCandidate)})
	|| {_garrison
		&& {(_x buildingPos -1) isNotEqualTo []}
		&& {!(_x getVariable [QPVAR(garrisoned), false])}}
};

[_buildings, _percent] call PFUNC(misc_selectShare)
