#include "..\..\script_component.hpp"

// Called by the Interior Fill dialog (or the Alt shortcut). The work itself is done by PFUNC(interiorFill_start).
params [
		["_type", 0],
		["_area", 0],
		["_objectMode", OBJECT_MODE_SIMPLE],
		["_allowDamage", false],
		["_chance", 100]
	];

private _categories = call PFUNC(interiorFill_categories);
private _fillType = (_categories param [_type, _categories select 0]) select 1;
private _fillArea = _area isNotEqualTo 0;

// Save UI Settings for next time
PVAR(UiInteriorType) = _type;
PVAR(UiInteriorRadius) = _area;
PVAR(UiInteriorObjects) = _objectMode;
PVAR(UiInteriorDamage) = _allowDamage;
PVAR(UiInteriorChance) = _chance;

private _bldTmp = missionNamespace getVariable [QPVAR(UiLastBuilding), objNull];
private _bldArr = [];

if (isNull _bldTmp || _fillArea) then {
	// Around the spot where the module was placed (the mouse is over the dialog by now)
	private _center = missionNamespace getVariable [QPVAR(UiLastPosition), screenToWorld getMousePosition];
	_bldTmp = nearestObjects [_center, ["Building"], [_area, 15] select (_area isEqualTo 0), true];
	// Candidates: buildings with positions, or with a template entry in this category (e.g. bunkers, towers), or listed via PFUNC(addCustomHouse)
	_bldArr = _bldTmp select {
		((_x buildingPos 0) isNotEqualTo [0,0,0])
		|| {isClass (configFile >> "CfgZEIC" >> _fillType >> typeOf _x)}
		|| {isClass (missionConfigFile >> "CfgZEIC" >> _fillType >> typeOf _x)}
		|| {typeOf _x in (missionNamespace getVariable [QPVAR(additionalBuildings), []])}
	};

	if (_fillArea) then {
		// Chance: a random share of the buildings that aren't furnished yet (at least one)
		if (_chance < 100) then {
			_bldArr = [_bldArr select { isNull (_x getVariable [QPVAR(furnished), objNull]) && {!(_x getVariable [QPVAR(queued), false])} }, _chance] call PFUNC(misc_selectShare);
		};
	} else {
		_bldArr resize 1;
	};
} else {
	_bldArr = [_bldTmp];
};

_bldArr = _bldArr - [objNull];

// Don't continue if no objects were found.
if (_bldArr isEqualTo []) exitWith {
	[LLSTRING(ModuleInteriorFill_NoBuildingsFound), "INFO"] call PFUNC(misc_logMsg);
};

// Processed over several frames by the queue, see PFUNC(interiorFill_start).
[_bldArr, _fillType, [_objectMode, _allowDamage]] call PFUNC(interiorFill_start);
