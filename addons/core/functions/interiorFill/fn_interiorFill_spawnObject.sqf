#include "..\..\script_component.hpp"

/*
* Spawns one object of a template relative to its building.
*
* Arguments:
* 0: Building <OBJECT>
* 1: Object entry ["Class", [x, y, z], direction, [rotX, rotY, rotZ]] <ARRAY>
* 2: Editable in Zeus (normal object instead of a simple object) <BOOL>
* 3: Detail level <NUMBER>
* 4: Eden layer ID <NUMBER>
*
* Return Value:
* Spawned object, objNull if nothing was spawned <OBJECT>
*
* Public: No
*/

params [["_bld", objNull, [objNull]], ["_entry", [], [[]]], ["_addZeus", true, [true]], ["_detail", 1, [0]], ["_layer", -1, [0]]];
_entry params ["_item", "_offset", ["_angle", 0], ["_rot", [0, 0, 0]]];

_item = [_item] call PFUNC(randomiseObject);
if (_item == "" || {!([_item, _detail] call PFUNC(checkDetailLevel))}) exitWith { objNull };

private _obj = objNull;

if (is3DEN) then {
	_obj = create3DENEntity ["Object", _item, [0,0,0], true];
	_obj set3DENAttribute ["objectIsSimple", true];
	_obj set3DENLayer _layer;
} else {
	if (_addZeus) then {
		_obj = createVehicle [_item, (_bld modelToWorld _offset), [], 0, "CAN_COLLIDE"];
		if (isServer) then { _obj enableSimulationGlobal false } else { [_obj, false] remoteExec ["enableSimulationGlobal", 2] };
	} else {
		_obj = createSimpleObject [_item, AGLToASL (_bld modelToWorld _offset)];
	};
};

_obj setVectorDirAndUp [vectorDir _bld, vectorUp _bld];

if (_rot isNotEqualTo [0,0,0]) then {
	// Apply further rotation to object.
	[_obj, (_rot select 0)*-1] call PFUNC(misc_rotateAroundOwnAxisX);
	[_obj, (_rot select 1)*-1] call PFUNC(misc_rotateAroundOwnAxisY);
	[_obj, (_rot select 2)*-1] call PFUNC(misc_rotateAroundOwnAxisZ);
} else {
	[_obj, _angle*-1] call PFUNC(misc_rotateAroundOwnAxisZ);
};

if (is3DEN) then {
	_obj set3DENAttribute ["rotation", [_obj] call PFUNC(misc_Vector2Eden)];

	private _pos = (_bld modelToWorld _offset);

	if (surfaceIsWater _pos) then {
		_obj set3DENAttribute ["position", ASLToATL _pos];
	} else {
		_obj set3DENAttribute ["position", _pos];
	};
};

_obj
