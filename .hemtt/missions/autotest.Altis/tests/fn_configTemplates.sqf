#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* Templates from CfgZEIC: categories, template addons, lookup and cache, variants.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["configTemplates"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["Templates from CfgZEIC", {
        params ["_ctx"];

        // T11 config templates match the SQF templates (#24)
        private _cfgRoot = configFile >> "CfgZEIC";
        ["categories mil, civ, cbrn exist", ({ isClass (_cfgRoot >> _x) } count ["mil", "civ", "cbrn"]) == 3] call autotest_fnc_check;
        ["vanilla template addon loaded", isClass (configFile >> "CfgPatches" >> "ZEIC_templates_vanilla")] call autotest_fnc_check;
        {
            _x params ["_templateAddon", "_dependency"];
            [format ["%1 loaded only with its dependency", _templateAddon],
                isClass (configFile >> "CfgPatches" >> _templateAddon) isEqualTo isClass (configFile >> "CfgPatches" >> _dependency)] call autotest_fnc_check;
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
            [format ["%1 (%2): lookup = config", _class, _category],
                _raw isNotEqualTo [] && {_found isEqualTo _raw}, [count _found, count _raw]] call autotest_fnc_check;
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

        ["inherited building has its parent's templates",
            count (["Land_DeconTent_01_AAF_F", "cbrn", true] call PFUNC(findTemplates)) == count (["Land_DeconTent_01_NATO_F", "cbrn", true] call PFUNC(findTemplates))] call autotest_fnc_check;
        ["lookup is cached", "mil|land_i_house_small_03_v1_f" in (uiNamespace getVariable ["ZEIC_templateCache", createHashMap])] call autotest_fnc_check;
        ["variant groups read from config", (["Land_GasTank_01_blue_F"] call PFUNC(randomiseObject)) in ["Land_GasTank_01_blue_F", "Land_GasTank_01_yellow_F", "Land_GasTank_01_khaki_F"]] call autotest_fnc_check;
    }, 180]
]
