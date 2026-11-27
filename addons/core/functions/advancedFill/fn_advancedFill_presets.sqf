#include "..\..\script_component.hpp"

/*
* Lists the Advanced Fill presets: first the read-only ones from config (CfgZEIC_Presets in the addon config and the
* mission config, see docs/config-schema.md), sorted by their "order" property (default 100), then by display name;
* then the ones saved in the profile (see PFUNC(advancedFill_presetProfile)), sorted by name.
* A mission class with the name of an addon preset replaces it.
*
* A preset's settings are the keys of PFUNC(ui_advancedFill)'s settings hashmap. A config preset only has the keys
* its class sets: applying it leaves the other settings of the dialog as they are.
*
* Arguments:
* 0: With the profile presets <BOOL> (default: true)
*
* Return Value:
* Presets [[name, settings <HASHMAP>, read-only <BOOL>], ...] <ARRAY>
*
* Example:
* call ZEIC_fnc_advancedFill_presets
*
* Public: Yes
*/

params [["_withProfile", true, [true]]];

private _config = createHashMap;
{
	{
		private _cfg = _x;
		private _settings = createHashMap;
		{
			_x params ["_key", "_property"];
			if (isNumber (_cfg >> _property)) then { _settings set [_key, getNumber (_cfg >> _property) != 0] };
		} forEach [["interior", "interior"], ["damage", "damage"], ["garrison", "garrison"], ["dynamic", "dynamic"], ["trigger", "trigger"], ["collision", "collision"]];
		{
			if (isNumber (_cfg >> _x)) then { _settings set [_x, getNumber (_cfg >> _x)] };
		} forEach ["objects", "positions", "radius", "percent", "blocked"];
		{
			if (isArray (_cfg >> _x)) then { _settings set [_x, (getArray (_cfg >> _x)) select { _x isEqualType "" } apply { toLower _x }] };
		} forEach ["categories", "modifiers"];
		if (isText (_cfg >> "faction")) then { _settings set ["pair", [getText (_cfg >> "faction"), getText (_cfg >> "subcategory")]] };

		private _name = getText (_cfg >> "displayName");
		if (_name == "") then { _name = configName _cfg };
		private _order = [100, getNumber (_cfg >> "order")] select (isNumber (_cfg >> "order"));
		_config set [toLower configName _cfg, [_order, _name, _settings]];
	} forEach ("true" configClasses (_x >> "CfgZEIC_Presets"));
} forEach [configFile, missionConfigFile];

private _list = values _config;
_list sort true;
private _presets = _list apply { [_x select 1, _x select 2, true] };

if (_withProfile) then {
	private _profile = [] call PFUNC(advancedFill_presetProfile);
	if (isNil "_profile") exitWith {};
	private _sorted = _profile apply { [toLower (_x select 0), _x select 0, _x select 1] };
	_sorted sort true;
	_presets append (_sorted apply { [_x select 1, createHashMapFromArray (_x select 2), false] });
};

_presets
