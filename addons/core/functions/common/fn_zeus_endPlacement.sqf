#include "..\..\script_component.hpp"

/*
* Ends the placement mode in Zeus after a ZEIC module was placed: clears the selection of the create
* lists, so the next click doesn't place the module again (as ZEN does). Does nothing in Eden.
* Zeus may still be finishing the placement when the module runs, so it is done again on the next frames.
*
* Arguments:
* 0: Frames to repeat it (internal) <NUMBER> (default: 3)
*
* Return Value:
* None
*
* Public: No
*/

params [["_frames", 3, [0]]];

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// 270-279 unit and group lists per side, 280 modules, 282 recent
for "_idc" from 270 to 282 do {
	private _tree = _display displayCtrl _idc;
	if (!isNull _tree && {(tvCurSel _tree) isNotEqualTo []}) then { _tree tvSetCurSel [-1] };
};

if (_frames > 0) then {
	addMissionEventHandler ["EachFrame", {
		removeMissionEventHandler [_thisEvent, _thisEventHandler];
		[_thisArgs select 0] call PFUNC(zeus_endPlacement);
	}, [_frames - 1]];
};
