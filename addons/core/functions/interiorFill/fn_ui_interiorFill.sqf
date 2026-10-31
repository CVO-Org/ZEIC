#include "..\..\script_component.hpp"

params [
		["_type", 0],
		["_area", 0],
		["_objectMode", OBJECT_MODE_SIMPLE],
		["_allowDamage", false],
		["_detail", 1]
	];

private _categories = call PFUNC(interiorFill_categories);
private _fillType = (_categories param [_type, _categories select 0]) select 1;
private _fillArea = _area isNotEqualTo 0;

// Save UI Settings for next time
PVAR(UiInteriorType) = _type;
PVAR(UiInteriorDetail) = _detail;
PVAR(UiInteriorObjects) = _objectMode;
PVAR(UiInteriorDamage) = _allowDamage;

private _bldTmp = missionNamespace getVariable [QPVAR(UiLastBuilding), objNull];
private _bldArr = [];

if (isNull _bldTmp || _fillArea) then { 
	_bldTmp = nearestObjects [screenToWorld getMousePosition, ["Building"], [_area, 15] select (_area isEqualTo 0), true]; 
	// Candidates: buildings with positions, or with a template entry in this category (e.g. bunkers, towers), or listed via PFUNC(addCustomHouse)
	_bldArr = _bldTmp select {
		((_x buildingPos 0) isNotEqualTo [0,0,0])
		|| {isClass (configFile >> "CfgZEIC" >> _fillType >> typeOf _x)}
		|| {isClass (missionConfigFile >> "CfgZEIC" >> _fillType >> typeOf _x)}
		|| {typeOf _x in (missionNamespace getVariable [QPVAR(additionalBuildings), []])}
	};
	
	if !(_fillArea) then { _bldArr resize 1 };
} else {
	_bldArr = [_bldTmp];
};

_bldArr = _bldArr - [objNull];

// Don't continue if no objects were found.
if (_bldArr isEqualTo []) exitWith {
	["No valid objects within 25m", "INFO"] call PFUNC(misc_logMsg);
};

// Processed over several frames by the queue, see PFUNC(interiorFill_start).
[_bldArr, _fillType, [_objectMode, _allowDamage, _detail]] call PFUNC(interiorFill_start);
