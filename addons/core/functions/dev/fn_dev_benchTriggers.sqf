#include "..\..\script_component.hpp"

/*
* Benchmark for the garrison "Move AI" triggers (#56): frame time with many triggers like the ones
* Garrison Building creates (40 m circle, 15 m high, any player present). The triggers are placed on a 30 m
* grid around the player, so the player stands inside many of them, like in a garrisoned town.
* Each run waits 2 s, then samples 15 s of frames: average and longest frame, and the share of frames over 25 ms.
* Statements are empty, only the checks are measured. Results go to the RPT, prefixed with [ZEIC BENCH].
*
* Run by hand from the debug console (stand still in a town, don't touch anything for ~3 minutes):
*   [] spawn ZEIC_fnc_dev_benchTriggers;
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

if (!canSuspend) exitWith { [] spawn PFUNC(dev_benchTriggers) };

private _center = getPosATL player;
private _enemyCondition = "this && {thisList findIf { ((side group _x) getFriend east) < 0.6 } != -1}";

// [label, trigger count, randomized interval, condition]
private _runs = [
	["baseline", 0, false, "this"],
	["fixed 5 s", 100, false, "this"],
	["random 4-6 s", 100, true, "this"],
	["fixed 5 s", 300, false, "this"],
	["random 4-6 s", 300, true, "this"],
	["fixed 5 s", 1000, false, "this"],
	["random 4-6 s", 1000, true, "this"],
	["random 4-6 s, enemy check", 1000, true, _enemyCondition],
	["baseline", 0, false, "this"]
];

diag_log text format ["[ZEIC BENCH] ===== start | %1 at %2 | %3 runs of 15 s =====", worldName, _center, count _runs];

{
	_x params ["_label", "_count", "_random", "_condition"];

	// A square grid, 30 m apart, centered on the player
	private _side = ceil sqrt _count;
	private _triggers = [];
	for "_i" from 0 to (_count - 1) do {
		private _pos = _center vectorAdd [((_i mod _side) - _side / 2) * 30, ((floor (_i / _side)) - _side / 2) * 30, 0];
		private _trg = createTrigger ["EmptyDetector", _pos, false];
		_trg setTriggerArea [40, 40, 0, false, 15];
		_trg setTriggerActivation ["ANYPLAYER", "PRESENT", false];
		_trg setTriggerInterval ([5, 4 + random 2] select _random);
		_trg setTriggerStatements [_condition, "", ""];
		_triggers pushBack _trg;
	};
	private _inside = { player inArea _x } count _triggers;

	sleep 2;

	// Frame times of the next 15 s
	PVAR(benchFrames) = [];
	private _handler = addMissionEventHandler ["EachFrame", { PVAR(benchFrames) pushBack diag_deltaTime }];
	sleep 15;
	removeMissionEventHandler ["EachFrame", _handler];

	private _frames = PVAR(benchFrames);
	private _sum = 0;
	{ _sum = _sum + _x } forEach _frames;
	private _avg = 1000 * _sum / ((count _frames) max 1);
	private _max = 1000 * (selectMax (_frames + [0]));
	private _slow = 100 * ({ _x > 0.025 } count _frames) / ((count _frames) max 1);

	diag_log text format ["[ZEIC BENCH] %1 triggers, %2 | player inside %3 | frames %4 | avg %5 ms | max %6 ms | over 25 ms %7 percent",
		_count, _label, _inside, count _frames, _avg toFixed 2, _max toFixed 1, _slow toFixed 1];

	{ deleteVehicle _x } forEach _triggers;
	sleep 1;
} forEach _runs;

PVAR(benchFrames) = nil;
diag_log text "[ZEIC BENCH] ===== done =====";
systemChat "ZEIC trigger benchmark done.";
