#include "..\..\script_component.hpp"

/*
* Ends the placement mode in Zeus after a ZEIC module was placed: clears the selection in the module
* and "recent" lists, so the next click doesn't place the module again (as ZEN does). Does nothing in Eden.
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

private _display = findDisplay 312;
if (isNull _display) exitWith {};

{
	private _tree = _display displayCtrl _x;
	if (!isNull _tree && {(tvCurSel _tree) isNotEqualTo []}) then { _tree tvSetCurSel [-1] };
} forEach [280, 282]; // modules, recent
