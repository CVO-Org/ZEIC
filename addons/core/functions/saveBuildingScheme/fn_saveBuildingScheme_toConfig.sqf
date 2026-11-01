#include "..\..\script_component.hpp"

/*
* Saves the objects around a building as a ZEIC template in config syntax (CfgZEIC, see docs/config-schema.md),
* ready to paste into a mission's description.ext or a template addon.
*
* Arguments:
* 0: Building <OBJECT>
* 1: Objects around it (the building itself, arrows and logics are left out) <ARRAY of OBJECTs>
*
* Return Value:
* Lines of the template <ARRAY of STRINGs>
*
* Public: No
*/

params [["_keyObj", objNull, [objNull]], ["_nearObjects", [], [[]]]];
private _keyObjType = typeOf _keyObj;

private _mods = [];
private _entries = [];
{
	private _xType = typeOf _x;
	private _blacklisted = (_xType select [0, 11]) isEqualTo "Sign_Arrow_" || {_xType in ["Logic", "CamCurator", _keyObjType]};

	if (!_blacklisted) then {
		if !(_xType call PFUNC(isVanillaObject)) then {
			_mods pushBackUnique (configSourceMod (configFile >> "CfgVehicles" >> _xType));
		};

		private _objPos = _keyObj worldToModel (getPosATL _x);
		private _objDir = round ((getDir _x) - (getDir _keyObj));
		private _pb = _x call BIS_fnc_getPitchBank;
		private _pitch = ((abs (_pb#0)) + 360) mod 360;
		private _bank = ((abs (_pb#1)) + 360) mod 360;

		// If the pitch/bank isn't significant, ignore it
		if (_pitch + _bank < 5) then {
			_entries pushBack [_xType, _objPos, _objDir];
		} else {
			private _orgVec = [vectorDir _x, vectorUp _x];
			_x setVectorDirAndUp [[0,1,0],[0,0,1]]; // Realign object direction to get correct worldToModel position.
			_objPos = _keyObj worldToModel (getPosATL _x);
			_x setVectorDirAndUp _orgVec;  // Revert to original orientation.
			_entries pushBack [_xType, _objPos, _objDir, ([_x] call PFUNC(misc_Vector2Eden)) apply { round _x }];
		};
	};
} forEach _nearObjects;

// Config syntax of CfgZEIC (docs/config-schema.md), ready for description.ext: missions use it whenever ZEIC is loaded
private _fnc_number = { _this toFixed 3 };
private _time = systemTimeUTC select [0, 6] apply { if (_x < 10) then { "0" + str _x } else { str _x } };
private _templateName = format ["saved_%1%2%3_%4%5%6", _time select 0, _time select 1, _time select 2, _time select 3, _time select 4, _time select 5];

private _lines = [
	"// ZEIC template, made with Save Building Scheme. Paste it into the mission's description.ext:",
	"// class CfgZEIC { class civ { /* here */ }; };  (category: mil, civ, cbrn or your own)"
];
if (_mods isNotEqualTo []) then { _lines pushBack format ["// Uses objects from: %1", (_mods - [""]) joinString ", "] };
_lines append [format ["class %1 {", _keyObjType], format ["    class %1 {", _templateName], "        objects[] = {"];
{
	_x params ["_type", "_pos", "_dir", ["_rot", []]];
	private _entry = format ['{"%1", {%2, %3, %4}, %5', _type, (_pos select 0) call _fnc_number, (_pos select 1) call _fnc_number, (_pos select 2) call _fnc_number, _dir];
	if (_rot isNotEqualTo []) then { _entry = _entry + format [", {%1, %2, %3}", _rot select 0, _rot select 1, _rot select 2] };
	_lines pushBack format ["            %1}%2", _entry, ["", ","] select (_forEachIndex < count _entries - 1)];
} forEach _entries;
_lines append ["        };", "    };", "};"];

_lines
