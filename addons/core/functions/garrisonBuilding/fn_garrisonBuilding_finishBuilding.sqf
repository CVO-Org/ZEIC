#include "..\..\script_component.hpp"

/*
* Finishes the building in progress of a Garrison job: group settings, dynamic simulation, optional "move AI" trigger
* (server only, acts on this building's group, see PFUNC(garrisonBuilding_triggerStatements)),
* and makes the units editable for all curators (in one call).
*
* Arguments:
* 0: Job <HASHMAP> - see PFUNC(garrisonBuilding_start)
*
* Return Value:
* None
*
* Public: No
*/

params ["_job"];

private _bld = _job get "current";
private _group = _job get "group";
private _units = _job get "spawned";
private _rad = (round (sizeOf typeOf _bld)) max 40;

if (is3DEN) then {
	// Set group to be deleted when empty.
	_group set3DENAttribute ["garbageCollectGroup", true];

	// Set dynamicSimulation if forced or all units are inside a building.
	if ((_job get "forceDS") || {(_units findIf { (lineIntersectsWith [eyePos _x, (eyePos _x) vectorAdd [0, 0, 10]] select { _x isKindOf "Building" }) isEqualTo [] }) == -1}) then {
		_group set3DENAttribute ["dynamicSimulation", true];
	};

	delete3DENEntities [_job get "tempUnit"];

	if (_job get "createTR" && {_units isNotEqualTo []}) then {
		// The trigger finds its group by an id that the units' init puts on the group (no ZEIC code in the mission)
		private _id = format ["%1_%2_%3", round ((getPos _bld) select 0), round ((getPos _bld) select 1), floor random 100000];
		{
			private _init = (_x get3DENAttribute "Init") param [0, ""];
			_x set3DENAttribute ["Init", _init + format [" group this setVariable ['ZEIC_garrison', '%1'];", _id]];
		} forEach _units;

		(_id call PFUNC(garrisonBuilding_triggerStatements)) params ["_condition", "_onActivation"];
		private _trg = create3DENEntity ["Trigger", "EmptyDetector", getPos _bld];
		_trg set3DENLayer (_job get "layer");
		_trg set3DENAttribute ["Size2", [_rad, _rad]];
		_trg set3DENAttribute ["Size3", [_rad, _rad, 15]];
		_trg set3DENAttribute ["IsRectangle", false];
		_trg set3DENAttribute ["ActivationBy", "AnyPlayer"];
		_trg set3DENAttribute ["activationType", "Present"];
		_trg set3DENAttribute ["repeatable", false];
		_trg set3DENAttribute ["isServerOnly", true];
		_trg set3DENAttribute ["triggerInterval", (round ((4 + random 2) * 10)) / 10];
		_trg set3DENAttribute ["condition", _condition];
		_trg set3DENAttribute ["onActivation", _onActivation];
	};
} else {
	if (_job get "forceDS") then { _group spawn { sleep 5; _this enableDynamicSimulation true; }; };

	// On the server only, see PFUNC(garrisonBuilding_createTrigger)
	if (_job get "createTR" && {_units isNotEqualTo []}) then {
		[getPos _bld, _rad, _group] call PFUNC(garrisonBuilding_createTrigger);
	};

	if (_units isNotEqualTo []) then {
		if (isServer) then {
			{ _x addCuratorEditableObjects [_units, true] } forEach allCurators;
		} else {
			{ [_x, [_units, true]] remoteExec ["addCuratorEditableObjects", 2] } forEach allCurators;
		};
	};
};

_job set ["buildingCount", (_job get "buildingCount") + 1];
_job set ["unitCount", (_job get "unitCount") + count _units];
[_bld, [FEEDBACK_NONE, FEEDBACK_DONE] select (_units isNotEqualTo [])] call PFUNC(feedback_report);
