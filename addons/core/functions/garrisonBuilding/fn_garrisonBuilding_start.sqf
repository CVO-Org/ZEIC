#include "..\..\script_component.hpp"

/*
* Garrisons buildings with units of a faction, processed over several frames by the queue.
* Units are created locally (in Zeus they stay local to the Zeus, like any Zeus-placed unit). One group per building.
*
* Arguments:
* 0: Buildings <ARRAY of OBJECTs>
* 1: Faction class <STRING>
* 2: Editor subcategory class <STRING>
* 3: Options [positions to fill in percent <NUMBER>, dynamic simulation <BOOL>, create "move AI" trigger <BOOL>] <ARRAY>
*    The units per building are a percentage of its positions, see PFUNC(garrisonBuilding_unitCounts).
*    A 4th element, a link id, garrisons each building only once its interior is done (Advanced Fill, see PFUNC(advancedFill_start)).
*    A 5th element, Eden layers shared with the interior <HASHMAP>, see PFUNC(advancedFill_layer).
*
* Return Value:
* None
*
* Example:
* [[cursorObject], "BLU_F", "EdSubcat_Personnel", [50, false, false]] call ZEIC_fnc_garrisonBuilding_start
*
* Public: Yes
*/

params [["_buildings", [], [[]]], ["_factClass", "", [""]], ["_catClass", "", [""]], ["_options", [], [[]]]];
_options params [["_percent", 50, [0]], ["_forceDS", false, [false]], ["_createTR", false, [false]], ["_linkId", "", [""]], ["_layers", createHashMap, [createHashMap]]];

private _unitTypes = [_factClass, _catClass] call PFUNC(garrisonBuilding_unitTypes);
if (_unitTypes isEqualTo []) exitWith {
	[format [LLSTRING(ModuleGarrisonBuilding_NoUnits), _factClass], "ERROR"] call PFUNC(misc_logMsg);
};

_buildings = _buildings select { !isNull _x && {(_x buildingPos -1) isNotEqualTo []} };
_buildings = [_buildings arrayIntersect _buildings] call PFUNC(queue_sortBuildings);
if (_buildings isEqualTo []) exitWith {
	[LLSTRING(ModuleGarrisonBuilding_NoBuildings), "ERROR"] call PFUNC(misc_logMsg);
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
	["unitCounts", [_buildings apply { count (_x buildingPos -1) }, _percent] call PFUNC(garrisonBuilding_unitCounts)],
	["forceDS", _forceDS],
	["createTR", _createTR],
	["linkId", _linkId],
	["layers", _layers],
	["triggerLayer", -1],
	["waitSince", -1],
	// current building
	["current", objNull],
	["positions", []],
	["group", grpNull],
	["tempUnit", objNull],
	["layer", -1],
	["fillLayer", -1],
	["spawned", []],
	// results
	["buildingCount", 0],
	["unitCount", 0]
]] call PFUNC(queue_add);
