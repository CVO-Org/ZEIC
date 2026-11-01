#include "..\..\script_component.hpp"

/*
* Self test: Advanced Fill (#55, phase 1): the dialog's tabs and enable logic (never both parts off),
* interior only, garrison only, both (per building the interior before the units) and the Alt shortcut.
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

// T24 Advanced Fill (#55)
private _fnc_waitQueue = {
	private _timeout = diag_tickTime + 60;
	waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };
	(missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo []
};
private _fnc_units = { params ["_bld"]; (_bld nearEntities ["CAManBase", 30]) select { !isPlayer _x } };
private _fnc_furnished = { params ["_bld"]; !isNull (_bld getVariable [QPVAR(furnished), objNull]) };
private _garrisonOnly = createHashMapFromArray [["interior", false], ["garrison", true], ["pair", ["BLU_F", "EdSubcat_Personnel"]], ["positions", 50], ["radius", 0]];

private _module = configFile >> "CfgVehicles" >> QPVAR(AdvancedFill);
["T24.1 module, icon and dialog exist", isClass _module && {fileExists getText (_module >> "icon")} && {isClass (configFile >> "Rsc_ZEIC_AdvancedFill")}, getText (_module >> "icon")] call PFUNC(dev_check);

// ---- dialog: tabs and enable logic
private _bld = [DEV_HOUSE, 50] call PFUNC(dev_spawn);
PVAR(UiLastBuilding) = _bld;
PVAR(UiAdvancedFill) = nil;
createDialog "Rsc_ZEIC_AdvancedFill";
private _dlg = findDisplay 1706;
["T24.2 dialog opens with both parts on, on the Interior tab", !isNull _dlg && {_dlg getVariable ["interior", false]} && {_dlg getVariable ["garrison", false]} && {(_dlg getVariable ["tab", -1]) == 0}] call PFUNC(dev_check);
if (isNull _dlg) exitWith {};

private _fnc_set = { params ["_part", "_on"]; [_dlg, _part, _on] call (_dlg getVariable QPVAR(setPart)); [_dlg getVariable "interior", _dlg getVariable "garrison"] };
private _fnc_checked = { [cbChecked (_dlg getVariable "interior_ctrl"), cbChecked (_dlg getVariable "garrison_ctrl")] };
private _parts = ["interior", false] call _fnc_set;
["T24.3 interior off, garrison stays on", _parts isEqualTo [false, true] && {(call _fnc_checked) isEqualTo [false, true]}, _parts] call PFUNC(dev_check);
_parts = ["garrison", false] call _fnc_set;
["T24.4 turning off the last part turns the other back on", _parts isEqualTo [true, false] && {(call _fnc_checked) isEqualTo [true, false]}, [_parts, call _fnc_checked]] call PFUNC(dev_check);
_parts = ["interior", false] call _fnc_set;
["T24.5 never both off", _parts isEqualTo [false, true], _parts] call PFUNC(dev_check);

private _tabs = _dlg getVariable QPVAR(tabControls);
["T24.6 the part that is off is greyed out", ((_tabs select 0) findIf { ctrlEnabled _x } == -1) && {(_tabs select 1) findIf { !ctrlEnabled _x } == -1}] call PFUNC(dev_check);
[_dlg, 1] call (_dlg getVariable QPVAR(showTab));
["T24.7 a tab shows only its own rows", ((_tabs select 1) findIf { !ctrlShown _x } == -1) && {((_tabs select 0) + (_tabs select 2)) findIf { ctrlShown _x } == -1}] call PFUNC(dev_check);

// ---- interior only, through the dialog
["interior", true] call _fnc_set;
["garrison", false] call _fnc_set;
_dlg setVariable ["radius", 0];
[_dlg] call PFUNC(ui_dialogConfirm);
private _closeTimeout = diag_tickTime + 1;
waitUntil { isNull findDisplay 1706 || {diag_tickTime > _closeTimeout} };
private _done = call _fnc_waitQueue;
["T24.8 interior only: furnished, no units", isNull findDisplay 1706 && {_done} && {[_bld] call _fnc_furnished} && {([_bld] call _fnc_units) isEqualTo []} && {!(_bld getVariable [QPVAR(garrisoned), false])},
	[isNull findDisplay 1706, _done, [_bld] call _fnc_furnished, count ([_bld] call _fnc_units)]] call PFUNC(dev_check);
private _saved = missionNamespace getVariable [QPVAR(UiAdvancedFill), createHashMap];
["T24.9 settings saved for Alt", (_saved getOrDefault ["interior", false]) && {!(_saved getOrDefault ["garrison", true])}] call PFUNC(dev_check);
if (!isNull findDisplay 1706) then { (findDisplay 1706) closeDisplay 2 };

// ---- garrison only
_bld = [DEV_HOUSE, 51] call PFUNC(dev_spawn);
PVAR(UiLastBuilding) = _bld;
[_garrisonOnly] call PFUNC(ui_advancedFill);
_done = call _fnc_waitQueue;
sleep 0.5;
["T24.10 garrison only: units, not furnished", _done && {([_bld] call _fnc_units) isNotEqualTo []} && {!([_bld] call _fnc_furnished)},
	[_done, count ([_bld] call _fnc_units), [_bld] call _fnc_furnished]] call PFUNC(dev_check);

// ---- both: one step per frame, a per-frame recorder notes when each building got its interior and its first unit
private _both = [[DEV_HOUSE, 52] call PFUNC(dev_spawn), [DEV_HOUSE, 53] call PFUNC(dev_spawn)];
PVAR(dev_frames) = _both apply { [-1, -1] };
private _recorder = addMissionEventHandler ["EachFrame", {
	{
		private _frames = PVAR(dev_frames) select _forEachIndex;
		if ((_frames select 0) < 0 && {!isNull (_x getVariable [QPVAR(furnished), objNull])}) then { _frames set [0, diag_frameNo] };
		if ((_frames select 1) < 0 && {((_x nearEntities ["CAManBase", 30]) select { !isPlayer _x }) isNotEqualTo []}) then { _frames set [1, diag_frameNo] };
	} forEach (_thisArgs select 0);
}, [_both]];
ZEIC_queueBudget = 0;
[_both, ["mil", [OBJECT_MODE_SIMPLE, false]], ["BLU_F", "EdSubcat_Personnel", [50, false, false]]] call PFUNC(advancedFill_start);
_done = call _fnc_waitQueue;
sleep 0.5;
ZEIC_queueBudget = nil;
removeMissionEventHandler ["EachFrame", _recorder];
private _frames = PVAR(dev_frames);
["T24.11 both: every building furnished and garrisoned", _done && {_frames findIf { (_x select 0) < 0 || {(_x select 1) < 0} } == -1}, _frames] call PFUNC(dev_check);
["T24.12 both: per building the interior before the units", _frames findIf { (_x select 1) <= (_x select 0) } == -1, _frames] call PFUNC(dev_check);
// In processing order: the queue sorts the buildings (see PFUNC(queue_sortBuildings))
private _byInterior = +_frames;
_byInterior sort true;
["T24.13 both: building by building (the first one's units before the second one's interior)", ((_byInterior select 0) select 1) < ((_byInterior select 1) select 0), _byInterior] call PFUNC(dev_check);
["T24.14 reported interiors are cleared with the garrison job", count (missionNamespace getVariable [QPVAR(interiorDone), createHashMap]) == 0] call PFUNC(dev_check);

// ---- Alt: without last settings nothing happens, with them the dialog is skipped
// The module looks for a building at the mouse, so the house is placed there
private _spot = screenToWorld getMousePosition;
private _altHouse = createVehicle [DEV_HOUSE, _spot, [], 0, "CAN_COLLIDE"];
private _savedModifiers = uiNamespace getVariable [QPVAR(modifiers), [false, false, false]];
private _fnc_placeModule = {
	private _temp = "Module_F" createVehicleLocal _spot;
	["init", [_temp, true, true]] call PFUNC(mod_advancedFill);
	if (!isNull _temp) then { deleteVehicle _temp };
};
uiNamespace setVariable [QPVAR(modifiers), [false, false, true]];

PVAR(UiAdvancedFill) = nil;
call _fnc_placeModule;
sleep 0.1;
["T24.15 Alt without last settings: no dialog, nothing queued", isNull findDisplay 1706 && {(missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo []} && {!(_altHouse getVariable [QPVAR(garrisoned), false])}] call PFUNC(dev_check);

PVAR(UiAdvancedFill) = +_garrisonOnly;
call _fnc_placeModule;
uiNamespace setVariable [QPVAR(modifiers), _savedModifiers];
sleep 0.1;
private _noDialog = isNull findDisplay 1706;
_done = call _fnc_waitQueue;
sleep 0.5;
private _altUnits = [_altHouse] call _fnc_units;
["T24.16 Alt repeats the last settings without the dialog (garrison only)", _noDialog && {_done} && {PVAR(UiLastBuilding) == _altHouse} && {_altUnits isNotEqualTo []} && {!([_altHouse] call _fnc_furnished)},
	[_noDialog, _done, PVAR(UiLastBuilding), count _altUnits, [_altHouse] call _fnc_furnished]] call PFUNC(dev_check);
if (!isNull findDisplay 1706) then { (findDisplay 1706) closeDisplay 2 };

// The house was placed in front of the player, not in the test area
{ deleteVehicle _x } forEach _altUnits;
deleteVehicle _altHouse;
