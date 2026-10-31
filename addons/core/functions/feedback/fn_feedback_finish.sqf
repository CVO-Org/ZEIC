#include "..\..\script_component.hpp"

/*
* Clears all wireframe boxes a few seconds after a fill has finished, unless another fill updated them in the meantime.
* Runs on the machines that show progress (see PFUNC(feedback_send)).
*
* Public: No
*/

private _generation = missionNamespace getVariable [QPVAR(feedbackGeneration), 0];

[_generation] spawn {
	params ["_generation"];
	uiSleep FEEDBACK_LINGER;

	if (_generation != missionNamespace getVariable [QPVAR(feedbackGeneration), 0]) exitWith {};

	{ (_x select 0) setVariable [QPVAR(feedbackIndex), nil] } forEach (missionNamespace getVariable [QPVAR(feedback), []]);
	PVAR(feedback) = [];

	if (!isNil QPVAR(feedbackEH)) then {
		removeMissionEventHandler ["EachFrame", PVAR(feedbackEH)];
		PVAR(feedbackEH) = nil;
	};
};
