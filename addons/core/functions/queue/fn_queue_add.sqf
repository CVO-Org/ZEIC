#include "..\..\script_component.hpp"

/*
* Adds a job to the local processing queue and makes sure the queue is running.
* Jobs are processed in order, one step at a time, within a time budget per frame (see PFUNC(queue_onFrame)).
*
* Arguments:
* 0: Job <HASHMAP> - must contain "step": code called with [job], returns true once the job is finished
*
* Return Value:
* None
*
* Public: No
*/

params [["_job", createHashMap, [createHashMap]]];

if (isNil QPVAR(queue)) then { PVAR(queue) = [] };
PVAR(queue) pushBack _job;

// Driven by a vanilla EachFrame handler: CBA per-frame handlers don't run in Eden.
// The handler can get lost when Eden resets its mission namespace (preview, terrain change), so re-add it if it stopped ticking.
private _lastFrame = missionNamespace getVariable [QPVAR(queueFrame), -10];
if (isNil QPVAR(queueEH) || {diag_frameNo - _lastFrame > 5}) then {
	PVAR(queueFrame) = diag_frameNo;
	PVAR(queueEH) = addMissionEventHandler ["EachFrame", { [_thisEventHandler] call PFUNC(queue_onFrame) }];
};
