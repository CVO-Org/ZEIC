#include "..\..\script_component.hpp"

/*
* Records a progress state for a building. Runs where the work happens (server, or locally in Eden / singleplayer).
* States are collected and sent once per frame by PFUNC(feedback_flush).
*
* Arguments:
* 0: Building <OBJECT>
* 1: State <NUMBER> - FEEDBACK_QUEUED, FEEDBACK_PROCESSING, FEEDBACK_DONE or FEEDBACK_NONE
*
* Return Value:
* None
*
* Public: No
*/

params [["_bld", objNull, [objNull]], ["_state", FEEDBACK_QUEUED, [0]]];

if (isNil QPVAR(feedbackPending)) then { PVAR(feedbackPending) = [] };
PVAR(feedbackPending) pushBack [_bld, _state];
