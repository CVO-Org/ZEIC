#include "..\..\script_component.hpp"

/*
* Switches the objects within a radius of the module to their counterpart in a camouflage set
* (CfgZEIC_ObjectSwitch, see docs/config-schema.md section 11). Called by the Object Switch dialog.
*
* Arguments:
* 0: Set class, e.g. "jungle"; the old set numbers 0-6 still work <STRING or NUMBER>
* 1: Radius <NUMBER>
*
* Return Value:
* None
*
* Public: No
*/

params [["_set", "desert", ["", 0]], ["_searchRadius", 50, [0]]];

// Old calls passed the position in the old dialog list
if (_set isEqualType 0) then {
	_set = ["desert", "jungle", "woodland", "cup_desert", "cup_woodland", "sog_brown", "sog_green"] param [_set, "desert"];
};

// Where the module was placed (see PFUNC(mod_objectSwitch))
private _pos = missionNamespace getVariable [QPVAR(UiLastPosition), screenToWorld getMousePosition];

// Save UI Settings for next time
PVAR(UiSwitchCombo) = _set;
PVAR(UiSwitchRadius) = _searchRadius;

if !(isClass (configFile >> "CfgZEIC_ObjectSwitch" >> "Sets" >> _set)) exitWith {
	[LLSTRING(MSG_OSNoSet), "ERROR"] call PFUNC(misc_logMsg);
};

private _toReplace = [];
{
	private _row = [typeOf _x] call PFUNC(objectSwitch_row);
	if (!isNull _row) then {
		private _replacement = getText (_row >> _set);
		if (_replacement != "" && {toLowerANSI _replacement != toLowerANSI typeOf _x} && {isClass (configFile >> "CfgVehicles" >> _replacement)}) then {
			_toReplace pushBack [_x, configName (configFile >> "CfgVehicles" >> _replacement)];
		};
	};
} forEach (nearestObjects [_pos, [], _searchRadius, true]);

if (_toReplace isEqualTo []) exitWith {
	[LLSTRING(MSG_OSNothing), "INFO"] call PFUNC(misc_logMsg);
};

private _count = 0;

if (is3DEN) then {
	collect3DENHistory {
		{ 
			_x params ["_original","_replacement"];
			[_original] set3DENObjectType _replacement;
		} forEach _toReplace;
	};
} else {
	{ 
		_x params ["_original","_replacement"];
		private _obj = createVehicle [_replacement, getPosATL _original, [], 0, "CAN_COLLIDE"];
		_obj setVectorDirAndUp [vectorDir _original, vectorUp _original];
		deleteVehicle _original;
	} forEach _toReplace;
};

[format [LLSTRING(MSG_OSDone), count _toReplace], "INFO"] call PFUNC(misc_logMsg);
