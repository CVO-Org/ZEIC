#include "..\..\script_component.hpp"

/*
* Deletes an Advanced Fill preset from the profile. Read-only presets from config can't be deleted.
*
* Arguments:
* 0: Name <STRING>
*
* Return Value:
* Deleted <BOOL>
*
* Example:
* ["Fortified farmhouse"] call ZEIC_fnc_advancedFill_presetDelete
*
* Public: Yes
*/

params [["_name", "", [""]]];

if (([false] call PFUNC(advancedFill_presets)) findIf { (_x select 2) && {(_x select 0) == _name} } != -1) exitWith {
	[format [LLSTRING(ModuleAdvancedFill_Preset_ReadOnly), _name], "ERROR"] call PFUNC(misc_logMsg);
	false
};

private _presets = call PFUNC(advancedFill_presetProfile);
if (isNil "_presets") exitWith { false };

private _index = _presets findIf { (_x select 0) == _name };
if (_index == -1) exitWith { false };
_presets deleteAt _index;

[_presets] call PFUNC(advancedFill_presetProfile)
