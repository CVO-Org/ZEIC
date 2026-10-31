#include "..\..\script_component.hpp"

/*
* Self test: createTemplate spawns objects and marks the building as furnished.
* Part of PFUNC(dev_selfTest), needs its scheduled environment.
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

private _houseClass = DEV_HOUSE;

// T7 createTemplate actually spawns (#29, #30)
ZEIC_mil_customBuildings = nil;
ZEIC_civ_customBuildings = nil;
ZEIC_cbrn_customBuildings = nil;

private _house2 = [_houseClass, 10] call PFUNC(dev_spawn);
private _simpleBefore = count allSimpleObjects [];
[_house2, "civ", false, false, false, 1] call PFUNC(createTemplate);
private _simpleSpawned = (count allSimpleObjects []) - _simpleBefore;
["T7.1 simple-object fill spawns objects", _simpleSpawned > 0, _simpleSpawned] call PFUNC(dev_check);
["T7.2 building marked as furnished", !isNull (_house2 getVariable ["ZEIC_furnished", objNull])] call PFUNC(dev_check);

private _house3 = [_houseClass, 11] call PFUNC(dev_spawn);
private _nearBefore = count nearestObjects [_house3, [], 25];
[_house3, "mil", false, true, false, 1] call PFUNC(createTemplate);
sleep 1;
private _nearSpawned = (count nearestObjects [_house3, [], 25]) - _nearBefore;
["T7.3 editable-object fill spawns objects", _nearSpawned > 0, _nearSpawned] call PFUNC(dev_check);

private _again = count allSimpleObjects [];
[_house2, "civ", false, false, false, 1] call PFUNC(createTemplate);
["T7.4 furnished building is not filled twice", (count allSimpleObjects []) == _again] call PFUNC(dev_check);
