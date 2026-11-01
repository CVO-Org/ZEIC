#include "..\..\script_component.hpp"

/*
* Ends the placement mode after a ZEIC module was placed: clears the selection of the create lists,
* so the next click doesn't place the module again (as ZEN does in Zeus).
* - Zeus: the unit, group, module and recent lists (IDC 270-282).
* - Eden: the asset browser lists (tree controls whose class name starts with "Create").
* The editor may still be finishing the placement when the module runs, so it is done again on the next frames.
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

private _trees = if (is3DEN) then {
	(allControls findDisplay 313) select { ctrlType _x == 12 && {(ctrlClassName _x find "Create") == 0} }
} else {
	private _display = findDisplay 312;
	if (isNull _display) then { [] } else {
		([270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 282] apply { _display displayCtrl _x }) select { !isNull _x }
	}
};

#if _ZEIC_DEV_
if (_frames == 3) then {
	diag_log text format ["[ZEIC DEV] endPlacement: %1 lists %2, all trees: %3", count _trees, _trees apply { [ctrlClassName _x, tvCurSel _x] },
		(allControls (findDisplay ([312, 313] select is3DEN))) select { ctrlType _x == 12 } apply { [ctrlIDC _x, ctrlClassName _x, tvCurSel _x] }];
};
#endif

{
	if ((tvCurSel _x) isNotEqualTo []) then { _x tvSetCurSel [-1] };
} forEach _trees;

if (_frames > 0 && {_trees isNotEqualTo []}) then {
	addMissionEventHandler ["EachFrame", {
		removeMissionEventHandler [_thisEvent, _thisEventHandler];
		[_thisArgs select 0] call PFUNC(zeus_endPlacement);
	}, [_frames - 1]];
};
