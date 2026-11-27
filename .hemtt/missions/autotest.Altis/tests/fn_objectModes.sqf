#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* The three object modes of Interior Fill (simple, normal, editable).
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["objectModes"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The three object modes of Interior Fill", {
        params ["_ctx"];

        private _houseClass = DEV_HOUSE;

        // T9 object modes (#22)
        {
            _x params ["_mode", "_name", "_expectSimple"];
            private _bld = [_houseClass, 30 + _mode] call autotest_helper_fnc_spawn;
            isNil { [[_bld], "mil", [_mode, false, 1]] call PFUNC(interiorFill_start) };

            private _timeout = diag_tickTime + 15;
            waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };

            private _obj = _bld getVariable ["ZEIC_furnished", objNull];
            [format ["mode %1 (%2) spawns %3", _mode, _name, ["normal objects", "simple objects"] select _expectSimple],
                !isNull _obj && {isSimpleObject _obj isEqualTo _expectSimple}, [_obj, isSimpleObject _obj]] call autotest_fnc_check;

            if (_mode == 2) then {
                if (allCurators isEqualTo []) then {
                    diag_log text "[ZEIC TEST] SKIP T9.2b no curator in the mission";
                } else {
                    ["editable objects are added to the curator", _obj in curatorEditableObjects (allCurators select 0)] call autotest_fnc_check;
                };
            } else {
                if (allCurators isNotEqualTo []) then {
                    [format ["mode %1: objects are not added to the curator", _mode], !(_obj in curatorEditableObjects (allCurators select 0))] call autotest_fnc_check;
                };
            };
        } forEach [
            [0, "simple", true],
            [1, "objects", false],
            [2, "editable in Zeus", false]
        ];
    }, 180]
]
