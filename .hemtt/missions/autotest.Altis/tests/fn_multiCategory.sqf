#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* Interior Fill from several categories (#85): merged template pool, a single category as a string still works,
* a fill with several categories, and the Advanced Fill dialog's category checkboxes.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["multiCategory"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["Templates of several categories are one pool", {
        params ["_ctx"];

        private _houseClass = DEV_HOUSE;
        ZEIC_zeicmulti_a_customBuildings = [[_houseClass, [[["Land_Pallets_F", [0, 0, 0.1], 0]]]]];
        ZEIC_zeicmulti_b_customBuildings = [[_houseClass, [[["Land_WoodenCrate_01_F", [1, 0, 0.1], 0]], [["Land_Pallets_F", [2, 0, 0.1], 90]]]]];

        private _a = [_houseClass, "zeicmulti_a", true] call PFUNC(findTemplates);
        private _b = [_houseClass, ["zeicmulti_b"], true] call PFUNC(findTemplates);
        private _both = [_houseClass, ["zeicmulti_a", "ZEICMULTI_B"], true] call PFUNC(findTemplates);
        ["several categories: one merged pool, in category order", _both isEqualTo (_a + _b) && {count _both == 3}, [count _a, count _b, count _both]] call autotest_fnc_check;
        ["a single category as a string is the same as an array of one",
            ([_houseClass, "mil", true] call PFUNC(findTemplates)) isEqualTo ([_houseClass, ["mil"], true] call PFUNC(findTemplates))] call autotest_fnc_check;
        private _mil = count ([_houseClass, "mil", true] call PFUNC(findTemplates));
        private _civ = count ([_houseClass, "civ", true] call PFUNC(findTemplates));
        ["mil + civ pool is the sum of both", count ([_houseClass, ["mil", "civ"], true] call PFUNC(findTemplates)), _mil + _civ] call autotest_fnc_checkEqual;
        ["no categories: no templates", [_houseClass, [], true] call PFUNC(findTemplates), []] call autotest_fnc_checkEqual;

        ZEIC_zeicmulti_a_customBuildings = nil;
        ZEIC_zeicmulti_b_customBuildings = nil;
    }],

    ["A fill with several categories uses the one that has a template", {
        params ["_ctx"];

        ZEIC_zeicmulti_b_customBuildings = [[DEV_HOUSE, [[["Land_Pallets_F", [2, 0, 0.1], 90]]]]];
        private _bld = [DEV_HOUSE, 92] call autotest_helper_fnc_spawn;
        isNil { [[_bld], ["zeicmulti_a", "zeicmulti_b"], [OBJECT_MODE_SIMPLE, false]] call PFUNC(interiorFill_start) };
        private _done = [{ (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] }, 30] call autotest_fnc_waitFor;
        ["queue finished within 30 s", _done] call autotest_fnc_check;
        ["building furnished from the second category", !isNull (_bld getVariable [QPVAR(furnished), objNull])] call autotest_fnc_check;
        ZEIC_zeicmulti_b_customBuildings = nil;
    }, 60],

    ["Advanced Fill: category checkboxes", {
        params ["_ctx"];

        // Starts with the last ticked categories, needs one ticked, saves class names
        PVAR(UiLastBuilding) = [DEV_HOUSE, 93] call autotest_helper_fnc_spawn;
        PVAR(UiAdvancedFill) = createHashMapFromArray [["interior", true], ["garrison", false], ["categories", ["civ"]]];
        createDialog "Rsc_ZEIC_AdvancedFill";
        private _dlg = findDisplay 1706;
        private _boxes = _dlg getVariable ["categories_ctrl", []];
        ["a checkbox per category, the last ticked ones on",
            !isNull _dlg && {count _boxes == count (call PFUNC(interiorFill_categories))} && {(_dlg getVariable ["categories", []]) isEqualTo ["civ"]}
            && {((_boxes select { cbChecked _x }) apply { _x getVariable QPVAR(value) }) isEqualTo ["civ"]}, _dlg getVariable ["categories", []]] call autotest_fnc_check;
        if (!isNull _dlg) then {
            [_dlg, 2] call (_dlg getVariable QPVAR(showTab));
            _dlg setVariable ["categories", []];
            [_dlg] call PFUNC(ui_dialogConfirm);
            ["confirm without a ticked category keeps the dialog open on the Interior tab",
                !isNull findDisplay 1706 && {(_dlg getVariable ["tab", -1]) == 0}, _dlg getVariable ["tab", -1]] call autotest_fnc_check;
            _dlg setVariable ["categories", ["mil", "cbrn"]];
            _dlg setVariable ["radius", 0];
            [_dlg] call PFUNC(ui_dialogConfirm);
            [{ (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] }, 30] call autotest_fnc_waitFor;
        };
        ["the ticked categories are saved as class names", (missionNamespace getVariable [QPVAR(UiAdvancedFill), createHashMap]) getOrDefault ["categories", []], ["mil", "cbrn"]] call autotest_fnc_checkEqual;
        if (!isNull findDisplay 1706) then { (findDisplay 1706) closeDisplay 2 };
        PVAR(UiAdvancedFill) = nil;
    }, 60]
]
