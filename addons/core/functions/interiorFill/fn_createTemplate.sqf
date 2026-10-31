#include "..\..\script_component.hpp"

// Furnishes one building immediately (synchronous). Interior Fill itself goes through the processing queue (PFUNC(interiorFill_start)).
params [
		["_bld", objNull],
		["_fillType", "mil"],
		["_fillArea", false],
		["_objectMode", OBJECT_MODE_EDITABLE],	// object mode, or true/false (editable / simple objects)
		["_allowDamage", false]
		// A 6th parameter (detail level) is ignored, the option was removed
	];

[format ["Passed - B: %1 T: %2 A: %3 Z: %4 D: %5", _bld, _fillType, _fillArea, _objectMode, _allowDamage], "DEBUG"] call PFUNC(misc_logMsg);

if (_objectMode isEqualType true) then { _objectMode = [OBJECT_MODE_SIMPLE, OBJECT_MODE_EDITABLE] select _objectMode };

// Skip previously processed houses
if (isNull _bld || !isNull (_bld getVariable [QPVAR(furnished), objNull])) exitWith {};

private _items = [_bld, _fillType, _fillArea] call PFUNC(interiorFill_selectTemplate);
if (_items isEqualTo []) exitWith {};

private _layer = [_bld, _allowDamage] call PFUNC(interiorFill_prepareBuilding);
private _objects = [];

{
	private _obj = [_bld, _x, _objectMode, _layer] call PFUNC(interiorFill_spawnObject);
	if (!isNull _obj) then { _objects pushBack _obj };
} forEach _items;

[_bld, _objects, _objectMode] call PFUNC(interiorFill_finishBuilding);
