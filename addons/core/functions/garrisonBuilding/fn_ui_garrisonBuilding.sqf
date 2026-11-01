#include "..\..\script_component.hpp"

// Called by the Garrison Building dialog (or the Alt shortcut). The work itself is done by PFUNC(garrisonBuilding_start).
params [
		["_gType", ""],
		["_positions", 50],
		["_forceDS", true],
		["_createTR", false],
		["_radius", 0],
		["_percent", 50]
	];

[format["Passed - F: %1 Pos: %2 DS: %3 TR: %4 R: %5 P: %6", _gType, _positions, _forceDS, _createTR, _radius, _percent], "DEBUG"] call PFUNC(misc_logMsg);

private _bld = missionNamespace getVariable [QPVAR(UiLastBuilding), objNull];

// Split out the faction and category classes
(_gType splitString "#") params [["_factClass", ""], ["_catClass", ""]];

// Save UI Settings for next time
PVAR(UiGarrisonFaction) = _factClass;
PVAR(UiGarrisonCategory) = _catClass;
PVAR(UiGarrisonPositions) = _positions;
PVAR(UiGarrisonDynamic) = _forceDS;
PVAR(UiCreateTrigger) = _createTR;
PVAR(UiGarrisonRadius) = _radius;
PVAR(UiGarrisonPercent) = _percent;

// Radius 0: only the selected building. Otherwise a share of the buildings around it.
private _buildings = if (_radius > 0) then {
	[getPos _bld, _radius, _percent] call PFUNC(garrisonBuilding_selectBuildings)
} else {
	[_bld]
};

[_buildings, _factClass, _catClass, [_positions, _forceDS, _createTR]] call PFUNC(garrisonBuilding_start);
