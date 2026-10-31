#include "..\..\script_component.hpp"

// Furnishes one building immediately (synchronous). Interior Fill itself goes through the processing queue (PFUNC(interiorFill_start)).
params [
		["_bld", objNull],
		["_fillType", "mil"],
		["_fillArea", false],
		["_addZeus", true],
		["_allowDamage", false],
		["_detail", 1]
	];

[format ["Passed - B: %1 T: %2 A: %3 Z: %4 D: %5 M: %6", _bld, _fillType, _fillArea, _addZeus, _allowDamage, _detail], "DEBUG"] call PFUNC(misc_logMsg);

// Skip previously processed houses
if (isNull _bld || !isNull (_bld getVariable [QPVAR(furnished), objNull])) exitWith {};

private _items = [_bld, _fillType, _fillArea] call PFUNC(interiorFill_selectTemplate);
if (_items isEqualTo []) exitWith {};

private _layer = [_bld, _allowDamage] call PFUNC(interiorFill_prepareBuilding);
private _objects = [];

{
	private _obj = [_bld, _x, _addZeus, _detail, _layer] call PFUNC(interiorFill_spawnObject);
	if (!isNull _obj) then { _objects pushBack _obj };
} forEach _items;

[_bld, _objects, _addZeus] call PFUNC(interiorFill_finishBuilding);
