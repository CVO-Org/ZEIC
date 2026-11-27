#include "..\..\script_component.hpp"

/*
* Checks a preset's settings against the loaded mods: categories, fill modifiers and the faction + subcategory that
* don't exist (e.g. from a mod that isn't loaded) are left out, with a note in chat and the RPT. The rest stays.
*
* Arguments:
* 0: Preset name, for the note <STRING>
* 1: Settings <HASHMAP>
*
* Return Value:
* Settings without the missing entries (a copy) <HASHMAP>
*
* Example:
* ["Fortified farmhouse", _settings] call ZEIC_fnc_advancedFill_presetCheck
*
* Public: No
*/

params [["_name", "", [""]], ["_settings", createHashMap, [createHashMap]]];

_settings = +_settings;
private _skipped = [];

{
	_x params ["_key", "_known"];
	if (_key in _settings) then {
		private _values = _settings get _key;
		if !(_values isEqualType []) then { _values = [] };
		private _kept = [];
		{
			if (_x isEqualType "" && {(toLower _x) in _known}) then { _kept pushBack toLower _x } else { _skipped pushBack ([str _x, _x] select (_x isEqualType "")) };
		} forEach _values;
		_settings set [_key, _kept];
	};
} forEach [
	["categories", (call PFUNC(interiorFill_categories)) apply { _x select 1 }],
	["modifiers", (call PFUNC(fillModifiers_list)) apply { _x select 1 }]
];

if ("pair" in _settings) then {
	(_settings get "pair") params [["_faction", "", [""]], ["_subcat", "", [""]]];
	private _factions = call PFUNC(garrisonBuilding_factions);
	private _index = _factions findIf { (_x select 1) == _faction };
	if (_index == -1 || {((_factions select _index) select 4) findIf { (_x select 1) == _subcat } == -1}) then {
		_skipped pushBack format ["%1 / %2", _faction, _subcat];
		_settings deleteAt "pair";
	};
};

if (_skipped isNotEqualTo []) then {
	[format [LLSTRING(ModuleAdvancedFill_Preset_Skipped), _name, _skipped joinString ", "], "WARNING"] call PFUNC(misc_logMsg);
};

_settings
