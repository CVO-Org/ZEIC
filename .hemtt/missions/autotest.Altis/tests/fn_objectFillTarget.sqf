#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* the target the Object Fill module picks (#66).
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["objectFillTarget"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The target the Object Fill module picks (#66)", {
        params ["_ctx"];

        private _fnc_place = {
            params ["_pos"];
            private _logic = (createGroup sideLogic) createUnit ["Logic", _pos, [], 0, "CAN_COLLIDE"];
            _logic setPosATL _pos;
            ["init", [_logic, true, true]] call PFUNC(mod_objectFill);
            sleep 0.2;
            findDisplay 1704
        };

        // T28.1 nothing around: no dialog, the target of an earlier placement is gone
        private _old = ["Land_TablePlastic_01_F", 89] call autotest_helper_fnc_spawn;
        PVAR(UiLastObject) = _old;
        private _empty = PVAR(dev_origin) vectorAdd [150 * (90 mod 8), 150 * floor (90 / 8), 0];
        private _dlg = [_empty] call _fnc_place;
        ["nothing around: no dialog, no stale target", isNull _dlg && {isNull PVAR(UiLastObject)}, [isNull _dlg, PVAR(UiLastObject)]] call autotest_fnc_check;
        if (!isNull _dlg) then { _dlg closeDisplay 2 };

        // T28.2 dialog opened without a target closes itself
        PVAR(UiLastObject) = objNull;
        createDialog "Rsc_ZEIC_ObjectFill";
        sleep 0.2;
        ["dialog without a target closes", isNull findDisplay 1704] call autotest_fnc_check;

        // T28.3 next to a table: dialog with its name in the title
        _dlg = [getPosATL _old vectorAdd [1, 0, 0]] call _fnc_place;
        private _title = (allControls _dlg) findIf { ctrlClassName _x == QPVAR(ctrlTitle) };
        _title = if (_title < 0) then { "" } else { ctrlText ((allControls _dlg) select _title) };
        private _name = getText (configOf _old >> "displayName");
        ["next to a table: dialog shows its name", !isNull _dlg && {PVAR(UiLastObject) isEqualTo _old} && {_name != ""} && {(_title find _name) >= 0}, [_title, _name]] call autotest_fnc_check;
        if (!isNull _dlg) then { _dlg closeDisplay 2 };
    }, 180]
]
