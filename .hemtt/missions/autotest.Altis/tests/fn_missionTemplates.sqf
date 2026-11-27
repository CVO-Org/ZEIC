#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* Templates and categories from the mission's description.ext (the test missions have them).
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["missionTemplates"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["Templates and categories from the mission's description.ext", {
        params ["_ctx"];

        // T12 mission templates and categories (description.ext, #24)
        if (!isClass (missionConfigFile >> "CfgZEIC" >> "zeic_test")) exitWith {
            diag_log text "[ZEIC TEST] SKIP T12 the mission has no test templates (see description.ext of the test missions)";
        };

        private _categoryClasses = (call PFUNC(interiorFill_categories)) apply { _x select 1 };
        ["categories sorted by order: mil, civ, cbrn first", (_categoryClasses select [0, 3]) isEqualTo ["mil", "civ", "cbrn"], _categoryClasses] call autotest_fnc_check;
        ["mission category listed", "zeic_test" in _categoryClasses] call autotest_fnc_check;
        private _missionFound = ["Land_i_House_Small_03_V1_F", "zeic_test", true] call PFUNC(findTemplates);
        ["mission category: template with missing object skipped", count _missionFound == 1, count _missionFound] call autotest_fnc_check;
        ["mission template added to an addon category",
            [["Land_Pallets_F", [0, 0, 0.5], 45]] in (["Land_i_House_Small_03_V1_F", "mil", true] call PFUNC(findTemplates))] call autotest_fnc_check;
    }, 180]
]
