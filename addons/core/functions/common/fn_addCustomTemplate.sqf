#include "..\..\script_component.hpp"

/*
* Adds custom interior templates for a building, used by PFUNC(findTemplates).
*
* Arguments:
* 0: Category, e.g. "mil", "civ", "cbrn" <STRING>
* 1: Data <STRING or ARRAY>
*    - STRING: the clipboard output of the Save Building Scheme module (case "Class": { [...] };)
*              or the legacy format "Class: [...]"
*    - ARRAY:  [buildingClass, template] or [buildingClass, [template, ...]]
*
* Return Value:
* Success <BOOL>
*
* Example:
* ["mil", "Land_House_Small_03_F: [[""Land_Pallets_F"",[1,2,0],90]]"] call ZEIC_fnc_addCustomTemplate
*
* Public: Yes
*/

params [
	["_type", "", [""]],
	["_data", "", ["", []]]
];

_type = toLower _type;
if (_type isEqualTo "") exitWith { ["No category passed.", "ERROR"] call PFUNC(misc_logMsg); false };

private _bld = "";
private _templates = [];

if (_data isEqualType []) then {
	_data params [["_dataBld", "", [""]], ["_dataTemplates", [], [[]]]];
	_bld = _dataBld;
	_templates = _dataTemplates;
} else {
	// Building class: between the first pair of quotes (scheme output: case "Class": {...}), otherwise before the first ':' (legacy)
	private _arrayStart = -1;

	if ((toLower trim _data) find "case" == 0) then {
		private _quoteStart = _data find """";
		private _quoteEnd = _data find ["""", _quoteStart + 1];
		_bld = _data select [_quoteStart + 1, _quoteEnd - _quoteStart - 1];
		_arrayStart = _data find ["[", _quoteEnd];
	} else {
		private _colon = _data find ":";
		if (_colon != -1) then {
			_bld = _data select [0, _colon];
			_arrayStart = _data find ["[", _colon];
		};
	};

	// Save Building Scheme prefixes buildings with modded objects
	if (_bld find "[MOD] " == 0) then { _bld = _bld select [6] };
	_bld = trim _bld;

	if (_arrayStart != -1) then {
		private _arrayString = (_data select [_arrayStart]) trim [toString [9, 10, 13, 32, 59, 125], 2];
		_templates = parseSimpleArray _arrayString;
	};
};

if !(isClass (configFile >> "CfgVehicles" >> _bld)) exitWith {
	[format ["Building class '%1' not found in CfgVehicles.", _bld], "ERROR"] call PFUNC(misc_logMsg);
	false
};

// Use the config spelling, so the lookup by typeOf in PFUNC(findTemplates) matches.
_bld = configName (configFile >> "CfgVehicles" >> _bld);

if (_templates isEqualTo []) exitWith {
	[format ["No template data found for '%1'.", _bld], "ERROR"] call PFUNC(misc_logMsg);
	false
};

// A single template is a list of object entries ["Class", [x,y,z], dir, ...]: wrap it.
if ((_templates select 0) isEqualType [] && {((_templates select 0) param [0, []]) isEqualType ""}) then {
	_templates = [_templates];
};

private _varName = format ["%1_%2_customBuildings", QUOTE(PREFIX), _type];
private _custom = missionNamespace getVariable [_varName, []];
private _index = _custom findIf { (_x select 0) == _bld };

if (_index == -1) then {
	_index = _custom pushBack [_bld, []];
};

private _list = _custom select _index select 1;
{ _list pushBackUnique _x } forEach _templates;

missionNamespace setVariable [_varName, _custom];

true
