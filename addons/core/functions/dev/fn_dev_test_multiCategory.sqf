#include "..\..\script_component.hpp"

/*
* Self test: Interior Fill from several categories (#85): merged template pool, a single category as a string still
* works, candidates and the queue with several categories.
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

// T30 several categories (#85)
private _houseClass = DEV_HOUSE;
ZEIC_zeicmulti_a_customBuildings = [[_houseClass, [[["Land_Pallets_F", [0, 0, 0.1], 0]]]]];
ZEIC_zeicmulti_b_customBuildings = [[_houseClass, [[["Land_WoodenCrate_01_F", [1, 0, 0.1], 0]], [["Land_Pallets_F", [2, 0, 0.1], 90]]]]];

private _a = [_houseClass, "zeicmulti_a", true] call PFUNC(findTemplates);
private _b = [_houseClass, ["zeicmulti_b"], true] call PFUNC(findTemplates);
private _both = [_houseClass, ["zeicmulti_a", "ZEICMULTI_B"], true] call PFUNC(findTemplates);
["T30.1 several categories: one merged pool, in category order", _both isEqualTo (_a + _b) && {count _both == 3}, [count _a, count _b, count _both]] call PFUNC(dev_check);
["T30.2 a single category as a string is the same as an array of one",
	([_houseClass, "mil", true] call PFUNC(findTemplates)) isEqualTo ([_houseClass, ["mil"], true] call PFUNC(findTemplates))] call PFUNC(dev_check);
private _mil = count ([_houseClass, "mil", true] call PFUNC(findTemplates));
private _civ = count ([_houseClass, "civ", true] call PFUNC(findTemplates));
private _milCiv = count ([_houseClass, ["mil", "civ"], true] call PFUNC(findTemplates));
["T30.3 mil + civ pool is the sum of both", _milCiv == _mil + _civ, [_mil, _civ, _milCiv]] call PFUNC(dev_check);
["T30.4 no categories: no templates", ([_houseClass, [], true] call PFUNC(findTemplates)) isEqualTo []] call PFUNC(dev_check);

// A building that only the second category has templates for is furnished from it
private _bld = [_houseClass, 92] call PFUNC(dev_spawn);
ZEIC_zeicmulti_a_customBuildings = nil;
isNil { [[_bld], ["zeicmulti_a", "zeicmulti_b"], [OBJECT_MODE_SIMPLE, false]] call PFUNC(interiorFill_start) };
private _timeout = diag_tickTime + 30;
waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };
["T30.5 fill with several categories uses the category that has a template", !isNull (_bld getVariable [QPVAR(furnished), objNull])] call PFUNC(dev_check);
ZEIC_zeicmulti_b_customBuildings = nil;

// Advanced Fill: starts with the last ticked categories, needs one ticked, saves class names
PVAR(UiLastBuilding) = [_houseClass, 93] call PFUNC(dev_spawn);
PVAR(UiAdvancedFill) = createHashMapFromArray [["interior", true], ["garrison", false], ["categories", ["civ"]]];
createDialog "Rsc_ZEIC_AdvancedFill";
private _dlg = findDisplay 1706;
private _boxes = _dlg getVariable ["categories_ctrl", []];
["T30.6 Advanced Fill: a checkbox per category, the last ticked ones on",
	!isNull _dlg && {count _boxes == count (call PFUNC(interiorFill_categories))} && {(_dlg getVariable ["categories", []]) isEqualTo ["civ"]}
	&& {((_boxes select { cbChecked _x }) apply { _x getVariable QPVAR(value) }) isEqualTo ["civ"]}, _dlg getVariable ["categories", []]] call PFUNC(dev_check);
if (!isNull _dlg) then {
	[_dlg, 2] call (_dlg getVariable QPVAR(showTab));
	_dlg setVariable ["categories", []];
	[_dlg] call PFUNC(ui_dialogConfirm);
	["T30.7 Advanced Fill: confirm without a ticked category keeps the dialog open on the Interior tab",
		!isNull findDisplay 1706 && {(_dlg getVariable ["tab", -1]) == 0}, _dlg getVariable ["tab", -1]] call PFUNC(dev_check);
	_dlg setVariable ["categories", ["mil", "cbrn"]];
	_dlg setVariable ["radius", 0];
	[_dlg] call PFUNC(ui_dialogConfirm);
	private _timeoutAdv = diag_tickTime + 30;
	waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeoutAdv} };
};
private _saved = (missionNamespace getVariable [QPVAR(UiAdvancedFill), createHashMap]) getOrDefault ["categories", []];
["T30.8 Advanced Fill: the ticked categories are saved as class names", _saved isEqualTo ["mil", "cbrn"], _saved] call PFUNC(dev_check);
if (!isNull findDisplay 1706) then { (findDisplay 1706) closeDisplay 2 };
PVAR(UiAdvancedFill) = nil;
