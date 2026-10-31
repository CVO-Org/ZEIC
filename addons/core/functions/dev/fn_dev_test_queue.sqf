#include "..\..\script_component.hpp"

/*
* Self test: Interior Fill through the processing queue, with the wireframe feedback.
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

// T8 processing queue + feedback (#22)
private _queueHouses = [];
for "_i" from 0 to 4 do { _queueHouses pushBack ([_houseClass, 20 + _i] call PFUNC(dev_spawn)) };
private _noTemplate = ["Land_WoodenCrate_01_F", 25] call PFUNC(dev_spawn);

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
["T8.1 fill is queued, not done in the same frame", _queuedRightAway] call PFUNC(dev_check);

private _timeout = diag_tickTime + 30;
waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };
private _frames = diag_frameNo - _frameStart;
ZEIC_queueBudget = nil;

["T8.2 queue finished within 30 s", (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo []] call PFUNC(dev_check);
private _furnishedCount = { !isNull (_x getVariable ["ZEIC_furnished", objNull]) } count _queueHouses;
["T8.3 all 5 houses furnished", _furnishedCount == 5, _furnishedCount] call PFUNC(dev_check);
["T8.4 spread over many frames (one step each)", _frames > 20, _frames] call PFUNC(dev_check);
["T8.5 queue event handler removed when empty", isNil "ZEIC_queueEH"] call PFUNC(dev_check);

private _colorOf = {
	params ["_bld"];
	private _index = _bld getVariable ["ZEIC_feedbackIndex", -1];
	if (_index == -1) exitWith { [] };
	(missionNamespace getVariable ["ZEIC_feedback", []]) select _index select 2
};
private _houseColors = _queueHouses apply { [_x] call _colorOf };
["T8.6 furnished houses shown green", (_houseColors findIf { _x isNotEqualTo [0,1,0,1] }) == -1, _houseColors] call PFUNC(dev_check);
["T8.7 building without template shown red", ([_noTemplate] call _colorOf) isEqualTo [1,0,0,1], [_noTemplate] call _colorOf] call PFUNC(dev_check);
["T8.8 no-template building not marked as queued", !(_noTemplate getVariable ["ZEIC_queued", false])] call PFUNC(dev_check);

sleep 6;
["T8.9 wireframes cleared after the fill", (missionNamespace getVariable ["ZEIC_feedback", []]) isEqualTo [] && {isNil "ZEIC_feedbackEH"}] call PFUNC(dev_check);

private _simpleBeforeRefill = count allSimpleObjects [];
[_queueHouses, "mil", [false, false, 1]] call PFUNC(interiorFill_start);
sleep 1;
["T8.10 furnished houses are not filled again", (count allSimpleObjects []) == _simpleBeforeRefill] call PFUNC(dev_check);
