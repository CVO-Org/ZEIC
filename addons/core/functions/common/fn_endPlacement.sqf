#include "..\..\script_component.hpp"

/*
* Ends the placement mode after a ZEIC module was placed: clears the selection of the create lists,
* so the next click doesn't place the module again (as ZEN does in Zeus).
* - Zeus: the unit, group, module and recent lists (IDC 270-282).
* - Eden: the asset browser lists (tree controls whose class name starts with "Create").
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

private _trees = if (is3DEN) then {
	(allControls findDisplay 313) select { ctrlType _x == 12 && {(ctrlClassName _x find "Create") == 0} }
} else {
	private _display = findDisplay 312;
	if (isNull _display) then { [] } else {
		([270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 282] apply { _display displayCtrl _x }) select { !isNull _x }
	}
};

// DEBUG #54 (temporary): reduced version, clear once right away
private _dbgSel = (_trees select { (tvCurSel _x) isNotEqualTo [] }) apply { [ctrlClassName _x, ctrlIDC _x, tvCurSel _x] };
diag_log text format ["[ZEIC ENDPL] once frame %1 eden %2 trees %3 selected %4", diag_frameNo, is3DEN, count _trees, _dbgSel];

{
	if ((tvCurSel _x) isNotEqualTo []) then { _x tvSetCurSel [-1] };
} forEach _trees;
