#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* the prompt before a garrison creates more than GARRISON_CONFIRM_UNITS units
* (PFUNC(ui_garrisonBuilding_confirmUnits)): nothing below the limit, above it "Yes" runs the fill, "Back" reopens the
* dialog.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["confirmUnits"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The prompt before a garrison creates more than GARRISON_CONFIRM_UNITS units", {
        params ["_ctx"];

        // T26 Confirm many units
        private _fnc_waitFor = {
            params ["_condition", "_seconds"];
            private _timeout = diag_tickTime + _seconds;
            waitUntil { sleep 0.05; call _condition || {diag_tickTime > _timeout} };
            call _condition
        };

        private _bld = [DEV_HOUSE, 75] call autotest_helper_fnc_spawn;
        private _positions = count (_bld buildingPos -1);
        PVAR(UiLastBuilding) = _bld;
        // The same house many times: 100 % of its positions, just over the limit
        private _many = [];
        for "_i" from 1 to (floor (GARRISON_CONFIRM_UNITS / _positions) + 1) do { _many pushBack _bld };
        PVAR(dev_confirmed) = nil;
        private _args = [_bld, "Rsc_ZEIC_AdvancedFill"];
        private _fnc_ask = { [_this, 100, "Test", { PVAR(dev_confirmed) = _this }, _args, "Rsc_ZEIC_AdvancedFill"] call PFUNC(ui_garrisonBuilding_confirmUnits) };

        private _asked = [_bld] call _fnc_ask;
        sleep 0.2;
        ["below the limit: no prompt", !_asked && {isNull findDisplay 1707}] call autotest_fnc_check;

        _asked = _many call _fnc_ask;
        private _shown = [{ !isNull findDisplay 1707 }, 2] call _fnc_waitFor;
        ["above the limit: the prompt opens", _asked && {_shown}, [count _many * _positions]] call autotest_fnc_check;
        [findDisplay 1707] call PFUNC(ui_dialogConfirm);
        private _closed = [{ isNull findDisplay 1707 }, 1] call _fnc_waitFor;
        sleep 0.2;
        ["Yes runs the fill with its arguments, no dialog reopened", _closed && {(missionNamespace getVariable [QPVAR(dev_confirmed), []]) isEqualTo _args} && {isNull findDisplay 1706},
            [_closed, missionNamespace getVariable [QPVAR(dev_confirmed), []]]] call autotest_fnc_check;

        PVAR(dev_confirmed) = nil;
        _many call _fnc_ask;
        [{ !isNull findDisplay 1707 }, 2] call _fnc_waitFor;
        (findDisplay 1707) closeDisplay 2;
        private _reopened = [{ !isNull findDisplay 1706 }, 2] call _fnc_waitFor;
        ["Back reopens the module's dialog, nothing created", _reopened && {isNil QPVAR(dev_confirmed)} && {isNull findDisplay 1707}] call autotest_fnc_check;
        if (!isNull findDisplay 1706) then { (findDisplay 1706) closeDisplay 2 };
        PVAR(dev_confirmed) = nil;
    }, 180]
]
