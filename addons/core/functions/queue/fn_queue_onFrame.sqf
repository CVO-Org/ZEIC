#include "..\..\script_component.hpp"

/*
* EachFrame handler of the processing queue. Runs job steps until the time budget for this frame is used up,
* then sends the collected progress feedback. Removes itself once the queue is empty.
*
* Budget: ZEIC_queueBudget (seconds) if set, otherwise 1.5 ms on clients and 0.5 ms on a dedicated server.
* In Eden, everything a frame creates is one undo step (collect3DENHistory can't span frames).
*
* Arguments:
* 0: Event handler ID <NUMBER>
*
* Public: No
*/

params ["_handle"];

PVAR(queueFrame) = diag_frameNo;

private _budget = missionNamespace getVariable [QPVAR(queueBudget), [QUEUE_BUDGET_CLIENT, QUEUE_BUDGET_SERVER] select isDedicated];
private _end = diag_tickTime + _budget;

// At least one step per frame, however small the budget.
// A job that waits for another one (it sets "waiting", see PFUNC(advancedFill_waitForInterior)) lets the jobs behind it run,
// and waiting doesn't count as the frame's step.
private _runSteps = {
	private _index = 0;
	while { _index < count PVAR(queue) } do {
		private _job = PVAR(queue) select _index;
		_job set ["waiting", false];
		private _waiting = false;
		if ([_job] call (_job get "step")) then {
			PVAR(queue) deleteAt _index;
		} else {
			_waiting = _job get "waiting";
			if (_waiting) then { _index = _index + 1 };
		};
		if (!_waiting && {diag_tickTime >= _end}) exitWith {};
	};
};

if (is3DEN) then { collect3DENHistory _runSteps } else { call _runSteps };

call PFUNC(feedback_flush);

if (PVAR(queue) isEqualTo []) then {
	removeMissionEventHandler ["EachFrame", _handle];
	PVAR(queueEH) = nil;
};
