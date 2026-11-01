#include "..\..\script_component.hpp"

/*
* Self test: the Object Fill, Object Switch and List Buildings dialogs.
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

private _fnc_waitClosed = {
	params ["_idd"];
	private _timeout = diag_tickTime + 1;
	waitUntil { isNull findDisplay _idd || {diag_tickTime > _timeout} };
	isNull findDisplay _idd
};

// T16 Object Fill dialog (#26)
private _table = ["Land_TablePlastic_01_F", 42] call PFUNC(dev_spawn);
PVAR(UiLastObject) = _table;
PVAR(UiObjectFillType) = 1;
PVAR(UiObjectFillPercent) = 100;
PVAR(UiObjectFillObjects) = OBJECT_MODE_SIMPLE;
createDialog "Rsc_ZEIC_ObjectFill";
private _dlg = findDisplay 1704;
["T16.1 Object Fill dialog opens", !isNull _dlg] call PFUNC(dev_check);
if (!isNull _dlg) then {
	["T16.2 seven types, last one preselected", lbSize (_dlg getVariable ["type_ctrl", controlNull]) == 7 && {(_dlg getVariable ["type", -1]) == 1}] call PFUNC(dev_check);
	["T16.3 object modes shown outside Eden", !isNull (_dlg getVariable ["objects_ctrl", controlNull])] call PFUNC(dev_check);

	private _simpleBefore = count allSimpleObjects [];
	[_dlg] call PFUNC(ui_dialogConfirm);
	private _closed = [1704] call _fnc_waitClosed;
	private _spawned = (count allSimpleObjects []) - _simpleBefore;
	["T16.4 confirm closes and fills the table with simple objects", _closed && {_spawned > 0}, [_closed, _spawned]] call PFUNC(dev_check);
};

// T17 Object Switch dialog (#26)
private _fence = ["Land_BagFence_Long_F", 43] call PFUNC(dev_spawn);
PVAR(UiLastPosition) = getPosATL _fence;
PVAR(UiSwitchCombo) = "jungle";
PVAR(UiSwitchRadius) = 5;
createDialog "Rsc_ZEIC_ObjectSwitch";
_dlg = findDisplay 1701;
["T17.1 Object Switch dialog opens", !isNull _dlg] call PFUNC(dev_check);
if (!isNull _dlg) then {
	private _expected = 3 + ([0, 2] select isClass (configFile >> "CfgPatches" >> "ZEIC_templates_cup")) + ([0, 2] select isClass (configFile >> "CfgPatches" >> "ZEIC_templates_sog"));
	private _combo = _dlg getVariable ["set_ctrl", controlNull];
	["T17.2 only sets of loaded mods listed", lbSize _combo == _expected, [lbSize _combo, _expected]] call PFUNC(dev_check);
	["T17.3 last set preselected", (_dlg getVariable QPVAR(sets)) select (_dlg getVariable ["set", 0]) == "jungle"] call PFUNC(dev_check);

	[_dlg] call PFUNC(ui_dialogConfirm);
	private _closed = [1701] call _fnc_waitClosed;
	sleep 0.1;
	private _switched = nearestObjects [PVAR(UiLastPosition), ["Land_BagFence_01_long_green_F"], 5];
	["T17.4 confirm switches at the module's position, not the mouse", _closed && {isNull _fence} && {_switched isNotEqualTo []}, [_closed, isNull _fence, count _switched]] call PFUNC(dev_check);
};

// T18 List Buildings dialog (#26): only the dialog, listing all buildings takes long
PVAR(UiListCategory) = 0;
createDialog "Rsc_ZEIC_ListBuildings";
_dlg = findDisplay 1703;
["T18.1 List Buildings dialog opens", !isNull _dlg] call PFUNC(dev_check);
if (!isNull _dlg) then {
	private _combo = _dlg getVariable ["category_ctrl", controlNull];
	private _categoryCount = count (call PFUNC(interiorFill_categories));
	["T18.2 All plus one entry per config category", lbSize _combo == _categoryCount + 1, [lbSize _combo, _categoryCount]] call PFUNC(dev_check);
	["T18.3 category classes behind the entries", (_dlg getVariable QPVAR(categories)) isEqualTo ([""] + ((call PFUNC(interiorFill_categories)) apply { _x select 1 }))] call PFUNC(dev_check);
	_dlg closeDisplay 2;
};
