#include "..\..\script_component.hpp"

/*
* Creates the "Move AI" trigger of a garrisoned building, on the server only (Zeus; Eden creates its own in
* PFUNC(garrisonBuilding_finishBuilding)). See PFUNC(garrisonBuilding_triggerStatements) for what it does.
* The interval is randomized a little, so the triggers of a garrison don't all check in the same frame.
*
* Arguments:
* 0: Center <ARRAY>
* 1: Radius <NUMBER>
* 2: Group of the building <GROUP>
*
* Return Value:
* Trigger <OBJECT>
*
* Public: No
*/

params [["_pos", [0, 0, 0], [[]]], ["_radius", 40, [0]], ["_group", grpNull, [grpNull]]];

if (!isServer) exitWith { _this remoteExecCall [QPFUNC(garrisonBuilding_createTrigger), 2]; objNull };

private _trg = createTrigger ["EmptyDetector", _pos, false];
_trg setTriggerArea [_radius, _radius, 0, false, 15];
_trg setTriggerActivation ["ANYPLAYER", "PRESENT", true];
_trg setTriggerInterval (4 + random 2);
_trg setVariable ["ZEIC_group", _group];
_trg setTriggerStatements ([] call PFUNC(garrisonBuilding_triggerStatements));
_trg
