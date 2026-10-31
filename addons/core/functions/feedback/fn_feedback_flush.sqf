#include "..\..\script_component.hpp"

/*
* Sends all progress states collected this frame in one message. Called by PFUNC(queue_onFrame).
*
* Public: No
*/

if (missionNamespace getVariable [QPVAR(feedbackPending), []] isEqualTo []) exitWith {};

[QPFUNC(feedback_update), [PVAR(feedbackPending)]] call PFUNC(feedback_send);
PVAR(feedbackPending) = [];
