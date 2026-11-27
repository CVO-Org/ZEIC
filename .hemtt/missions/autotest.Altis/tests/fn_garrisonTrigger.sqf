#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* the garrison "Move AI" trigger (#56): server only, fires once, randomized interval, its own group only, enemies
* only, releases everyone after its delay and deletes itself, deletes itself when the group is gone. The triggers are
* moved onto the player to activate them.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["garrisonTrigger"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The garrison 'Move AI' trigger (#56)", {
        params ["_ctx"];

        // T23 garrison trigger (#56)
        private _playerSide = side group player;
        private _factionOfSide = { params ["_side"]; ["OPF_F", "BLU_F", "IND_F"] select ([east, west, independent] find _side) };
        private _friendly = [[west, _playerSide] select (_playerSide in [east, west, independent])] call _factionOfSide;
        private _enemySide = [east, west, independent] select { (_x getFriend _playerSide) < 0.6 } param [0, east];
        private _enemy = [_enemySide] call _factionOfSide;

        // Garrisons one building with the trigger option, returns [building, trigger, group]
        private _fnc_garrison = {
            params ["_spot", "_faction"];
            private _bld = [DEV_HOUSE, _spot] call autotest_helper_fnc_spawn;
            [[_bld], _faction, "EdSubcat_Personnel", [100, false, true]] call PFUNC(garrisonBuilding_start);
            private _timeout = diag_tickTime + 30;
            waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };
            sleep 0.5;
            private _trg = (allMissionObjects "EmptyDetector") select {
                private _group = _x getVariable ["ZEIC_group", grpNull];
                !isNull _group && {(leader _group) distance2D _bld < 30}
            };
            _trg = _trg param [0, objNull];
            [_bld, _trg, _trg getVariable ["ZEIC_group", grpNull]]
        };

        // Waits until the code returns true or the time is up, returns the last result
        private _fnc_waitFor = {
            params ["_code", "_seconds"];
            private _timeout = diag_tickTime + _seconds;
            waitUntil { sleep 0.25; (call _code) || {diag_tickTime > _timeout} };
            call _code
        };

        // Enemy garrison
        ([45, _enemy] call _fnc_garrison) params ["_bld", "_trg", "_group"];
        ["one trigger for the building, with its group", !isNull _trg && {units _group isNotEqualTo []}, [_trg, units _group]] call autotest_fnc_check;
        if (isNull _trg) exitWith {};
        ["fires once, interval 4-6 s, server only", !((triggerActivation _trg) select 2) && {triggerInterval _trg >= 4} && {triggerInterval _trg <= 6} && {local _trg},
            [triggerActivation _trg, triggerInterval _trg]] call autotest_fnc_check;
        private _held = (units _group) select { !(_x checkAIFeature "PATH") };
        ["units are held in place", _held isNotEqualTo [], count _held] call autotest_fnc_check;

        // A unit of another group in the same area, also held: the trigger must leave it alone
        private _otherGroup = createGroup [_enemySide, true];
        private _other = _otherGroup createUnit [typeOf (units _group select 0), getPos _bld, [], 0, "CAN_COLLIDE"];
        _other disableAI "PATH";

        // The player comes close: the trigger activates. A short release delay instead of 30-120 s
        _trg setVariable ["ZEIC_releaseDelay", 2];
        _trg setPos getPos player;
        private _activated = [{ isNull _trg || {triggerActivated _trg} }, 8] call _fnc_waitFor;
        ["an enemy player activates it", _activated] call autotest_fnc_check;

        // After the delay everyone of the group may move, the other unit stays, the trigger is gone
        private _gone = [{ isNull _trg }, 5] call _fnc_waitFor;
        sleep 0.5;
        ["after the delay the group may move and the trigger deletes itself", _gone && {(units _group) findIf { !(_x checkAIFeature "PATH") } == -1},
            [_gone, (units _group) select { !(_x checkAIFeature "PATH") }]] call autotest_fnc_check;
        ["a unit of another group in the area is left alone", !(_other checkAIFeature "PATH")] call autotest_fnc_check;
        deleteVehicle _other;

        // Friendly garrison: the player doesn't activate it
        ([46, _friendly] call _fnc_garrison) params ["", "_friendlyTrg"];
        if (!isNull _friendlyTrg) then {
            _friendlyTrg setPos getPos player;
            sleep 7;
            ["a friendly player doesn't activate it", !triggerActivated _friendlyTrg] call autotest_fnc_check;
            deleteVehicle _friendlyTrg;
        } else {
            ["a friendly player doesn't activate it", false, "no trigger"] call autotest_fnc_check;
        };

        // Failsafe: all units gone, the trigger deletes itself
        ([47, _enemy] call _fnc_garrison) params ["", "_deadTrg", "_deadGroup"];
        { deleteVehicle _x } forEach units _deadGroup;
        private _deleted = [{ isNull _deadTrg }, 8] call _fnc_waitFor;
        ["group gone: the trigger deletes itself", _deleted] call autotest_fnc_check;
    }, 180]
]
