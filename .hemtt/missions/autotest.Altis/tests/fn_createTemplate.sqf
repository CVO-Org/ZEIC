#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* createTemplate spawns objects and marks the building as furnished.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["createTemplate"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["createTemplate spawns objects and marks the building as furnished", {
        params ["_ctx"];

        private _houseClass = DEV_HOUSE;

        // T7 createTemplate actually spawns (#29, #30)
        ZEIC_mil_customBuildings = nil;
        ZEIC_civ_customBuildings = nil;
        ZEIC_cbrn_customBuildings = nil;

        private _house2 = [_houseClass, 10] call autotest_helper_fnc_spawn;
        private _simpleBefore = count allSimpleObjects [];
        [_house2, "civ", false, false, false, 1] call PFUNC(createTemplate);
        private _simpleSpawned = (count allSimpleObjects []) - _simpleBefore;
        ["simple-object fill spawns objects", _simpleSpawned > 0, _simpleSpawned] call autotest_fnc_check;
        ["building marked as furnished", !isNull (_house2 getVariable ["ZEIC_furnished", objNull])] call autotest_fnc_check;

        private _house3 = [_houseClass, 11] call autotest_helper_fnc_spawn;
        private _nearBefore = count nearestObjects [_house3, [], 25];
        [_house3, "mil", false, true, false, 1] call PFUNC(createTemplate);
        sleep 1;
        private _nearSpawned = (count nearestObjects [_house3, [], 25]) - _nearBefore;
        ["editable-object fill spawns objects", _nearSpawned > 0, _nearSpawned] call autotest_fnc_check;

        private _again = count allSimpleObjects [];
        [_house2, "civ", false, false, false, 1] call PFUNC(createTemplate);
        ["furnished building is not filled twice", (count allSimpleObjects []) == _again] call autotest_fnc_check;
    }, 180]
]
