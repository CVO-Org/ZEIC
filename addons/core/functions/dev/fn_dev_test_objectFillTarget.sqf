#include "..\..\script_component.hpp"

/*
* Self test: the target the Object Fill module picks (#66).
* Part of PFUNC(dev_selfTest), needs its scheduled environment.
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

private _fnc_place = {
	params ["_pos"];
	private _logic = (createGroup sideLogic) createUnit ["Logic", _pos, [], 0, "CAN_COLLIDE"];
	_logic setPosATL _pos;
	["init", [_logic, true, true]] call PFUNC(mod_objectFill);
	sleep 0.2;
	findDisplay 1704
};

// T28.1 nothing around: no dialog, the target of an earlier placement is gone
private _old = ["Land_TablePlastic_01_F", 45] call PFUNC(dev_spawn);
PVAR(UiLastObject) = _old;
private _empty = PVAR(dev_origin) vectorAdd [150 * (46 mod 8), 150 * floor (46 / 8), 0];
private _dlg = [_empty] call _fnc_place;
["T28.1 nothing around: no dialog, no stale target", isNull _dlg && {isNull PVAR(UiLastObject)}, [isNull _dlg, PVAR(UiLastObject)]] call PFUNC(dev_check);
if (!isNull _dlg) then { _dlg closeDisplay 2 };

// T28.2 dialog opened without a target closes itself
PVAR(UiLastObject) = objNull;
createDialog "Rsc_ZEIC_ObjectFill";
sleep 0.2;
["T28.2 dialog without a target closes", isNull findDisplay 1704] call PFUNC(dev_check);

// T28.3 next to a table: dialog with its name in the title
_dlg = [getPosATL _old vectorAdd [1, 0, 0]] call _fnc_place;
private _title = (allControls _dlg) findIf { ctrlClassName _x == QPVAR(ctrlTitle) };
_title = if (_title < 0) then { "" } else { ctrlText ((allControls _dlg) select _title) };
private _name = getText (configOf _old >> "displayName");
["T28.3 next to a table: dialog shows its name", !isNull _dlg && {PVAR(UiLastObject) isEqualTo _old} && {_name != ""} && {(_title find _name) >= 0}, [_title, _name]] call PFUNC(dev_check);
if (!isNull _dlg) then { _dlg closeDisplay 2 };
