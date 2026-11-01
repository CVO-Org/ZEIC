#include "..\..\script_component.hpp"

/*
* Finds the interior templates of a building in a category.
*
* Sources, in this order:
* - addon config:   configFile >> "CfgZEIC" >> category >> building (cached in uiNamespace, config can't change during a game session)
* - mission config: missionConfigFile >> "CfgZEIC" >> category >> building (cached in missionNamespace)
* - script API:     ZEIC_<category>_customBuildings, see PFUNC(addCustomTemplate)
*
* Each building class holds one class per template with an objects[] array; inherited template classes count too
* (buildings sharing a layout inherit from each other). Templates with an object class that doesn't exist are skipped,
* and reported once per building in the RPT.
*
* Arguments:
* 0: Building or building class <OBJECT or STRING>
* 1: Category, e.g. "mil" <STRING>
* 2: Info only: don't ask for a template in chat if there is none <BOOL>
*
* Return Value:
* Templates: arrays of object entries ["Class", [x, y, z], direction, [rotX, rotY, rotZ]] <ARRAY>
*
* Example:
* [cursorObject, "mil"] call ZEIC_fnc_findTemplates
*
* Public: Yes
*/

params [["_bld", objNull, [objNull, ""]], ["_category", "mil", [""]], ["_infoOnly", false, [false]]];

private _class = if (_bld isEqualType "") then { _bld } else { typeOf _bld };
_category = toLower _category;
private _key = _category + "|" + toLower _class;

[format ["Passed - B: %1 T: %2 I: %3", _class, _category, _infoOnly], "DEBUG"] call PFUNC(misc_logMsg);

// Keeps the templates whose objects all exist (class check cached for the game session), reports the others once.
private _fnc_valid = {
	params ["_templates", "_source"];

	private _classExists = uiNamespace getVariable QPVAR(classExists);
	if (isNil "_classExists") then {
		_classExists = createHashMap;
		uiNamespace setVariable [QPVAR(classExists), _classExists];
	};

	private _missing = [];
	private _valid = _templates select {
		(_x findIf {
			private _object = _x select 0;
			private _exists = _classExists getOrDefault [toLower _object, -1];
			if (_exists isEqualTo -1) then {
				_exists = isClass (configFile >> "CfgVehicles" >> _object);
				_classExists set [toLower _object, _exists];
			};
			if (!_exists) then { _missing pushBackUnique _object };
			!_exists
		}) == -1
	};

	// RPT only: on a first large fill, chat would get one line per building class.
	if (_missing isNotEqualTo []) then {
		diag_log text format ["[ZEI][WARNING][findTemplates] - %1 of %2 %3 template(s) for %4 (%5) skipped, missing objects: %6", count _templates - count _valid, count _templates, _source, _class, toUpper _category, _missing joinString ", "];
	};

	_valid
};

private _fnc_read = {
	params ["_root"];
	private _cfg = _root >> "CfgZEIC" >> _category >> _class;
	if (!isClass _cfg) exitWith { [] };
	(configProperties [_cfg, "isClass _x", true]) apply { getArray (_x >> "objects") }
};

// ---- addon config
private _addonCache = uiNamespace getVariable QPVAR(templateCache);
if (isNil "_addonCache") then {
	_addonCache = createHashMap;
	uiNamespace setVariable [QPVAR(templateCache), _addonCache];
};
private _templates = _addonCache getOrDefault [_key, -1];
if (_templates isEqualTo -1) then {
	_templates = [[configFile] call _fnc_read, "addon"] call _fnc_valid;
	_addonCache set [_key, _templates];
};
_templates = +_templates;

// ---- mission config
private _missionCache = missionNamespace getVariable QPVAR(missionTemplateCache);
if (isNil "_missionCache") then {
	_missionCache = createHashMap;
	missionNamespace setVariable [QPVAR(missionTemplateCache), _missionCache];
};
private _missionTemplates = _missionCache getOrDefault [_key, -1];
if (_missionTemplates isEqualTo -1) then {
	_missionTemplates = [[missionConfigFile] call _fnc_read, "mission"] call _fnc_valid;
	_missionCache set [_key, _missionTemplates];
};
_templates append _missionTemplates;

// ---- script API (can change at any time, not cached)
private _custom = missionNamespace getVariable [format ["%1_%2_customBuildings", QUOTE(PREFIX), _category], []];
private _index = _custom findIf { (_x select 0) == _class };
if (_index != -1) then {
	_templates append ([(_custom select _index) param [1, []], "custom"] call _fnc_valid);
};

// Don't spam messages if there is an area to fill
if (!_infoOnly && {_templates isEqualTo []} && {sizeOf _class > 2}) then {
	[format [LLSTRING(ModuleInteriorFill_NoTemplate), _class, getText (configFile >> "CfgVehicles" >> _class >> "displayName")], "INFO"] call PFUNC(misc_logMsg);
};

_templates
