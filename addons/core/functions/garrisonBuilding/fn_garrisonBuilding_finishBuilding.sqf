#include "..\..\script_component.hpp"

/*
* Finishes the building in progress of a Garrison job: group settings, dynamic simulation, optional "move AI" trigger,
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
private _onActivation = "{ if (local _x) then { if (!(_x checkAIFeature 'PATH') && random 1 < 0.2) then { doStop _x; _x enableAI 'PATH' }; }; } forEach (allUnits inAreaArray thisTrigger);";
private _onDeactivation = "{ if (local _x) then { if !(_x checkAIFeature 'PATH') then { _x doFollow leader _x; _x enableAI 'PATH' }; }; } forEach (allUnits inAreaArray thisTrigger);";

if (is3DEN) then {
	// Set group to be deleted when empty.
	_group set3DENAttribute ["garbageCollectGroup", true];

	// Set dynamicSimulation if forced or all units are inside a building.
	if ((_job get "forceDS") || {(_units findIf { (lineIntersectsWith [eyePos _x, (eyePos _x) vectorAdd [0, 0, 10]] select { _x isKindOf "Building" }) isEqualTo [] }) == -1}) then {
		_group set3DENAttribute ["dynamicSimulation", true];
	};

	delete3DENEntities [_job get "tempUnit"];

	if (_job get "createTR") then {
		private _trg = create3DENEntity ["Trigger", "EmptyDetector", getPos _bld];
		_trg set3DENLayer (_job get "layer");
		_trg set3DENAttribute ["Size2", [_rad, _rad]];
		_trg set3DENAttribute ["Size3", [_rad, _rad, 15]];
		_trg set3DENAttribute ["IsRectangle", false];
		_trg set3DENAttribute ["ActivationBy", "AnyPlayer"];
		_trg set3DENAttribute ["activationType", "Present"];
		_trg set3DENAttribute ["triggerInterval", 5];
		_trg set3DENAttribute ["onActivation", _onActivation];
		_trg set3DENAttribute ["onDeactivation", _onDeactivation];
	};
} else {
	if (_job get "forceDS") then { _group spawn { sleep 5; _this enableDynamicSimulation true; }; };

	if (_job get "createTR") then {
		private _trg = createTrigger ["EmptyDetector", getPos _bld];
		_trg setTriggerArea [_rad, _rad, 0, false, 15];
		_trg setTriggerActivation ["ANYPLAYER", "PRESENT", false];
		_trg setTriggerInterval 5;
		_trg setTriggerStatements ["this", _onActivation, _onDeactivation];
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
