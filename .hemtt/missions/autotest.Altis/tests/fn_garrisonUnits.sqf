#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* units per building as a percentage of the positions (capped at 1.5 x the median), and the shared helper that picks a
* share of the buildings (#57).
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["garrisonUnits"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["Units per building as a percentage of the positions", {
        params ["_ctx"];

        // T22 garrison unit counts and building share (#57)
        private _counts = [[4, 4, 4, 60], 50] call PFUNC(garrisonBuilding_unitCounts);
        ["huts + large building: cap 1.5 x median applied", _counts isEqualTo [2, 2, 2, 3], _counts] call autotest_fnc_check;
        _counts = [[4, 60], 100] call PFUNC(garrisonBuilding_unitCounts);
        ["hut + large building, two values: median between them", _counts isEqualTo [4, 48], _counts] call autotest_fnc_check;
        _counts = [[60], 50] call PFUNC(garrisonBuilding_unitCounts);
        ["single building: no cap", _counts isEqualTo [30], _counts] call autotest_fnc_check;
        _counts = [[4, 2, 8], 10] call PFUNC(garrisonBuilding_unitCounts);
        ["at least 1 unit per building", _counts isEqualTo [1, 1, 1], _counts] call autotest_fnc_check;
        _counts = [[3, 3, 3], 100] call PFUNC(garrisonBuilding_unitCounts);
        ["never more units than positions", _counts isEqualTo [3, 3, 3], _counts] call autotest_fnc_check;
        ["no buildings: no counts", ([[], 50] call PFUNC(garrisonBuilding_unitCounts)) isEqualTo []] call autotest_fnc_check;

        private _items = [1, 2, 3, 4, 5, 6, 7];
        private _share = [_items, 30] call PFUNC(misc_selectShare);
        ["share rounds to nearest: 7 at 30% gives 2", count _share == 2 && {(_share - _items) isEqualTo []}, _share] call autotest_fnc_check;
        _share = [[1], 10] call PFUNC(misc_selectShare);
        ["share: at least one", _share isEqualTo [1], _share] call autotest_fnc_check;
        _share = [_items, 100] call PFUNC(misc_selectShare);
        ["share 100% picks all, without duplicates", count _share == 7 && {count (_share arrayIntersect _share) == 7}, _share] call autotest_fnc_check;
        ["share of nothing is nothing", ([[], 50] call PFUNC(misc_selectShare)) isEqualTo []] call autotest_fnc_check;
    }, 180]
]
