#include "..\..\script_component.hpp"

/*
* Lists the factions that have infantry, with their infantry subcategories. Scanned once per game
* session (cached in uiNamespace), since it reads all of CfgVehicles.
*
* Arguments:
* None
*
* Return Value:
* Factions, sorted by name <ARRAY of [name, class, side number, icon, subcategories]>
*   subcategories: [name, class, unit count], most units first <ARRAY>
*
* Public: No
*/

private _cache = uiNamespace getVariable QPVAR(garrisonFactions);
if (!isNil "_cache") exitWith { _cache };

private _ignored = ["Men (Story)", "Men (Virtual Reality)"];
private _found = createHashMap; // faction -> [side, subcategory -> unit count]
{
	private _subcat = getText (_x >> "editorSubcategory");
	if !(getText (configFile >> "CfgEditorSubcategories" >> _subcat >> "displayName") in _ignored) then {
		private _faction = getText (_x >> "faction");
		private _entry = _found getOrDefaultCall [_faction, { [getNumber (_x >> "side"), createHashMap] }, true];
		private _counts = _entry select 1;
		_counts set [_subcat, (_counts getOrDefault [_subcat, 0]) + 1];
	};
} forEach ("getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'side') in [0, 1, 2, 3]} && {configName _x isKindOf 'CAManBase'}" configClasses (configFile >> "CfgVehicles"));

private _factions = [];
{
	_y params ["_side", "_counts"];
	private _cfgFaction = configFile >> "CfgFactionClasses" >> _x;
	private _subcats = [];
	{ _subcats pushBack [-_y, getText (configFile >> "CfgEditorSubcategories" >> _x >> "displayName"), _x] } forEach _counts;
	_subcats sort true;
	_factions pushBack [
		getText (_cfgFaction >> "displayName"),
		_x,
		_side,
		getText (_cfgFaction >> "icon"),
		_subcats apply { [_x select 1, _x select 2, -(_x select 0)] }
	];
} forEach _found;
_factions sort true;

uiNamespace setVariable [QPVAR(garrisonFactions), _factions];
_factions
