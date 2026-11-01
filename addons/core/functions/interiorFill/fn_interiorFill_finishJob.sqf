#include "..\..\script_component.hpp"

/*
* Finishes an Interior Fill job: one summary message for the requesting client, the list of buildings
* without a template in the RPT, and the progress wireframes are cleared a few seconds later.
*
* Arguments:
* 0: Job <HASHMAP> - see PFUNC(interiorFill_enqueue)
*
* Return Value:
* None
*
* Public: No
*/

params ["_job"];

private _missing = _job get "missing";
// Translated on the receiving client (see PFUNC(misc_logMsg))
private _summary = [
	[LSTRING(MSG_FillDone), LSTRING(MSG_FillDoneMissing)] select (_missing isNotEqualTo []),
	toUpper (_job get "category"), _job get "furnished", count _missing
];

if (_missing isNotEqualTo []) then {

	private _unique = _missing arrayIntersect _missing;
	diag_log text format ["[ZEI][INFO] Interior Fill (%1): no template for %2 building class(es): %3",
		toUpper (_job get "category"),
		count _unique,
		(_unique apply { private _class = _x; format ["%1 (%2x)", _class, { _x == _class } count _missing] }) joinString ", "
	];
};

[_summary, _job get "requester"] call PFUNC(interiorFill_notify);

// Make sure the last states arrive before the clear is scheduled.
call PFUNC(feedback_flush);
[QPFUNC(feedback_finish), []] call PFUNC(feedback_send);
