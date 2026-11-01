#include "..\..\script_component.hpp"

/*
* Self test: the collision check of Advanced Fill (#55, phase 2): the check itself (an object on a spot blocks it,
* one next to it or above it doesn't), check off (old behaviour), units give way (units only on free positions)
* and furniture gives way (the reserved positions stay free of objects, all units placed). 100 % of the positions,
* so every position of the house counts.
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
	params ["_spot", "_collision"];
	private _bld = [DEV_HOUSE, _spot] call PFUNC(dev_spawn);
	private _before = allSimpleObjects [];
	[[_bld], ["mil", [OBJECT_MODE_SIMPLE, false]], ["BLU_F", "EdSubcat_Personnel", [100, false, false]], _collision] call PFUNC(advancedFill_start);
	private _done = call _fnc_waitQueue;
	sleep 0.5;
	private _objects = ((allSimpleObjects []) - _before) select { (_x distance _bld) < 30 };
	private _blocked = [_bld buildingPos -1, _objects] call PFUNC(advancedFill_blockedPositions);
	[_bld, _objects, _blocked, [_bld, [_bld] call _fnc_units] call _fnc_unitPositions, _done]
};

// ---- the check: on the spot, next to it, above it
private _probeHouse = [DEV_HOUSE, 68] call PFUNC(dev_spawn);
private _spotPos = _probeHouse buildingPos 0;
private _probe = createSimpleObject ["Land_PaperBox_closed_F", AGLToASL _spotPos];
private _results = [];
{
	_probe setPosASL (AGLToASL (_spotPos vectorAdd _x));
	_results pushBack (([[_spotPos], [_probe]] call PFUNC(advancedFill_blockedPositions)) isNotEqualTo []);
} forEach [[0, 0, 0], [0.2, 0, 0], [1.5, 0, 0], [0, 0, 2.2]];
deleteVehicle _probe;
["T25.1 check: an object on or just beside the spot blocks it, one next to it or above it doesn't", _results isEqualTo [true, true, false, false], _results] call PFUNC(dev_check);

// ---- check off: units on all positions, wherever the objects are
([69, COLLISION_OFF] call _fnc_fill) params ["_offHouse", "_offObjects", "_offBlocked", "_offUnits", "_offDone"];
["T25.2 check off: furnished, a unit on every position (old behaviour)",
	_offDone && {_offObjects isNotEqualTo []} && {count _offUnits == count (_offHouse buildingPos -1)},
	[count _offObjects, count _offUnits, count (_offHouse buildingPos -1), "blocked", _offBlocked]] call PFUNC(dev_check);

// ---- units give way: no unit on a blocked position, all free ones taken (100 %)
([70, COLLISION_UNITS_GIVE_WAY] call _fnc_fill) params ["_unitsHouse", "_unitsObjects", "_unitsBlocked", "_unitsUnits", "_unitsDone"];
private _free = count (_unitsHouse buildingPos -1) - count _unitsBlocked;
["T25.3 units give way: units only on free positions",
	_unitsDone && {_unitsObjects isNotEqualTo []} && {_unitsUnits findIf { _x == -1 || {_x in _unitsBlocked} } == -1},
	[_unitsUnits, "blocked", _unitsBlocked]] call PFUNC(dev_check);
["T25.4 units give way: every free position taken", count _unitsUnits == _free && {count (_unitsUnits arrayIntersect _unitsUnits) == _free}, [count _unitsUnits, _free]] call PFUNC(dev_check);
["T25.5 free positions are not left on the house", isNil { _unitsHouse getVariable QPVAR(freePositions) }] call PFUNC(dev_check);

// ---- furniture gives way: all positions reserved (100 %), no object blocks any of them, a unit on each
([71, COLLISION_FURNITURE_GIVES_WAY] call _fnc_fill) params ["_furnHouse", "_furnObjects", "_furnBlocked", "_furnUnits", "_furnDone"];
["T25.6 furniture gives way: furnished, no object on a reserved position",
	_furnDone && {_furnObjects isNotEqualTo []} && {_furnBlocked isEqualTo []},
	[count _furnObjects, "blocked", _furnBlocked]] call PFUNC(dev_check);
["T25.7 furniture gives way: a unit on every position",
	count _furnUnits == count (_furnHouse buildingPos -1) && {_furnUnits findIf { _x == -1 } == -1},
	[_furnUnits, count (_furnHouse buildingPos -1)]] call PFUNC(dev_check);

// ---- the dialog remembers the settings for Alt
PVAR(UiLastBuilding) = _probeHouse;
PVAR(UiAdvancedFill) = createHashMapFromArray [["collision", true], ["blocked", COLLISION_FURNITURE_GIVES_WAY]];
createDialog "Rsc_ZEIC_AdvancedFill";
private _dlg = findDisplay 1706;
private _shown = [_dlg getVariable ["collision", false], _dlg getVariable ["blocked", -1], lbCurSel (_dlg getVariable ["blocked_ctrl", controlNull])];
if (!isNull _dlg) then { _dlg closeDisplay 2 };
["T25.8 dialog starts with the last collision settings", _shown isEqualTo [true, COLLISION_FURNITURE_GIVES_WAY, COLLISION_FURNITURE_GIVES_WAY], _shown] call PFUNC(dev_check);
PVAR(UiAdvancedFill) = nil;
