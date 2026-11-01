#include "..\..\script_component.hpp"

/*
* Self test: the Garrison Building dialog (faction filters, subcategory, recently used).
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

// T15 Garrison dialog (#9)
private _bld = [DEV_HOUSE, 41] call PFUNC(dev_spawn);
PVAR(UiLastBuilding) = _bld;
PVAR(UiGarrisonFaction) = nil;
PVAR(UiGarrisonPositions) = 10;
PVAR(UiGarrisonRadius) = 0;
uiNamespace setVariable [QPVAR(garrisonRecent), nil];

private _factions = call PFUNC(garrisonBuilding_factions);
["T15.1 factions found, NATO among them", _factions findIf { (_x select 1) == "BLU_F" } != -1, count _factions] call PFUNC(dev_check);

createDialog "Rsc_ZEIC_GarrisonBuilding";
private _dlg = findDisplay 1702;
["T15.2 dialog opens", !isNull _dlg] call PFUNC(dev_check);
if (isNull _dlg) exitWith {};

private _list = _dlg getVariable ["faction_ctrl", controlNull];
["T15.3 all factions listed, no recently used list", lbSize _list == count _factions && {isNull (_dlg getVariable ["recent_ctrl", controlNull])}, [lbSize _list, count _factions]] call PFUNC(dev_check);
["T15.4 a faction and subcategory are preselected", count (_dlg getVariable [QPVAR(selection), []]) == 2, _dlg getVariable [QPVAR(selection), []]] call PFUNC(dev_check);

// Estimate: radius 0, one building with 10% of its positions (#57)
private _estimate = ctrlText (_dlg getVariable ["estimate_ctrl", controlNull]);
private _estimateUnits = 1 max round ((count (_bld buildingPos -1)) / 10);
["T15.14 estimate shows the one building", _estimate == format [LLSTRING(ModuleGarrisonBuilding_EstimateSingle), _estimateUnits], _estimate] call PFUNC(dev_check);
private _positionsSlider = _dlg getVariable ["positions_ctrl", controlNull];
[_positionsSlider, 100] call (_positionsSlider getVariable QPVAR(store));
_estimate = ctrlText (_dlg getVariable ["estimate_ctrl", controlNull]);
["T15.15 estimate follows the Positions slider", _estimate == format [LLSTRING(ModuleGarrisonBuilding_EstimateSingle), count (_bld buildingPos -1)], _estimate] call PFUNC(dev_check);
[_positionsSlider, 10] call (_positionsSlider getVariable QPVAR(store));

private _fnc_listed = { private _out = []; for "_i" from 0 to (lbSize _list - 1) do { _out pushBack (_list lbData _i) }; _out };
private _fnc_info = { params ["_class"]; _factions select (_factions findIf { (_x select 1) == _class }) };

// Search matches name or class, case-insensitive
_dlg setVariable ["search", "blu_f"];
_dlg call (_dlg getVariable QPVAR(fillFactions));
private _listed = call _fnc_listed;
private _unmatched = _listed select { (toLowerANSI _x find "blu_f") == -1 && {(toLowerANSI (([_x] call _fnc_info) select 0) find "blu_f") == -1} };
["T15.5 search filters by name or class", "BLU_F" in _listed && {_unmatched isEqualTo []}, [count _listed, _unmatched]] call PFUNC(dev_check);

// Side filter: OPFOR (toolbox index 2) shows only side 0
_dlg setVariable ["search", ""];
_dlg setVariable ["side", 2];
_dlg call (_dlg getVariable QPVAR(fillFactions));
_listed = call _fnc_listed;
private _wrongSide = _listed select { (([_x] call _fnc_info) select 2) != 0 };
["T15.6 side filter shows only OPFOR", _listed isNotEqualTo [] && {_wrongSide isEqualTo []} && {!("BLU_F" in _listed)}, _wrongSide] call PFUNC(dev_check);
["T15.7 filtered-out faction is no longer picked", (_dlg getVariable [QPVAR(selection), []]) isEqualTo [] || {((_dlg getVariable QPVAR(selection)) select 0) in _listed}] call PFUNC(dev_check);

// Pick NATO
_dlg setVariable ["side", 0];
_dlg call (_dlg getVariable QPVAR(fillFactions));
_list lbSetCurSel ((call _fnc_listed) find "BLU_F");
["T15.8 picking NATO selects its Men", (_dlg getVariable [QPVAR(selection), []]) isEqualTo ["BLU_F", "EdSubcat_Personnel"], _dlg getVariable [QPVAR(selection), []]] call PFUNC(dev_check);

// Nothing picked: confirm keeps the dialog open
private _keep = _dlg getVariable QPVAR(selection);
_dlg setVariable [QPVAR(selection), []];
[_dlg] call PFUNC(ui_dialogConfirm);
["T15.9 confirm without a faction keeps the dialog open", !isNull findDisplay 1702] call PFUNC(dev_check);
_dlg setVariable [QPVAR(selection), _keep];

[_dlg] call PFUNC(ui_dialogConfirm);
private _closeTimeout = diag_tickTime + 1;
waitUntil { isNull findDisplay 1702 || {diag_tickTime > _closeTimeout} };
["T15.10 confirm closes the dialog and starts the garrison", isNull findDisplay 1702 && {_bld getVariable [QPVAR(garrisoned), false]},
	[isNull findDisplay 1702, _bld getVariable [QPVAR(garrisoned), false], _dlg getVariable [QPVAR(confirmed), "-"], _dlg getVariable ["units", "-"]]] call PFUNC(dev_check);
if (!isNull findDisplay 1702) then { (findDisplay 1702) closeDisplay 2; sleep 0.1 };
["T15.11 pair added to recently used", (uiNamespace getVariable [QPVAR(garrisonRecent), []]) isEqualTo [["BLU_F", "EdSubcat_Personnel"]]] call PFUNC(dev_check);

private _timeout = diag_tickTime + 30;
waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };

// Reopened: the recently used pair is shown and preselected
createDialog "Rsc_ZEIC_GarrisonBuilding";
_dlg = findDisplay 1702;
private _recentList = _dlg getVariable ["recent_ctrl", controlNull];
["T15.12 recently used list preselects the last pair", lbSize _recentList == 1 && {lbCurSel _recentList == 0} && {(_dlg getVariable [QPVAR(selection), []]) isEqualTo ["BLU_F", "EdSubcat_Personnel"]}, [lbSize _recentList, lbCurSel _recentList]] call PFUNC(dev_check);
["T15.13 recently used clears the faction list selection", lbCurSel (_dlg getVariable "faction_ctrl") == -1] call PFUNC(dev_check);
_dlg closeDisplay 2;
