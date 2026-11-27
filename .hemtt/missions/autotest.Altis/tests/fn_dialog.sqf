#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* The Interior Fill dialog.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["dialog"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The Interior Fill dialog", {
        params ["_ctx"];

        private _houseClass = DEV_HOUSE;

        // T14 Interior Fill dialog (#6, #25)
        private _dlgHouse = [_houseClass, 40] call autotest_helper_fnc_spawn;
        ZEIC_UiLastBuilding = _dlgHouse;
        ZEIC_UiLastPosition = getPos _dlgHouse;
        ZEIC_UiInteriorCategories = ["civ", "zeic_gone"];
        ZEIC_UiInteriorRadius = 0;
        createDialog "Rsc_ZEIC_InteriorFill";
        private _dlg = findDisplay 1705;
        ["dialog opens", !isNull _dlg] call autotest_fnc_check;
        if (!isNull _dlg) then {
            private _boxes = _dlg getVariable ["categories_ctrl", []];
            private _classes = (call PFUNC(interiorFill_categories)) apply { _x select 1 };
            ["one checkbox per category", count _boxes == count _classes && {(_boxes apply { _x getVariable [QPVAR(value), ""] }) isEqualTo _classes}, [count _boxes, _classes]] call autotest_fnc_check;
            ["last ticked categories preselected, a category that is gone left out",
                (_dlg getVariable ["categories", []]) isEqualTo ["civ"] && {((_boxes select { cbChecked _x }) apply { _x getVariable QPVAR(value) }) isEqualTo ["civ"]},
                _dlg getVariable ["categories", []]] call autotest_fnc_check;
            ["object modes and damage shown outside Eden", !isNull (_dlg getVariable ["objects_ctrl", controlNull]) && {!isNull (_dlg getVariable ["damage_ctrl", controlNull])}] call autotest_fnc_check;

            // Nothing ticked: confirming keeps the dialog open
            _dlg setVariable ["categories", []];
            [_dlg] call PFUNC(ui_dialogConfirm);
            ["confirm without a ticked category keeps the dialog open", !isNull findDisplay 1705 && {!(_dlg getVariable [QPVAR(confirmed), false])}] call autotest_fnc_check;
            { _x cbSetChecked ((_x getVariable QPVAR(value)) in ["mil", "civ"]) } forEach _boxes;
            _dlg setVariable ["categories", ["mil", "civ"]];

            private _slider = _dlg getVariable ["radius_ctrl", controlNull];
            ["radius preview drawn around the module position", (_slider getVariable [QPVAR(previewEH), -1]) >= 0] call autotest_fnc_check;
            ["radius slider with its number field", !isNull _slider && {sliderPosition _slider == 0}, sliderRange _slider] call autotest_fnc_check;

            [_dlg] call PFUNC(ui_dialogConfirm);
            // The display may only be gone a frame later
            private _closeTimeout = diag_tickTime + 1;
            waitUntil { isNull findDisplay 1705 || {diag_tickTime > _closeTimeout} };
            ["confirm closes the dialog", isNull findDisplay 1705, diag_tickTime - _closeTimeout + 1] call autotest_fnc_check;
            ["confirm starts the fill", _dlgHouse getVariable ["ZEIC_queued", false] || {!isNull (_dlgHouse getVariable ["ZEIC_furnished", objNull])}] call autotest_fnc_check;
            ["ticked categories remembered as class names", ZEIC_UiInteriorCategories isEqualTo ["mil", "civ"], ZEIC_UiInteriorCategories] call autotest_fnc_check;

            private _dlgTimeout = diag_tickTime + 30;
            waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _dlgTimeout} };
        };

        // Chance: a share of the buildings within the radius
        private _chanceCenter = PVAR(dev_origin) vectorAdd [300, 1100, 0];
        private _chanceHouses = [];
        for "_i" from 0 to 3 do { _chanceHouses pushBack (createVehicle [DEV_HOUSE, _chanceCenter vectorAdd [_i * 25, 0, 0], [], 0, "CAN_COLLIDE"]) };
        PVAR(UiLastBuilding) = _chanceHouses select 0;
        PVAR(UiLastPosition) = _chanceCenter vectorAdd [37.5, 0, 0];
        isNil { [["mil"], 60, OBJECT_MODE_SIMPLE, false, 50] call PFUNC(ui_interiorFill) };
        private _chanceQueued = { _x getVariable ["ZEIC_queued", false] || {!isNull (_x getVariable ["ZEIC_furnished", objNull])} } count _chanceHouses;
        ["chance 50% fills 2 of 4 buildings", _chanceQueued == 2, _chanceQueued] call autotest_fnc_check;
        ["chance remembered for Alt and shortcuts", PVAR(UiInteriorChance) == 50] call autotest_fnc_check;
        PVAR(UiInteriorChance) = 100;
        private _chanceTimeout = diag_tickTime + 30;
        waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _chanceTimeout} };
    }, 180]
]
