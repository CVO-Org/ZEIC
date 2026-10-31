#include "..\..\script_component.hpp"

/*
* Calls a feedback function on every machine that shows progress: locally in Eden and singleplayer,
* otherwise on the clients of all assigned curators (each client only draws while in the Zeus camera).
*
* Arguments:
* 0: Function name <STRING>
* 1: Arguments <ARRAY>
*
* Return Value:
* None
*
* Public: No
*/

params [["_fnc", "", [""]], ["_args", [], [[]]]];

if (is3DEN || {!isMultiplayer}) exitWith { _args call (missionNamespace getVariable _fnc) };

private _owners = (allCurators apply { getAssignedCuratorUnit _x }) select { !isNull _x } apply { owner _x };
_owners = _owners arrayIntersect _owners;

if (_owners isNotEqualTo []) then { _args remoteExecCall [_fnc, _owners] };
