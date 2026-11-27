#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* the collision check of Advanced Fill (#55, phase 2): the check itself (an object on a spot blocks it, one next to it
* or above it doesn't), check off (old behaviour), units give way (units only on free positions) and furniture gives
* way (the reserved positions stay free of objects, all units placed). 100 % of the positions, so every position of
* the house counts. First with a real template, then with a test template that puts a box exactly on the house's first
* position (the real one may not block any).
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["advancedFillCollision"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The collision check of Advanced Fill (#55, phase 2)", {
        params ["_ctx"];

        // T25 Advanced Fill collision check (#55)
        private _fnc_waitQueue = {
            private _timeout = diag_tickTime + 60;
            waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };
            (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo []
        };
        private _fnc_units = { params ["_bld"]; (_bld nearEntities ["CAManBase", 30]) select { !isPlayer _x } };
        // Index of the building position each unit stands on (-1: none within 1 m)
        private _fnc_unitPositions = {
            params ["_bld", "_units"];
            private _positions = _bld buildingPos -1;
            _units apply {
                private _unitPos = getPosATL _x;
                _positions findIf { (_x distance _unitPos) < 1 }
            }
        };
        // Fills one house (interior + garrison) with the given collision check and returns
        // [house, its fill objects, the positions they block, the positions the units stand on, done]
        private _fnc_fill = {
            params ["_spot", "_collision", ["_category", "mil"]];
            private _bld = [DEV_HOUSE, _spot] call autotest_helper_fnc_spawn;
            private _before = allSimpleObjects [];
            [[_bld], [_category, [OBJECT_MODE_SIMPLE, false]], ["BLU_F", "EdSubcat_Personnel", [100, false, false]], _collision] call PFUNC(advancedFill_start);
            private _done = call _fnc_waitQueue;
            sleep 0.5;
            private _objects = ((allSimpleObjects []) - _before) select { (_x distance _bld) < 30 };
            private _blocked = [_bld buildingPos -1, _objects] call PFUNC(advancedFill_blockedPositions);
            [_bld, _objects, _blocked, [_bld, [_bld] call _fnc_units] call _fnc_unitPositions, _done]
        };

        // ---- the check: on the spot, next to it, above it
        private _probeHouse = [DEV_HOUSE, 68] call autotest_helper_fnc_spawn;
        private _spotPos = _probeHouse buildingPos 0;
        private _probe = createSimpleObject ["Land_PaperBox_closed_F", AGLToASL _spotPos];
        private _results = [];
        {
            _probe setPosASL (AGLToASL (_spotPos vectorAdd _x));
            _results pushBack (([[_spotPos], [_probe]] call PFUNC(advancedFill_blockedPositions)) isNotEqualTo []);
        } forEach [[0, 0, 0], [0.2, 0, 0], [2, 0, 0], [0, 0, 2.2]];
        deleteVehicle _probe;
        ["check: an object on or just beside the spot blocks it, one next to it or above it doesn't", _results isEqualTo [true, true, false, false], _results] call autotest_fnc_check;

        // ---- check off: units on all positions, wherever the objects are
        ([69, COLLISION_OFF] call _fnc_fill) params ["_offHouse", "_offObjects", "_offBlocked", "_offUnits", "_offDone"];
        ["check off: furnished, a unit on every position (old behaviour)",
            _offDone && {_offObjects isNotEqualTo []} && {count _offUnits == count (_offHouse buildingPos -1)},
            [count _offObjects, count _offUnits, count (_offHouse buildingPos -1), "blocked", _offBlocked]] call autotest_fnc_check;

        // ---- units give way: no unit on a blocked position, all free ones taken (100 %)
        ([70, COLLISION_UNITS_GIVE_WAY] call _fnc_fill) params ["_unitsHouse", "_unitsObjects", "_unitsBlocked", "_unitsUnits", "_unitsDone"];
        private _free = count (_unitsHouse buildingPos -1) - count _unitsBlocked;
        ["units give way: units only on free positions",
            _unitsDone && {_unitsObjects isNotEqualTo []} && {_unitsUnits findIf { _x == -1 || {_x in _unitsBlocked} } == -1},
            [_unitsUnits, "blocked", _unitsBlocked]] call autotest_fnc_check;
        ["units give way: every free position taken", count _unitsUnits == _free && {count (_unitsUnits arrayIntersect _unitsUnits) == _free}, [count _unitsUnits, _free]] call autotest_fnc_check;
        ["free positions are not left on the house", isNil { _unitsHouse getVariable QPVAR(freePositions) }] call autotest_fnc_check;

        // ---- furniture gives way: all positions reserved (100 %), no object blocks any of them, a unit on each
        ([71, COLLISION_FURNITURE_GIVES_WAY] call _fnc_fill) params ["_furnHouse", "_furnObjects", "_furnBlocked", "_furnUnits", "_furnDone"];
        ["furniture gives way: furnished, no object on a reserved position",
            _furnDone && {_furnObjects isNotEqualTo []} && {_furnBlocked isEqualTo []},
            [count _furnObjects, "blocked", _furnBlocked]] call autotest_fnc_check;
        ["furniture gives way: a unit on every position",
            count _furnUnits == count (_furnHouse buildingPos -1) && {_furnUnits findIf { _x == -1 } == -1},
            [_furnUnits, count (_furnHouse buildingPos -1)]] call autotest_fnc_check;

        // ---- test template: a box on the first position, another one outside the house (blocks nothing)
        private _offset = _probeHouse worldToModel (_probeHouse buildingPos 0);
        ["zeictest", [DEV_HOUSE, [["Land_PaperBox_closed_F", _offset, 0], ["Land_PaperBox_closed_F", [12, 12, 0], 0]]]] call PFUNC(addCustomTemplate);
        private _count = count (_probeHouse buildingPos -1);

        ([72, COLLISION_OFF, "zeictest"] call _fnc_fill) params ["", "_offObjects", "_offBlocked", "_offUnits"];
        ["test template, check off: the box blocks position 0, still a unit there",
            count _offObjects == 2 && {0 in _offBlocked} && {0 in _offUnits} && {count _offUnits == _count},
            [count _offObjects, _offBlocked, _offUnits]] call autotest_fnc_check;

        ([73, COLLISION_UNITS_GIVE_WAY, "zeictest"] call _fnc_fill) params ["", "_unitsObjects", "_unitsBlocked", "_unitsUnits"];
        ["test template, units give way: both boxes, no unit on a blocked position (incl. 0), the others taken",
            count _unitsObjects == 2 && {0 in _unitsBlocked} && {_unitsUnits findIf { _x == -1 || {_x in _unitsBlocked} } == -1} && {count (_unitsUnits arrayIntersect _unitsUnits) == _count - count _unitsBlocked},
            [count _unitsObjects, _unitsBlocked, _unitsUnits]] call autotest_fnc_check;

        ([74, COLLISION_FURNITURE_GIVES_WAY, "zeictest"] call _fnc_fill) params ["", "_furnObjects", "_furnBlocked", "_furnUnits"];
        ["test template, furniture gives way: the box on position 0 left out, a unit on every position",
            count _furnObjects == 1 && {_furnBlocked isEqualTo []} && {count (_furnUnits arrayIntersect _furnUnits) == _count} && {_furnUnits findIf { _x == -1 } == -1},
            [count _furnObjects, _furnBlocked, _furnUnits]] call autotest_fnc_check;
        ZEIC_zeictest_customBuildings = nil;

        // ---- spacing: positions almost on top of each other get one unit
        private _spread = [[[0, 0, 0], [0.5, 0, 0], [2, 0, 0], [2, 0, 3]], [1, 0, 2, 3], 4] call PFUNC(garrisonBuilding_spreadPositions);
        private _limited = [[[0, 0, 0], [2, 0, 0], [4, 0, 0]], [2, 1, 0], 2] call PFUNC(garrisonBuilding_spreadPositions);
        ["spacing: a position within 0.8 m of a taken one is skipped, in order, up to the count",
            _spread isEqualTo [1, 2, 3] && {_limited isEqualTo [2, 1]}, [_spread, _limited]] call autotest_fnc_check;

        // ---- the dialog remembers the settings for Alt
        PVAR(UiLastBuilding) = _probeHouse;
        PVAR(UiAdvancedFill) = createHashMapFromArray [["collision", true], ["blocked", COLLISION_FURNITURE_GIVES_WAY]];
        createDialog "Rsc_ZEIC_AdvancedFill";
        private _dlg = findDisplay 1706;
        private _shown = [_dlg getVariable ["collision", false], _dlg getVariable ["blocked", -1], lbCurSel (_dlg getVariable ["blocked_ctrl", controlNull])];
        if (!isNull _dlg) then { _dlg closeDisplay 2 };
        ["dialog starts with the last collision settings", _shown isEqualTo [true, COLLISION_FURNITURE_GIVES_WAY, COLLISION_FURNITURE_GIVES_WAY], _shown] call autotest_fnc_check;
        PVAR(UiAdvancedFill) = nil;
    }, 180]
]
