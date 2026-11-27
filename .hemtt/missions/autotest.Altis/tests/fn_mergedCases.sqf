#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* Buildings that had duplicate templates in the old SQF lists still have all of them.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["mergedCases"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["Buildings that had duplicate templates in the old SQF lists still have all of them", {
        params ["_ctx"];

        // T6 merged duplicate cases (#30)
        {
            _x params ["_class", "_category", "_min"];
            if (isClass (configFile >> "CfgVehicles" >> _class)) then {
                private _bld = [_class, _forEachIndex + 1] call autotest_helper_fnc_spawn;
                private _count = count ([_bld, _category, true] call PFUNC(findTemplates));
                [format ["%1 (%2) has >= %3 templates", _class, _category, _min], _count >= _min, _count] call autotest_fnc_check;
            } else {
                diag_log text format ["[ZEIC TEST] SKIP T6.%1 %2 not loaded", _forEachIndex + 1, _class];
            };
        } forEach [
            ["Land_Mine_01_warehouse_F", "mil", 2],
            ["Land_dp_bigTank_old_F", "mil", 2],
            ["Land_Radar_01_antenna_base_F", "mil", 2],
            ["Land_Cargo_Tower_V1_No1_F", "mil", 1],
            ["Land_DeconTent_01_yellow_F", "cbrn", 2],
            ["Land_DeconTent_01_white_F", "cbrn", 2],
            ["Land_DeconTent_01_IDAP_F", "cbrn", 2]
        ];
    }, 180]
]
