#include "..\..\script_component.hpp"

/*
* Self test: the queue processes buildings in rows, north to south, east to west within a row.
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

// T13 queue processes buildings in rows: north to south, east to west
// Rows are 25 m bands of the map; both test areas start on a band edge, so +1012 and +1062 sit
// inside different bands. The houses are created in scrambled order.
private _rowHouses = createHashMap;
{
	_x params ["_name", "_offset"];
	_rowHouses set [_name, createVehicle [_houseClass, PVAR(dev_origin) vectorAdd _offset, [], 0, "CAN_COLLIDE"]];
} forEach [
	["SW", [600, 1012, 0]], ["NE", [680, 1062, 0]], ["SE", [680, 1012, 0]],
	["NW", [600, 1062, 0]], ["NC", [640, 1062, 0]], ["SC", [640, 1012, 0]]
];
private _expectedOrder = ["NE", "NC", "NW", "SE", "SC", "SW"] apply { _rowHouses get _x };
private _sorted = [values _rowHouses] call PFUNC(queue_sortBuildings);
["T13.1 sorted north to south, east to west", _sorted isEqualTo _expectedOrder, _sorted apply { getPosWorld _x apply { round _x } }] call PFUNC(dev_check);

private _jobOrder = [];
isNil {
	[values _rowHouses, "mil", [0, false]] call PFUNC(interiorFill_start);
	private _job = (missionNamespace getVariable ["ZEIC_queue", []]) select -1;
	_jobOrder = _job getOrDefault ["buildings", []];
};
["T13.2 Interior Fill queue uses that order", _jobOrder isEqualTo _expectedOrder] call PFUNC(dev_check);

private _rowTimeout = diag_tickTime + 30;
waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _rowTimeout} };
