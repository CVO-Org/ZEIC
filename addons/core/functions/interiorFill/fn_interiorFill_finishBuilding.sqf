#include "..\..\script_component.hpp"

/*
* Finishes a furnished building: marks it as furnished and makes its objects editable for all curators (in one call).
*
* Arguments:
* 0: Building <OBJECT>
* 1: Spawned objects <ARRAY>
* 2: Editable in Zeus <BOOL>
*
* Return Value:
* None
*
* Public: No
*/

params [["_bld", objNull, [objNull]], ["_objects", [], [[]]], ["_addZeus", true, [true]]];

_bld setVariable [QPVAR(queued), nil];

if (_objects isEqualTo []) exitWith {};

_bld setVariable [QPVAR(furnished), _objects select -1];

if (is3DEN || {!_addZeus}) exitWith {};

if (isServer) then {
	{ _x addCuratorEditableObjects [_objects, true] } forEach allCurators;
} else {
	{ [_x, [_objects, true]] remoteExec ["addCuratorEditableObjects", 2] } forEach allCurators;
};
