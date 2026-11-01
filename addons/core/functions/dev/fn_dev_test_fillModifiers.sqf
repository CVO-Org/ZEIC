#include "..\..\script_component.hpp"

/*
* Self test: the fill modifiers of Advanced Fill (#55, phase 3): every class they name exists, the list and its order,
* remove / keep / replace on single classes (incl. parent classes, missing candidates, the order replace -> remove ->
* keep, subclasses and mission modifiers from test.Altis), then real fills with a test template, with the collision
* check and with normal objects, and the dialog for Alt.
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

// T27 Fill modifiers (#55)
private _fnc_exists = { isClass (configFile >> "CfgVehicles" >> _this) };
private _fnc_waitQueue = {
	private _timeout = diag_tickTime + 60;
	waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };
	(missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo []
};
private _fnc_apply = { params ["_names", "_classes"]; private _modifiers = [_names] call PFUNC(fillModifiers_resolve); _classes apply { [_x, _modifiers] call PFUNC(fillModifiers_apply) } };

// ---- every class named in an addon modifier exists; replace candidates may be missing, but each rule has one
private _missing = [];
private _noCandidate = [];
{
	{
		private _cfg = _x;
		{ if !(_x call _fnc_exists) then { _missing pushBack _x } } forEach (getArray (_cfg >> "remove") + getArray (_cfg >> "keep"));
		{
			if !(configName _x call _fnc_exists) then { _missing pushBack configName _x };
			if ((getArray _x) findIf { _x call _fnc_exists } == -1) then { _noCandidate pushBack configName _x };
		} forEach configProperties [_cfg >> "replace", "isArray _x"];
	} forEach ([_x] + ("toLower configName _x != 'replace'" configClasses _x));
} forEach ("true" configClasses (configFile >> "CfgZEIC_Modifiers"));
["T27.1 every class in remove[], keep[] and the replace keys exists", _missing isEqualTo [], _missing] call PFUNC(dev_check);
["T27.2 every replace rule has a candidate that exists", _noCandidate isEqualTo [], _noCandidate] call PFUNC(dev_check);

// ---- the list: core modifiers first, by order, translated; the mission's after them
private _list = call PFUNC(fillModifiers_list);
private _classes = _list apply { _x select 1 };
["T27.3 list: Military defences only, No modern electronics, Cold War era, then the mission's",
	(_classes select [0, 3]) isEqualTo ["defencesonly", "noelectronics", "coldwar"] && {"zeic_testorder" in _classes} && {(_list select [0, 3]) findIf { (_x select 0) find "STR_" != -1 || {(_x select 2) == ""} } == -1},
	_list] call PFUNC(dev_check);

// ---- single classes
private _none = [[], ["Land_Laptop_unfolded_F", "Land_ChairWood_F"]] call _fnc_apply;
private _unknown = [["does_not_exist"]] call PFUNC(fillModifiers_resolve);
["T27.4 no modifier or an unknown one: nothing changes", _none isEqualTo ["Land_Laptop_unfolded_F", "Land_ChairWood_F"] && {count _unknown == 0}, _none] call PFUNC(dev_check);

private _removed = [["noElectronics"], ["Land_Laptop_unfolded_F", "Land_Laptop_device_F", "Land_Tablet_02_black_F", "Land_ChairWood_F", "Land_Map_F"]] call _fnc_apply;
["T27.5 remove: laptops and tablets (also child classes) go, a chair stays; the mission adds a map", _removed isEqualTo ["", "", "", "Land_ChairWood_F", ""], _removed] call PFUNC(dev_check);

private _kept = [["defencesOnly"], ["Land_BagFence_01_long_green_F", "Land_HBarrier_5_F", "CamoNet_BLUFOR_F", "Land_ChairWood_F", "Land_Laptop_unfolded_F"]] call _fnc_apply;
["T27.6 keep: sandbags, H-barriers, camo nets (via parent classes) stay, the rest goes", _kept isEqualTo ["Land_BagFence_01_long_green_F", "Land_HBarrier_5_F", "CamoNet_BLUFOR_F", "", ""], _kept] call PFUNC(dev_check);

private _replaced = [["coldWar"], ["Land_PlasticCase_01_medium_idap_F", "Land_PlasticCase_01_large_F", "Land_PaperBox_01_small_closed_white_IDAP_F", "Land_Laptop_unfolded_F", "Land_MetalCase_01_small_F"]] call _fnc_apply;
["T27.7 replace: plastic cases (also child classes) and IDAP boxes become older ones, a laptop goes, a metal case stays",
	_replaced isEqualTo ["Land_MetalCase_01_medium_F", "Land_MetalCase_01_large_F", "Land_PaperBox_01_small_closed_brown_F", "", "Land_MetalCase_01_small_F"], _replaced] call PFUNC(dev_check);

// test.Altis: zeic_testOrder replaces the wooden chair with a plastic one and removes the plastic one;
// zeic_testKeep replaces the wooden chair with a plastic one and keeps only plastic chairs
private _order = [["zeic_testOrder"], ["Land_ChairWood_F", "Land_Bucket_F", "Land_Sack_F", "Land_Pallets_F"]] call _fnc_apply;
["T27.8 replace before remove; a missing candidate is skipped; no candidate: as-is; a subclass adds a remove",
	_order isEqualTo ["", "Land_Bucket_clean_F", "Land_Sack_F", ""], _order] call PFUNC(dev_check);
private _keepOrder = [["zeic_testKeep"], ["Land_ChairWood_F", "Land_Bucket_F"]] call _fnc_apply;
["T27.9 replace before keep: the replacement is kept", _keepOrder isEqualTo ["Land_ChairPlastic_F", ""], _keepOrder] call PFUNC(dev_check);
private _both = [["coldWar", "defencesOnly"], ["Land_PlasticCase_01_medium_F", "Land_BagFence_Long_F"]] call _fnc_apply;
private _union = [["defencesOnly", "zeic_testKeep"], ["Land_BagFence_Long_F", "Land_ChairPlastic_F", "Land_Bucket_F"]] call _fnc_apply;
["T27.10 several: keep checks the replacement; an object kept by any keep[] stays",
	_both isEqualTo ["", "Land_BagFence_Long_F"] && {_union isEqualTo ["Land_BagFence_Long_F", "Land_ChairPlastic_F", ""]}, [_both, _union]] call PFUNC(dev_check);

private _cached = [["coldWar"]] call PFUNC(fillModifiers_resolve);
["Land_PlasticCase_01_small_F", _cached] call PFUNC(fillModifiers_apply);
["T27.11 results are cached per fill", "land_plasticcase_01_small_f" in (_cached get "results")] call PFUNC(dev_check);

// ---- real fills with a test template (Advanced Fill, interior only)
private _probeHouse = [DEV_HOUSE, 80] call PFUNC(dev_spawn);
private _offset = _probeHouse worldToModel (_probeHouse buildingPos 0);
["zeictestmod", [DEV_HOUSE, [
	["Land_Laptop_unfolded_F", [3, 3, 0.5], 0],
	["Land_PlasticCase_01_large_F", _offset, 0],
	["Land_BagFence_Long_F", [-3, 3, 0.5], 0],
	["Land_ChairWood_F", [3, -3, 0.5], 0]
]]] call PFUNC(addCustomTemplate);
private _fnc_fill = {
	params ["_spot", "_modifiers", ["_objectMode", OBJECT_MODE_SIMPLE], ["_garrison", []], ["_collision", COLLISION_OFF]];
	private _bld = [DEV_HOUSE, _spot] call PFUNC(dev_spawn);
	private _before = (nearestObjects [_bld, [], 25, true]) + allSimpleObjects [];
	[[_bld], ["zeictestmod", [_objectMode, false], _modifiers], _garrison, _collision] call PFUNC(advancedFill_start);
	call _fnc_waitQueue;
	sleep 0.5;
	private _new = ((nearestObjects [_bld, [], 25, true]) + ((allSimpleObjects []) select { (_x distance _bld) < 25 })) - _before;
	private _types = (_new select { !(_x isKindOf "CAManBase") }) apply { typeOf _x };
	_types = _types arrayIntersect _types;
	_types sort true;
	[_bld, _types]
};

// Without Cold War era the large case is a random member of its variant group (metal or plastic)
private _fnc_case = { _this apply { [_x, "case"] select (_x isKindOf "Land_PlasticCase_01_large_F" || {_x isKindOf "Land_MetalCase_01_large_F"}) } };
([81, []] call _fnc_fill) params ["", "_plain"];
["T27.12 fill without modifiers: all four objects", (_plain call _fnc_case) isEqualTo ["Land_BagFence_Long_F", "Land_ChairWood_F", "Land_Laptop_unfolded_F", "case"] || {(_plain call _fnc_case) isEqualTo ["Land_BagFence_Long_F", "Land_ChairWood_F", "case", "Land_Laptop_unfolded_F"]}, _plain] call PFUNC(dev_check);

([82, ["noelectronics"]] call _fnc_fill) params ["", "_noLaptop"];
["T27.13 fill, No modern electronics: no laptop", (_noLaptop call _fnc_case) isEqualTo ["Land_BagFence_Long_F", "Land_ChairWood_F", "case"], _noLaptop] call PFUNC(dev_check);

([83, ["defencesonly"]] call _fnc_fill) params ["", "_defences"];
["T27.14 fill, Military defences only: only the sandbags", _defences isEqualTo ["Land_BagFence_Long_F"], _defences] call PFUNC(dev_check);

([84, ["coldwar"]] call _fnc_fill) params ["", "_coldWar"];
["T27.15 fill, Cold War era: metal case instead of the plastic one, no laptop", _coldWar isEqualTo ["Land_BagFence_Long_F", "Land_ChairWood_F", "Land_MetalCase_01_large_F"], _coldWar] call PFUNC(dev_check);

// Normal objects: the server's createVehicle path
([85, ["coldwar"], OBJECT_MODE_NORMAL] call _fnc_fill) params ["", "_normal"];
["T27.16 fill with normal objects, Cold War era: same result", _normal isEqualTo ["Land_BagFence_Long_F", "Land_ChairWood_F", "Land_MetalCase_01_large_F"], _normal] call PFUNC(dev_check);

// Furniture gives way: the replacement (metal case) stands on position 0 too, so it's left out
([86, ["coldwar"], OBJECT_MODE_SIMPLE, ["BLU_F", "EdSubcat_Personnel", [100, false, false]], COLLISION_FURNITURE_GIVES_WAY] call _fnc_fill) params ["_furnHouse", "_furn"];
private _units = (_furnHouse nearEntities ["CAManBase", 30]) select { !isPlayer _x };
["T27.17 furniture gives way + Cold War era: the replacement on position 0 is left out, units placed",
	(_furn arrayIntersect ["Land_MetalCase_01_large_F", "Land_PlasticCase_01_large_F", "Land_Laptop_unfolded_F"]) isEqualTo [] && {_units isNotEqualTo []}, [_furn, count _units]] call PFUNC(dev_check);
ZEIC_zeictestmod_customBuildings = nil;

// ---- the dialog starts with the checked modifiers (Alt repeats them), confirming saves them
PVAR(UiLastBuilding) = _probeHouse;
PVAR(UiAdvancedFill) = createHashMapFromArray [["interior", true], ["garrison", false], ["modifiers", ["coldwar", "zeic_testkeep"]]];
createDialog "Rsc_ZEIC_AdvancedFill";
private _dlg = findDisplay 1706;
private _shown = _classes apply { _dlg getVariable [format ["modifier_%1", _x], false] };
private _boxes = _classes apply { cbChecked (_dlg getVariable [format ["modifier_%1_ctrl", _x], controlNull]) };
private _expected = _classes apply { _x in ["coldwar", "zeic_testkeep"] };
["T27.18 dialog: a checkbox per modifier, the last checked ones on", !isNull _dlg && {_shown isEqualTo _expected} && {_boxes isEqualTo _expected}, [_classes, _shown, _boxes]] call PFUNC(dev_check);
if (!isNull _dlg) then {
	(_dlg getVariable "modifier_coldwar_ctrl") cbSetChecked false;
	(_dlg getVariable "modifier_noelectronics_ctrl") cbSetChecked true;
	_dlg setVariable ["modifier_coldwar", false];
	_dlg setVariable ["modifier_noelectronics", true];
	_dlg setVariable ["radius", 0];
	[_dlg] call PFUNC(ui_dialogConfirm);
	call _fnc_waitQueue;
};
private _saved = (missionNamespace getVariable [QPVAR(UiAdvancedFill), createHashMap]) getOrDefault ["modifiers", []];
["T27.19 confirming saves the checked modifiers for Alt, in list order", _saved isEqualTo ["noelectronics", "zeic_testkeep"], _saved] call PFUNC(dev_check);
if (!isNull findDisplay 1706) then { (findDisplay 1706) closeDisplay 2 };
PVAR(UiAdvancedFill) = nil;
