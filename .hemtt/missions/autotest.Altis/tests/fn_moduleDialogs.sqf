#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* the Object Fill, Object Switch and List Buildings dialogs.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["moduleDialogs"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The Object Fill, Object Switch and List Buildings dialogs", {
        params ["_ctx"];

        private _fnc_waitClosed = {
            params ["_idd"];
            private _timeout = diag_tickTime + 1;
            waitUntil { isNull findDisplay _idd || {diag_tickTime > _timeout} };
            isNull findDisplay _idd
        };

        // T16 Object Fill dialog (#26)
        private _table = ["Land_TablePlastic_01_F", 42] call autotest_helper_fnc_spawn;
        PVAR(UiLastObject) = _table;
        PVAR(UiObjectFillType) = "food";
        PVAR(UiObjectFillPercent) = 100;
        PVAR(UiObjectFillObjects) = OBJECT_MODE_SIMPLE;
        createDialog "Rsc_ZEIC_ObjectFill";
        private _dlg = findDisplay 1704;
        ["Object Fill dialog opens", !isNull _dlg] call autotest_fnc_check;
        if (!isNull _dlg) then {
            ["Random plus every type, last one preselected", lbSize (_dlg getVariable ["type_ctrl", controlNull]) == 1 + count ("true" configClasses (configFile >> "CfgZEIC_ObjectFill" >> "Types")) && {(_dlg getVariable ["type", -1]) == 1}] call autotest_fnc_check;
            ["object modes shown outside Eden", !isNull (_dlg getVariable ["objects_ctrl", controlNull])] call autotest_fnc_check;

            private _simpleBefore = count allSimpleObjects [];
            [_dlg] call PFUNC(ui_dialogConfirm);
            private _closed = [1704] call _fnc_waitClosed;
            private _spawned = (count allSimpleObjects []) - _simpleBefore;
            ["confirm closes and fills the table with simple objects", _closed && {_spawned > 0}, [_closed, _spawned]] call autotest_fnc_check;
        };

        // T17 Object Switch dialog (#26)
        private _fence = ["Land_BagFence_Long_F", 43] call autotest_helper_fnc_spawn;
        PVAR(UiLastPosition) = getPosATL _fence;
        PVAR(UiSwitchCombo) = "jungle";
        PVAR(UiSwitchRadius) = 5;
        createDialog "Rsc_ZEIC_ObjectSwitch";
        _dlg = findDisplay 1701;
        ["Object Switch dialog opens", !isNull _dlg] call autotest_fnc_check;
        if (!isNull _dlg) then {
            private _expected = 3 + ([0, 2] select isClass (configFile >> "CfgPatches" >> "ZEIC_templates_cup")) + ([0, 2] select isClass (configFile >> "CfgPatches" >> "ZEIC_templates_sog"));
            private _combo = _dlg getVariable ["set_ctrl", controlNull];
            ["only sets of loaded mods listed", lbSize _combo == _expected, [lbSize _combo, _expected]] call autotest_fnc_check;
            ["last set preselected", (_dlg getVariable QPVAR(sets)) select (_dlg getVariable ["set", 0]) == "jungle"] call autotest_fnc_check;

            [_dlg] call PFUNC(ui_dialogConfirm);
            private _closed = [1701] call _fnc_waitClosed;
            sleep 0.1;
            private _switched = nearestObjects [PVAR(UiLastPosition), ["Land_BagFence_01_long_green_F"], 5];
            ["confirm switches at the module's position, not the mouse", _closed && {isNull _fence} && {_switched isNotEqualTo []}, [_closed, isNull _fence, count _switched]] call autotest_fnc_check;
        };

        // T18 List Buildings dialog (#26): only the dialog, listing all buildings takes long
        PVAR(UiListCategory) = 0;
        createDialog "Rsc_ZEIC_ListBuildings";
        _dlg = findDisplay 1703;
        ["List Buildings dialog opens", !isNull _dlg] call autotest_fnc_check;
        if (!isNull _dlg) then {
            private _combo = _dlg getVariable ["category_ctrl", controlNull];
            private _categoryCount = count (call PFUNC(interiorFill_categories));
            ["All plus one entry per config category", lbSize _combo == _categoryCount + 1, [lbSize _combo, _categoryCount]] call autotest_fnc_check;
            ["category classes behind the entries", (_dlg getVariable QPVAR(categories)) isEqualTo ([""] + ((call PFUNC(interiorFill_categories)) apply { _x select 1 }))] call autotest_fnc_check;
            _dlg closeDisplay 2;
        };
    }, 180]
]
