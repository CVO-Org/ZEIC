#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* CfgPatches of the mod and all functions compiled.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["addon"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["CfgPatches of the mod and all functions compiled", {
        params ["_ctx"];

        // T0 CfgPatches (#29)
        private _cfgCore = configFile >> "CfgPatches" >> "ZEIC_core";
        ["CfgPatches ZEIC_core exists", isClass _cfgCore] call autotest_fnc_check;
        ["CfgPatches ZEIC_main exists", isClass (configFile >> "CfgPatches" >> "ZEIC_main")] call autotest_fnc_check;
        ["no CfgPatches named ADDON", !isClass (configFile >> "CfgPatches" >> "ADDON")] call autotest_fnc_check;
        ["ZEIC_core requires ZEIC_main", (getArray (_cfgCore >> "requiredAddons") findIf { _x == "ZEIC_main" }) != -1, getArray (_cfgCore >> "requiredAddons")] call autotest_fnc_check;

        private _curatorModules = getArray (_cfgCore >> "units") select { getNumber (configFile >> "CfgVehicles" >> _x >> "scopeCurator") == 2 };
        ["ZEIC_core lists the 5 Zeus modules", count _curatorModules == 5, _curatorModules] call autotest_fnc_check;
        ["Zeus module injection removed", isNil QPFUNC(zeus_addModules)] call autotest_fnc_check;

        // T1 all functions compiled (#29, #30)
        private _functions = [];
        {
            { _functions pushBack format ["ZEIC_fnc_%1", configName _x] } forEach ("true" configClasses _x);
        } forEach ("true" configClasses (configFile >> "CfgFunctions" >> "ZEIC"));
        private _broken = _functions select { !((missionNamespace getVariable [_x, 0]) isEqualType {}) };
        ["all ZEIC functions compiled", _broken isEqualTo [], [count _functions, _broken]] call autotest_fnc_check;
    }, 180]
]
