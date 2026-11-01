#include "..\..\script_component.hpp"

/*
* One step of a Garrison job (called by the processing queue).
* - No building in progress: start the next one (group, Eden layer, random building positions).
* - Building in progress: place its next unit.
*
* Arguments:
* 0: Job <HASHMAP> - see PFUNC(garrisonBuilding_start)
*
* Return Value:
* Job finished <BOOL>
*
* Public: No
*/

params ["_job"];

private _bld = _job get "current";

// ---- start the next building
if (isNull _bld) exitWith {
	private _buildings = _job get "buildings";
	private _index = _job get "index";
	private _finished = _index >= count _buildings;

	// Advanced Fill: a building is garrisoned once its interior is done
	if (!_finished && {[_job, _buildings select _index] call PFUNC(advancedFill_waitForInterior)}) exitWith { false };

	if (_finished) then {
		[_job] call PFUNC(garrisonBuilding_finishJob);
	} else {
		_job set ["index", _index + 1];
		_bld = _buildings select _index;

		if (!isNull _bld) then {
			// Advanced Fill collision check: reserved positions (furniture gives way) or the free ones (units give way)
			private _indices = [];
			private _reservedIndex = (_job get "reserved") find _bld;
			if (_reservedIndex != -1) then {
				_indices = (_job get "reservedIndices") select _reservedIndex;
			} else {
				(_bld getVariable [QPVAR(freePositions), []]) params [["_linkId", ""], ["_free", []]];
				if ((_job get "collision") == COLLISION_UNITS_GIVE_WAY && {_linkId == _job get "linkId"}) then {
					_indices = _free;
				} else {
					for "_i" from 0 to count (_bld buildingPos -1) - 1 do { _indices pushBack _i };
				};
				_bld setVariable [QPVAR(freePositions), nil];
				_indices = [_bld buildingPos -1, _indices call BIS_fnc_arrayShuffle, (_job get "unitCounts") select _index] call PFUNC(garrisonBuilding_spreadPositions);
			};
			_job set ["positions", _indices apply { _bld buildingPos _x }];
			_job set ["spawned", []];

			if (is3DEN) then {
				private _layers = _job get "layers";
				if (count _layers > 0) then {
					// Advanced Fill: the units in the building's "Units" layer, the trigger in the building layer
					_job set ["layer", [_layers, _bld, "Units"] call PFUNC(advancedFill_layer)];
					_job set ["triggerLayer", [_layers, _bld] call PFUNC(advancedFill_layer)];
				} else {
					// One layer for the whole garrison, created with its first building, and one per building inside it
					if ((_job get "fillLayer") == -1) then {
						_job set ["fillLayer", ["ZEIC Garrisons", _job get "faction"] call PFUNC(eden_addLayer)];
					};
					_job set ["layer", [_job get "fillLayer", getText (configOf _bld >> "displayName")] call PFUNC(eden_addLayer)];
					_job set ["triggerLayer", _job get "layer"];
				};

				// Eden can only create a group through a unit: a temporary one, deleted once the building is done.
				// TODO: Find a neater way to create a group (create3DENComposition)?
				private _tempClass = ["I_Soldier_F", "O_Soldier_F", "B_Soldier_F", "C_man_1"] select (([independent, east, west, civilian] find (_job get "side")) max 0);
				private _tempUnit = create3DENEntity ["Object", _tempClass, [0, 0, 0]];
				_job set ["tempUnit", _tempUnit];
				_job set ["group", group _tempUnit];
			} else {
				_job set ["group", createGroup [_job get "side", true]];
			};

			_job set ["current", _bld];
			[_bld, FEEDBACK_PROCESSING] call PFUNC(feedback_report);
		};
	};

	_finished
};

// ---- place the next unit of the current building (none if the collision check left no free position)
private _positions = _job get "positions";
if (_positions isNotEqualTo []) then {
	private _unit = [
		_job get "group",
		selectRandom (_job get "unitTypes"),
		_positions deleteAt 0,
		_bld,
		_job get "layer"
	] call PFUNC(garrisonUnit);

	if (!isNull _unit) then { (_job get "spawned") pushBack _unit };
};

if (_positions isEqualTo []) then {
	[_job] call PFUNC(garrisonBuilding_finishBuilding);
	_job set ["current", objNull];
};

false
