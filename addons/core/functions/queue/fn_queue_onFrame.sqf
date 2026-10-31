#include "..\..\script_component.hpp"

/*
* EachFrame handler of the processing queue. Runs job steps until the time budget for this frame is used up,
* then sends the collected progress feedback. Removes itself once the queue is empty.
*
* Budget: ZEIC_queueBudget (seconds) if set, otherwise 1.5 ms on clients and 0.5 ms on a dedicated server.
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
while { PVAR(queue) isNotEqualTo [] } do {
	private _job = PVAR(queue) select 0;
	if ([_job] call (_job get "step")) then { PVAR(queue) deleteAt 0 };
	if (diag_tickTime >= _end) exitWith {};
};

call PFUNC(feedback_flush);

if (PVAR(queue) isEqualTo []) then {
	removeMissionEventHandler ["EachFrame", _handle];
	PVAR(queueEH) = nil;
};
