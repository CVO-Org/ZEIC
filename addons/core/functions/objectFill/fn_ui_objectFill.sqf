#include "..\..\script_component.hpp"

/*
* Fills a table, shelf or similar object with small props (called by the Object Fill dialog or the Alt shortcut).
* Props and shelves come from CfgZEIC_ObjectFill (see docs/config-schema.md, section 12).
*
* Arguments:
* 0: Type class (e.g. "food"), "" for random; the old numbers 0-6 still work <STRING or NUMBER>
* 1: Fill percent <NUMBER>
* 2: Object mode (OBJECT_MODE_*), or the old "add to Zeus" <NUMBER or BOOL> (default: simple objects)
*
* Return Value:
* None
*
* Public: No
*/

params [["_type", "", ["", 0]], ["_pc", 30, [0]], ["_objectMode", OBJECT_MODE_SIMPLE, [0, true]]];

// Old calls passed the position in the old type list, and "add to Zeus" (true/false)
if (_type isEqualType 0) then { _type = ["", "food", "medical", "office", "tools", "electric", "cbrn"] param [_type, ""] };
if (_objectMode isEqualType true) then { _objectMode = [OBJECT_MODE_SIMPLE, OBJECT_MODE_EDITABLE] select _objectMode };

// Remembered for the dialog and the Alt shortcut
PVAR(UiObjectFillType) = _type;
PVAR(UiObjectFillPercent) = _pc;
PVAR(UiObjectFillObjects) = _objectMode;

private _object = missionNamespace getVariable [QPVAR(UiLastObject), objNull];

if (isNull _object) exitWith { [LLSTRING(MSG_NoObject), "ERROR"] call PFUNC(misc_logMsg) };

// The props of the type, of all types for random; the floor object goes under tables
private _cfgTypes = configFile >> "CfgZEIC_ObjectFill" >> "Types";
private _itemArray = [];
private _itemFloor = "Land_Garbage_square3_F";
if (_type != "" && {isClass (_cfgTypes >> _type)}) then {
	_itemArray = getArray (_cfgTypes >> _type >> "objects");
	_itemFloor = getText (_cfgTypes >> _type >> "floor");
} else {
	{ _itemArray append getArray (_x >> "objects") } forEach ("true" configClasses _cfgTypes);
};
_itemArray = _itemArray select { isClass (configFile >> "CfgVehicles" >> _x) };
if (_itemArray isEqualTo []) exitWith {};

// Spawns an item to its parent at the requested offset
private _fnc_attachItem = {
	params ["_parent","_item","_itemToPos",["_forceDir",random 360]];
	
	// Get rotation for Eden / Zeus
	([_parent] call PFUNC(misc_Vector2Eden)) params ["_xRot", "_yRot", "_zRot"];
	
	// Get world position
	private _itemPos = _parent modelToWorld _itemToPos;
	
	// Spawn items depending on Zeus/Eden
	if (is3DEN) then {
		private _obj = create3DENEntity ["Object", _item, [0,0,0], true];

		if (surfaceIsWater _itemPos) then { 
			_obj set3DENAttribute ["position", ASLToATL _itemPos];
		} else {
			_obj set3DENAttribute ["position", _itemPos];
		};
		
		_obj set3DENAttribute ["rotation", [ _xRot, _yRot, _zRot + _forceDir]];
		_obj set3DENAttribute ["enableSimulation", false];
		_obj set3DENAttribute ["objectIsSimple", true];
	} else {	
		private _obj = objNull;
		
		if (_objectMode == OBJECT_MODE_SIMPLE) then {
			_obj = createSimpleObject [_item, [0,0,0]];
		} else {
			_obj = createVehicle [_item, [0,0,0], [], 0, "CAN_COLLIDE"];
			[_obj, false] remoteExec ["enableSimulationGlobal", 2];
		};
		
		_obj setPosATL _itemPos;
		_obj setVectorDirAndUp [vectorDir _parent, vectorUp _parent];
		[_obj, _forceDir] call PFUNC(misc_rotateAroundOwnAxisZ);
		
		if (_objectMode == OBJECT_MODE_EDITABLE) then {
			{ [_x, [ [_obj], true]] remoteExec ["addCuratorEditableObjects",2] } forEach allCurators;
		};
	};
};

// The shelves of the object: indent from the bounding box and the heights below its top
private _cfgSurface = configFile >> "CfgZEIC_ObjectFill" >> "Surfaces" >> typeOf _object;
private _fromEdge = [[0.1, 0.05, 0.1, 0.05], getArray (_cfgSurface >> "edge")] select (isArray (_cfgSurface >> "edge"));
private _levels = getArray (_cfgSurface >> "levels");
// About the old spacing (0.2 m plus up to 0.1 m at random)
private _itemSpacing = [0.25, 0.25];
private _objBB = boundingBoxReal _object;

// Not listed: fill the top of the model
if (_levels isEqualTo []) then {
	_objBB = 0 boundingBoxReal _object;
	_levels = [0];
	[format [LLSTRING(MSG_OFUnknown), typeOf _object], "WARNING"] call PFUNC(misc_logMsg);
};

private _fnc_fill = {
	// One level: a table, something goes on the floor below it
	if (count _levels == 1 && {_itemFloor != ""}) then {
		[_object, _itemFloor, [0, 0, (_objBB select 0) select 2], getDir _object] call _fnc_attachItem;
	};

	{
		private _height = ((_objBB select 1) select 2) + _x;
		for "_i" from ((_objBB select 0) select 0) + (_fromEdge select 0) to ((_objBB select 1) select 0) - (_fromEdge select 1) step (_itemSpacing select 0) do {
			for "_j" from ((_objBB select 0) select 1) + (_fromEdge select 2) to ((_objBB select 1) select 1) - (_fromEdge select 3) step (_itemSpacing select 1) do {
				if (random 100 < _pc) then {
					[_object, selectRandom _itemArray, [_i + random 0.05, _j + random 0.05, _height]] call _fnc_attachItem;
				};
			};
		};
	} forEach _levels;
};

if (is3DEN) then {
	collect3DENHistory {
		call _fnc_fill;
		_object set3DENAttribute ["enableSimulation", false];
	};
} else {
	call _fnc_fill;
};
