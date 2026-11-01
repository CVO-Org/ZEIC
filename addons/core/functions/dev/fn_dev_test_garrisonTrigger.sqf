#include "..\..\script_component.hpp"

/*
* Self test: the garrison "Move AI" trigger (#56): server only, fires once, randomized interval, its own group only,
* enemies only, releases everyone after its delay and deletes itself, deletes itself when the group is gone.
* The triggers are moved onto the player to activate them. Part of PFUNC(dev_selfTest), needs its scheduled environment.
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

// T22 garrison trigger (#56)
private _playerSide = side group player;
private _factionOfSide = { params ["_side"]; ["OPF_F", "BLU_F", "IND_F"] select ([east, west, independent] find _side) };
private _friendly = [[west, _playerSide] select (_playerSide in [east, west, independent])] call _factionOfSide;
private _enemySide = [east, west, independent] select { (_x getFriend _playerSide) < 0.6 } param [0, east];
private _enemy = [_enemySide] call _factionOfSide;

// Garrisons one building with the trigger option, returns [building, trigger, group]
private _fnc_garrison = {
	params ["_spot", "_faction"];
	private _bld = [DEV_HOUSE, _spot] call PFUNC(dev_spawn);
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
["T22.1 one trigger for the building, with its group", !isNull _trg && {count units _group > 0}, [_trg, units _group]] call PFUNC(dev_check);
if (isNull _trg) exitWith {};
["T22.2 fires once, interval 4-6 s, server only", !((triggerActivation _trg) select 2) && {triggerInterval _trg >= 4} && {triggerInterval _trg <= 6} && {local _trg},
	[triggerActivation _trg, triggerInterval _trg]] call PFUNC(dev_check);
private _held = (units _group) select { !(_x checkAIFeature "PATH") };
["T22.3 units are held in place", _held isNotEqualTo [], count _held] call PFUNC(dev_check);

// A unit of another group in the same area, also held: the trigger must leave it alone
private _otherGroup = createGroup [_enemySide, true];
private _other = _otherGroup createUnit [typeOf (units _group select 0), getPos _bld, [], 0, "CAN_COLLIDE"];
_other disableAI "PATH";

// The player comes close: the trigger activates. A short release delay instead of 30-120 s
_trg setVariable ["ZEIC_releaseDelay", 2];
_trg setPos getPos player;
private _activated = [{ isNull _trg || {triggerActivated _trg} }, 8] call _fnc_waitFor;
["T22.4 an enemy player activates it", _activated] call PFUNC(dev_check);

// After the delay everyone of the group may move, the other unit stays, the trigger is gone
private _gone = [{ isNull _trg }, 5] call _fnc_waitFor;
sleep 0.5;
["T22.5 after the delay the group may move and the trigger deletes itself", _gone && {(units _group) findIf { !(_x checkAIFeature "PATH") } == -1},
	[_gone, (units _group) select { !(_x checkAIFeature "PATH") }]] call PFUNC(dev_check);
["T22.6 a unit of another group in the area is left alone", !(_other checkAIFeature "PATH")] call PFUNC(dev_check);
deleteVehicle _other;

// Friendly garrison: the player doesn't activate it
([46, _friendly] call _fnc_garrison) params ["", "_friendlyTrg"];
if (!isNull _friendlyTrg) then {
	_friendlyTrg setPos getPos player;
	sleep 7;
	["T22.7 a friendly player doesn't activate it", !triggerActivated _friendlyTrg] call PFUNC(dev_check);
	deleteVehicle _friendlyTrg;
} else {
	["T22.7 a friendly player doesn't activate it", false, "no trigger"] call PFUNC(dev_check);
};

// Failsafe: all units gone, the trigger deletes itself
([47, _enemy] call _fnc_garrison) params ["", "_deadTrg", "_deadGroup"];
{ deleteVehicle _x } forEach units _deadGroup;
private _deleted = [{ isNull _deadTrg }, 8] call _fnc_waitFor;
["T22.8 group gone: the trigger deletes itself", _deleted] call PFUNC(dev_check);
