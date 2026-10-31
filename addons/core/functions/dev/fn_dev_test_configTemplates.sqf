#include "..\..\script_component.hpp"

/*
* Self test: Templates from CfgZEIC: categories, template addons, lookup and cache, variants.
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

// T11 config templates match the SQF templates (#24)
private _cfgRoot = configFile >> "CfgZEIC";
["T11.1 categories mil, civ, cbrn exist", ({ isClass (_cfgRoot >> _x) } count ["mil", "civ", "cbrn"]) == 3] call PFUNC(dev_check);
["T11.2 vanilla template addon loaded", isClass (configFile >> "CfgPatches" >> "ZEIC_templates_vanilla")] call PFUNC(dev_check);
{
	_x params ["_templateAddon", "_dependency"];
	[format ["T11.3 %1 loaded only with its dependency", _templateAddon],
		isClass (configFile >> "CfgPatches" >> _templateAddon) isEqualTo isClass (configFile >> "CfgPatches" >> _dependency)] call PFUNC(dev_check);
} forEach [
	["ZEIC_templates_cup", "CUP_Editor_Buildings_Config"],
	["ZEIC_templates_gm", "gm_core"],
	["ZEIC_templates_sog", "data_f_vietnam"],
	["ZEIC_templates_ws", "data_f_lxWS_Loadorder"],
	["ZEIC_templates_optre", "OPTRE_Core"]
];

ZEIC_mil_customBuildings = nil;
ZEIC_civ_customBuildings = nil;
ZEIC_cbrn_customBuildings = nil;

// The lookup returns exactly the config templates (addon + mission), inherited buildings (fall-through cases) included.
private _fnc_raw = {
	params ["_root", "_category", "_class"];
	(configProperties [_root >> "CfgZEIC" >> _category >> _class, "isClass _x", true]) apply { getArray (_x >> "objects") }
};
{
	_x params ["_class", "_category"];
	private _found = [_class, _category, true] call PFUNC(findTemplates);
	private _raw = ([configFile, _category, _class] call _fnc_raw) + ([missionConfigFile, _category, _class] call _fnc_raw);
	[format ["T11.%1 %2 (%3): lookup = config", 4 + _forEachIndex, _class, _category],
		_raw isNotEqualTo [] && {_found isEqualTo _raw}, [count _found, count _raw]] call PFUNC(dev_check);
} forEach [
	["Land_i_House_Small_03_V1_F", "mil"],
	["Land_i_House_Small_03_V1_F", "civ"],
	["Land_i_House_Small_03_V1_F", "cbrn"],
	["Land_Mine_01_warehouse_F", "mil"],
	["Land_Cargo_Tower_V1_No1_F", "mil"],
	["Land_Cargo_Tower_V3_F", "mil"],
	["Land_DeconTent_01_AAF_F", "cbrn"],
	["Land_DeconTent_01_yellow_F", "cbrn"]
];

["T11.12 inherited building has its parent's templates",
	count (["Land_DeconTent_01_AAF_F", "cbrn", true] call PFUNC(findTemplates)) == count (["Land_DeconTent_01_NATO_F", "cbrn", true] call PFUNC(findTemplates))] call PFUNC(dev_check);
["T11.13 lookup is cached", "mil|land_i_house_small_03_v1_f" in (uiNamespace getVariable ["ZEIC_templateCache", createHashMap])] call PFUNC(dev_check);
["T11.14 variant groups read from config", (["Land_GasTank_01_blue_F"] call PFUNC(randomiseObject)) in ["Land_GasTank_01_blue_F", "Land_GasTank_01_yellow_F", "Land_GasTank_01_khaki_F"]] call PFUNC(dev_check);
