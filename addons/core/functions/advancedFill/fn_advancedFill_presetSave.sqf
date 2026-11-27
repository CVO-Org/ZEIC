#include "..\..\script_component.hpp"

/*
* Saves Advanced Fill settings as a preset in the profile, or overwrites the profile preset of that name (names don't
* depend on upper/lower case). The name of a read-only preset from config can't be used.
* Only the settings keys of PFUNC(ui_advancedFill) are saved; categories, fill modifiers and the faction are class names.
*
* Arguments:
* 0: Name <STRING>
* 1: Settings <HASHMAP>
*
* Return Value:
* Saved <BOOL>
*
* Example:
* ["Fortified farmhouse", ZEIC_UiAdvancedFill] call ZEIC_fnc_advancedFill_presetSave
*
* Public: Yes
*/

params [["_name", "", [""]], ["_settings", createHashMap, [createHashMap]]];

_name = trim _name;
if (_name == "") exitWith {
	[LLSTRING(ModuleAdvancedFill_Preset_NoName), "ERROR"] call PFUNC(misc_logMsg);
	false
};

if (([false] call PFUNC(advancedFill_presets)) findIf { (_x select 2) && {(_x select 0) == _name} } != -1) exitWith {
	[format [LLSTRING(ModuleAdvancedFill_Preset_ReadOnly), _name], "ERROR"] call PFUNC(misc_logMsg);
	false
};

private _presets = call PFUNC(advancedFill_presetProfile);
if (isNil "_presets") exitWith { false };

private _keys = ["interior", "categories", "objects", "damage", "modifiers", "garrison", "pair", "positions", "dynamic", "trigger", "radius", "percent", "collision", "blocked"];
private _stored = [];
{
	if (_x in _settings) then { _stored pushBack [_x, +(_settings get _x)] };
} forEach _keys;

private _index = _presets findIf { (_x select 0) == _name };
if (_index == -1) then { _presets pushBack [_name, _stored] } else { _presets set [_index, [_name, _stored]] };

[_presets] call PFUNC(advancedFill_presetProfile)
