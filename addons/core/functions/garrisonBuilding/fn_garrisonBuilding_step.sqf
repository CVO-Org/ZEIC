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

	if (_finished) then {
		[_job] call PFUNC(garrisonBuilding_finishJob);
	} else {
		_job set ["index", _index + 1];
		_bld = _buildings select _index;

		if (!isNull _bld) then {
			private _positions = (_bld buildingPos -1) call BIS_fnc_arrayShuffle;
			_job set ["positions", _positions select [0, (_job get "units") min count _positions]];
			_job set ["spawned", []];

			if (is3DEN) then {
				private _counter = uiNamespace getVariable [QPVAR(layer_counter), 0];
				uiNamespace setVariable [QPVAR(layer_counter), _counter + 1];
				_job set ["layer", -1 add3DENLayer "ZEIC Garrison " + str _counter];

				// Eden can only create a group through a unit: a temporary one, deleted once the building is done.
				// TODO: Find a neater way to create a group (create3DENComposition)?
				private _tempClass = ["I_Soldier_F", "O_Soldier_F", "B_Soldier_F"] select (([independent, east, west] find (_job get "side")) max 0);
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

// ---- place the next unit of the current building
private _positions = _job get "positions";
private _unit = [
	_job get "group",
	selectRandom (_job get "unitTypes"),
	_positions deleteAt 0,
	_bld,
	_job get "layer"
] call PFUNC(garrisonUnit);

if (!isNull _unit) then { (_job get "spawned") pushBack _unit };

if (_positions isEqualTo []) then {
	[_job] call PFUNC(garrisonBuilding_finishBuilding);
	_job set ["current", objNull];
};

false
