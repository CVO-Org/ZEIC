#include "..\..\script_component.hpp"

/*
* Called by a garrison job before it starts its next building: with a link id (Advanced Fill), the building is
* garrisoned only once its interior is done (see PFUNC(advancedFill_interiorDone)). While it waits, the job is
* marked as "waiting", so the queue runs the jobs behind it (in Eden and singleplayer, the interior job itself).
* Failsafe: after ADVANCED_FILL_WAIT seconds for one building it goes on without the interior.
*
* Arguments:
* 0: Garrison job <HASHMAP> - see PFUNC(garrisonBuilding_start)
* 1: Next building <OBJECT>
*
* Return Value:
* Wait <BOOL>
*
* Public: No
*/

params ["_job", "_bld"];

private _linkId = _job getOrDefault ["linkId", ""];
if (_linkId == "" || {isNull _bld}) exitWith { false };

private _done = (missionNamespace getVariable [QPVAR(interiorDone), createHashMap]) getOrDefault [_linkId, []];
if (_bld in _done) exitWith {
	_job set ["waitSince", -1];
	false
};

if ((_job get "waitSince") < 0) then { _job set ["waitSince", diag_tickTime] };
if (diag_tickTime - (_job get "waitSince") > ADVANCED_FILL_WAIT) exitWith {
	[format [LLSTRING(ModuleAdvancedFill_NoInterior), typeOf _bld, ADVANCED_FILL_WAIT], "WARNING"] call PFUNC(misc_logMsg);
	_job set ["waitSince", -1];
	false
};

_job set ["waiting", true];
true
