#include "..\..\script_component.hpp"

/*
* Called by the Advanced Fill dialog (or the Alt shortcut): saves the settings for next time, picks the buildings
* and starts the fill. The work itself is done by PFUNC(advancedFill_start).
*
* Arguments:
* 0: Settings <HASHMAP>
*    "interior" <BOOL>, "category" (index in PFUNC(interiorFill_categories)) <NUMBER>, "objects" (object mode) <NUMBER>,
*    "damage" <BOOL>, "garrison" <BOOL>, "pair" [faction, subcategory] <ARRAY>, "positions" <NUMBER>,
*    "dynamic" <BOOL>, "trigger" <BOOL>, "radius" <NUMBER>, "percent" <NUMBER>,
*    "collision" <BOOL>, "blocked" (COLLISION_UNITS_GIVE_WAY or COLLISION_FURNITURE_GIVES_WAY) <NUMBER>
*
* Return Value:
* None
*
* Public: No
*/

params [["_settings", createHashMap, [createHashMap]]];

PVAR(UiAdvancedFill) = +_settings;

private _interior = _settings getOrDefault ["interior", true];
private _garrison = _settings getOrDefault ["garrison", true];
private _radius = _settings getOrDefault ["radius", 0];
private _categories = call PFUNC(interiorFill_categories);
private _category = (_categories param [_settings getOrDefault ["category", 0], _categories select 0]) select 1;

private _bld = missionNamespace getVariable [QPVAR(UiLastBuilding), objNull];
private _buildings = if (_radius > 0) then {
	[getPos _bld, _radius, _settings getOrDefault ["percent", 50], ["", _category] select _interior, _garrison] call PFUNC(advancedFill_selectBuildings)
} else {
	[_bld] - [objNull]
};

if (_buildings isEqualTo []) exitWith {
	[LLSTRING(ModuleAdvancedFill_NoBuildings), "ERROR"] call PFUNC(misc_logMsg);
};

(_settings getOrDefault ["pair", []]) params [["_faction", ""], ["_subcat", ""]];

[
	_buildings,
	[[], [_category, [_settings getOrDefault ["objects", OBJECT_MODE_SIMPLE], _settings getOrDefault ["damage", false]]]] select _interior,
	[[], [_faction, _subcat, [_settings getOrDefault ["positions", 50], _settings getOrDefault ["dynamic", false], _settings getOrDefault ["trigger", false]]]] select _garrison,
	[COLLISION_OFF, _settings getOrDefault ["blocked", COLLISION_UNITS_GIVE_WAY]] select (_settings getOrDefault ["collision", true])
] call PFUNC(advancedFill_start);
