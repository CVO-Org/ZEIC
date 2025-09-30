#include "../script_component.hpp"

params [
		["_type", 0],
		["_area", 0],
		["_addZeus", true],
		["_allowDamage", false],
		["_detail", 1]
	];

diag_log _type;

private _fillType = PVAR(interiorFillCategories) select _type select 1;
private _fillArea = _area isNotEqualTo 0;

// Save UI Settings for next time
PVAR(UiInteriorType) = _type;
PVAR(UiInteriorDetail) = _detail;
PVAR(UiInteriorEdit) = _addZeus;
PVAR(UiInteriorDamage) = _allowDamage;

private _bldTmp = missionNamespace getVariable [QPVAR(UiLastBuilding), objNull];
private _bldArr = [];

if (isNull _bldTmp || _fillArea) then { 
	_bldTmp = nearestObjects [screenToWorld getMousePosition, ["Building"], [_area, 15] select (_area isEqualTo 0), true]; 
	_bldArr = _bldTmp select { ((_x buildingPos 0) isNotEqualTo [0,0,0]) || typeOf _x in (missionNamespace getVariable [QPVAR(additionalBuildings), []]) };
	
	if !(_fillArea) then { _bldArr resize 1 };
} else {
	_bldArr = [_bldTmp];
};

_bldArr = _bldArr - [objNull];

// Don't continue if no objects were found.
if (_bldArr isEqualTo []) exitWith {
	["No valid objects within 25m", "INFO"] call PFUNC(misc_logMsg);
};

if (is3DEN) then {
	collect3DENHistory {
		{
			[_x, _fillType, _fillArea, _addZeus, _allowDamage, _detail] call PFUNC(createTemplate);
		} forEach _bldArr;
	};
} else {
	{
		[_x, _fillType, _fillArea, _addZeus, _allowDamage, _detail] call PFUNC(createTemplate);
	} forEach _bldArr;
};
