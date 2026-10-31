#include "..\..\script_component.hpp"

/*
* Garrisons buildings with units of a faction, processed over several frames by the queue.
* Units are created locally (in Zeus they stay local to the Zeus, like any Zeus-placed unit). One group per building.
*
* Arguments:
* 0: Buildings <ARRAY of OBJECTs>
* 1: Faction class <STRING>
* 2: Editor subcategory class <STRING>
* 3: Options [units per building <NUMBER>, dynamic simulation <BOOL>, create "move AI" trigger <BOOL>] <ARRAY>
*
* Return Value:
* None
*
* Example:
* [[cursorObject], "BLU_F", "EdSubcat_Personnel", [4, false, false]] call ZEIC_fnc_garrisonBuilding_start
*
* Public: Yes
*/

params [["_buildings", [], [[]]], ["_factClass", "", [""]], ["_catClass", "", [""]], ["_options", [], [[]]]];
_options params [["_units", 4, [0]], ["_forceDS", false, [false]], ["_createTR", false, [false]]];

private _unitTypes = [_factClass, _catClass] call PFUNC(garrisonBuilding_unitTypes);
if (_unitTypes isEqualTo []) exitWith {
	[format ["No units found for faction: %1", _factClass], "ERROR"] call PFUNC(misc_logMsg);
};

_buildings = _buildings select { !isNull _x && {(_x buildingPos -1) isNotEqualTo []} };
_buildings = [_buildings arrayIntersect _buildings] call PFUNC(queue_sortBuildings);
if (_buildings isEqualTo []) exitWith {
	["Garrison: no buildings with positions selected.", "ERROR"] call PFUNC(misc_logMsg);
};

private _side = switch (getNumber (configFile >> "CfgFactionClasses" >> _factClass >> "side")) do {
	case 0: { east };
	case 1: { west };
	case 3: { civilian };
	default { independent };
};

{
	_x setVariable [QPVAR(garrisoned), true];
	[_x, FEEDBACK_QUEUED] call PFUNC(feedback_report);
} forEach _buildings;

[createHashMapFromArray [
	["step", PFUNC(garrisonBuilding_step)],
	["buildings", _buildings],
	["index", 0],
	["faction", getText (configFile >> "CfgFactionClasses" >> _factClass >> "displayName")],
	["side", _side],
	["unitTypes", _unitTypes],
	["units", 1 max round _units],
	["forceDS", _forceDS],
	["createTR", _createTR],
	// current building
	["current", objNull],
	["positions", []],
	["group", grpNull],
	["tempUnit", objNull],
	["layer", -1],
	["spawned", []],
	// results
	["buildingCount", 0],
	["unitCount", 0]
]] call PFUNC(queue_add);
