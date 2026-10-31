#include "..\..\script_component.hpp"

/*
* Finishes a furnished building: marks it as furnished and, for OBJECT_MODE_EDITABLE, makes its objects editable
* for all curators (in one call).
*
* Arguments:
* 0: Building <OBJECT>
* 1: Spawned objects <ARRAY>
* 2: Object mode <NUMBER>
*
* Return Value:
* None
*
* Public: No
*/

params [["_bld", objNull, [objNull]], ["_objects", [], [[]]], ["_objectMode", OBJECT_MODE_SIMPLE, [0]]];

_bld setVariable [QPVAR(queued), nil];

if (_objects isEqualTo []) exitWith {};

_bld setVariable [QPVAR(furnished), _objects select -1];

if (is3DEN || {_objectMode != OBJECT_MODE_EDITABLE}) exitWith {};

if (isServer) then {
	{ _x addCuratorEditableObjects [_objects, true] } forEach allCurators;
} else {
	{ [_x, [_objects, true]] remoteExec ["addCuratorEditableObjects", 2] } forEach allCurators;
};
