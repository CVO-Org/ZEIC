#include "..\..\script_component.hpp"

/*
* Finishes a Garrison job: one summary message, and the progress wireframes are cleared a few seconds later.
*
* Arguments:
* 0: Job <HASHMAP> - see PFUNC(garrisonBuilding_start)
*
* Return Value:
* None
*
* Public: No
*/

params ["_job"];

[format [LLSTRING(MSG_GarrisonDone), _job get "faction", _job get "unitCount", _job get "buildingCount"], "INFO"] call PFUNC(misc_logMsg);

// Make sure the last states arrive before the clear is scheduled.
call PFUNC(feedback_flush);
[QPFUNC(feedback_finish), []] call PFUNC(feedback_send);
