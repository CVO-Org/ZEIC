#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* Interior Fill through the processing queue, with the wireframe feedback.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["queue"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["Interior Fill through the processing queue, with the wireframe feedback", {
        params ["_ctx"];

        private _houseClass = DEV_HOUSE;

        // T8 processing queue + feedback (#22)
        private _queueHouses = [];
        for "_i" from 0 to 4 do { _queueHouses pushBack ([_houseClass, 20 + _i] call autotest_helper_fnc_spawn) };
        private _noTemplate = ["Land_WoodenCrate_01_F", 25] call autotest_helper_fnc_spawn;

        // Budget 0 = exactly one step per frame, so the fill must take many frames
        ZEIC_queueBudget = 0;

        // Start unscheduled, so nothing can run in between
        private _queuedRightAway = false;
        private _frameStart = diag_frameNo;
        isNil {
            [_queueHouses + [_noTemplate], "mil", [false, false, 1]] call PFUNC(interiorFill_start);
            _queuedRightAway = (missionNamespace getVariable ["ZEIC_queue", []]) isNotEqualTo []
                && {isNull ((_queueHouses select 0) getVariable ["ZEIC_furnished", objNull])};
        };
        ["fill is queued, not done in the same frame", _queuedRightAway] call autotest_fnc_check;

        private _timeout = diag_tickTime + 30;
        waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };
        private _frames = diag_frameNo - _frameStart;
        ZEIC_queueBudget = nil;

        ["queue finished within 30 s", (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo []] call autotest_fnc_check;
        private _furnishedCount = { !isNull (_x getVariable ["ZEIC_furnished", objNull]) } count _queueHouses;
        ["all 5 houses furnished", _furnishedCount == 5, _furnishedCount] call autotest_fnc_check;
        ["spread over many frames (one step each)", _frames > 20, _frames] call autotest_fnc_check;
        ["queue event handler removed when empty", isNil "ZEIC_queueEH"] call autotest_fnc_check;

        private _colorOf = {
            params ["_bld"];
            private _index = _bld getVariable ["ZEIC_feedbackIndex", -1];
            if (_index == -1) exitWith { [] };
            (missionNamespace getVariable ["ZEIC_feedback", []]) select _index select 2
        };
        private _houseColors = _queueHouses apply { [_x] call _colorOf };
        ["furnished houses shown green", (_houseColors findIf { _x isNotEqualTo [0,1,0,1] }) == -1, _houseColors] call autotest_fnc_check;
        ["building without template shown red", ([_noTemplate] call _colorOf) isEqualTo [1,0,0,1], [_noTemplate] call _colorOf] call autotest_fnc_check;
        ["no-template building not marked as queued", !(_noTemplate getVariable ["ZEIC_queued", false])] call autotest_fnc_check;

        sleep 6;
        ["wireframes cleared after the fill", (missionNamespace getVariable ["ZEIC_feedback", []]) isEqualTo [] && {isNil "ZEIC_feedbackEH"}] call autotest_fnc_check;

        private _simpleBeforeRefill = count allSimpleObjects [];
        [_queueHouses, "mil", [false, false, 1]] call PFUNC(interiorFill_start);
        sleep 1;
        ["furnished houses are not filled again", (count allSimpleObjects []) == _simpleBeforeRefill] call autotest_fnc_check;
    }, 180]
]
