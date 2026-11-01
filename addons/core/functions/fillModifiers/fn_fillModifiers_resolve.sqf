#include "..\..\script_component.hpp"

/*
* Reads the checked fill modifiers once per fill (see PFUNC(fillModifiers_apply)). Runs where the objects are created
* (the server in multiplayer). The modifiers are used in the order of PFUNC(fillModifiers_list); names that don't
* exist (e.g. from a mod that isn't loaded) are skipped. The mission config of a modifier comes first, then the addon
* config; each also with its subclasses (other than "replace"), which mods use to extend a modifier.
* - replace: the first candidate that exists, per object class; rules without one are dropped.
* - remove, keep: only classes that exist. Several modifiers with keep[]: an object matching any of them is kept.
*
* Arguments:
* 0: Modifier classes <ARRAY of STRINGs>
*
* Return Value:
* Modifiers, empty for none <HASHMAP>
*   "replace" [[object class, replacement], ...], "remove" [classes], "keep" [classes], "results" (cache) <HASHMAP>
*
* Example:
* [["coldwar"]] call ZEIC_fnc_fillModifiers_resolve
*
* Public: No
*/

params [["_names", [], [[]]]];

private _fnc_exists = { isClass (configFile >> "CfgVehicles" >> _this) };
private _wanted = _names apply { toLower _x };
private _replace = [];
private _remove = [];
private _keep = [];

{
	private _name = _x select 1;
	if (_name in _wanted) then {
		{
			private _modifier = _x >> "CfgZEIC_Modifiers" >> _name;
			{
				private _cfg = _x;
				{
					private _candidates = getArray _x;
					private _index = _candidates findIf { _x isEqualType "" && {_x call _fnc_exists} };
					if (_index != -1 && {configName _x call _fnc_exists}) then { _replace pushBack [configName _x, _candidates select _index] };
				} forEach configProperties [_cfg >> "replace", "isArray _x"];
				_remove append ((getArray (_cfg >> "remove")) select { _x isEqualType "" && {_x call _fnc_exists} });
				_keep append ((getArray (_cfg >> "keep")) select { _x isEqualType "" && {_x call _fnc_exists} });
			} forEach ([_modifier] + ("toLower configName _x != 'replace'" configClasses _modifier));
		} forEach [missionConfigFile, configFile];
	};
} forEach (call PFUNC(fillModifiers_list));

if (_replace isEqualTo [] && {_remove isEqualTo []} && {_keep isEqualTo []}) exitWith { createHashMap };

createHashMapFromArray [
	["replace", _replace],
	["remove", _remove arrayIntersect _remove],
	["keep", _keep arrayIntersect _keep],
	["results", createHashMap]
]
