#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* Garrison through the queue, and the area selection.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["garrison"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["Garrison through the queue, and the area selection", {
        params ["_ctx"];

        private _houseClass = DEV_HOUSE;

        // T10 garrison through the queue + area selection (#23)
        private _gCenter = PVAR(dev_origin) vectorAdd [0, 900, 0];
        private _gHouses = [];
        for "_i" from 0 to 3 do { _gHouses pushBack (createVehicle [_houseClass, _gCenter vectorAdd [_i * 25, 0, 0], [], 0, "CAN_COLLIDE"]) };
        private _gMid = _gCenter vectorAdd [37.5, 0, 0];

        private _picked = [_gMid, 60, 50] call PFUNC(garrisonBuilding_selectBuildings);
        ["50% of 4 buildings selected", count _picked == 2, count _picked] call autotest_fnc_check;
        _picked = [_gMid, 60, 100] call PFUNC(garrisonBuilding_selectBuildings);
        ["100% selects all 4", count _picked == 4, count _picked] call autotest_fnc_check;

        private _unitTypes = ["BLU_F", "EdSubcat_Personnel"] call PFUNC(garrisonBuilding_unitTypes);
        ["NATO infantry found", _unitTypes isNotEqualTo [], count _unitTypes] call autotest_fnc_check;

        private _expectedUnits = 0;
        // All the same house: nothing is capped, half the positions each (at least 1)
        { _expectedUnits = _expectedUnits + (1 max round ((count (_x buildingPos -1)) / 2)) } forEach _gHouses;

        ZEIC_queueBudget = 0;
        private _gFrameStart = diag_frameNo;
        private _gQueued = false;
        isNil {
            [_gHouses, "BLU_F", "EdSubcat_Personnel", [50, false, false]] call PFUNC(garrisonBuilding_start);
            _gQueued = (missionNamespace getVariable ["ZEIC_queue", []]) isNotEqualTo [];
        };
        ["garrison is queued", _gQueued] call autotest_fnc_check;

        private _gTimeout = diag_tickTime + 30;
        waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _gTimeout} };
        ZEIC_queueBudget = nil;
        private _gFrames = diag_frameNo - _gFrameStart;

        private _gUnits = (_gMid nearEntities ["CAManBase", 80]) select { side group _x == west };
        private _gGroups = _gUnits apply { group _x };
        _gGroups = _gGroups arrayIntersect _gGroups;
        ["50% of the positions per building", count _gUnits == _expectedUnits, [count _gUnits, _expectedUnits]] call autotest_fnc_check;
        ["one group per building", count _gGroups == 4, count _gGroups] call autotest_fnc_check;
        ["spread over several frames", _gFrames > 8, _gFrames] call autotest_fnc_check;
        ["garrisoned buildings are not picked again", ([_gMid, 60, 100] call PFUNC(garrisonBuilding_selectBuildings)) isEqualTo []] call autotest_fnc_check;

        if (allCurators isNotEqualTo []) then {
            private _editable = curatorEditableObjects (allCurators select 0);
            ["units are editable in Zeus", (_gUnits findIf { !(_x in _editable) }) == -1] call autotest_fnc_check;
        } else {
            diag_log text "[ZEIC TEST] SKIP T10.9 no curator in the mission";
        };
    }, 180]
]
