#include "..\..\script_component.hpp"

/*
* Reads or writes the Advanced Fill presets saved in the profile (profileNamespace, PRESETS_VARIABLE):
* [PRESETS_VERSION, [[name, [[key, value], ...]], ...]]. Nothing saved yet reads as no presets.
* A different version (saved by another ZEIC version) isn't read and isn't overwritten: reading returns nil
* and writing does nothing, both with a note in chat and the RPT.
* The variable name can be changed with ZEIC_presetsVariable (for the tests, so they don't touch the real presets).
*
* Arguments:
* 0: Presets to save [[name, [[key, value], ...]], ...] <ARRAY> (default: nil = read)
*
* Return Value:
* Read: the presets <ARRAY>, nil on a version mismatch. Write: saved <BOOL>
*
* Public: No
*/

params [["_write", nil, [[]]]];

private _variable = missionNamespace getVariable [QPVAR(presetsVariable), PRESETS_VARIABLE];
private _data = profileNamespace getVariable [_variable, []];
if !(_data isEqualType []) then { _data = [] };

private _ok = _data isEqualTo [] || {(_data param [0, -1]) isEqualTo PRESETS_VERSION};
if (!_ok) exitWith {
	[format [LLSTRING(ModuleAdvancedFill_Preset_Version), _data param [0, "?"], PRESETS_VERSION], "WARNING"] call PFUNC(misc_logMsg);
	if (isNil "_write") then { nil } else { false }
};

if (isNil "_write") exitWith {
	private _presets = _data param [1, []];
	if !(_presets isEqualType []) then { _presets = [] };
	_presets select { _x isEqualTypeParams ["", []] }
};

profileNamespace setVariable [_variable, [PRESETS_VERSION, _write]];
saveProfileNamespace;
true
