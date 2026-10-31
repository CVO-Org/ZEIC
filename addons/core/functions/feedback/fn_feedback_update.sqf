#include "..\..\script_component.hpp"

/*
* Applies progress states and starts drawing wireframe boxes around the buildings.
* Runs on the machines that show progress (see PFUNC(feedback_send)).
*
* Arguments:
* 0: States <ARRAY> - [[building, state], ...]
*
* Return Value:
* None
*
* Public: No
*/

params [["_states", [], [[]]]];

if (isNil QPVAR(feedback)) then { PVAR(feedback) = [] };

// A new update cancels a pending clear of an earlier fill, so all results are cleared together.
PVAR(feedbackGeneration) = (missionNamespace getVariable [QPVAR(feedbackGeneration), 0]) + 1;

private _edges = [[0,1],[2,3],[4,5],[6,7],[0,2],[1,3],[4,6],[5,7],[0,4],[1,5],[2,6],[3,7]];

{
	_x params ["_bld", "_state"];

	if (!isNull _bld) then {
		// The entry index is stored on the building (objects can't be HashMap keys).
		private _index = _bld getVariable [QPVAR(feedbackIndex), -1];

		if (_index == -1 && {count PVAR(feedback) < FEEDBACK_MAX}) then {
			// Buildings don't move: compute the box lines (AGL) once.
			(boundingBoxReal _bld) params ["_min", "_max"];
			private _corners = [];
			for "_i" from 0 to 7 do {
				_corners pushBack (_bld modelToWorld [
					[_min select 0, _max select 0] select (_i mod 2),
					[_min select 1, _max select 1] select ((floor (_i / 2)) mod 2),
					[_min select 2, _max select 2] select (floor (_i / 4))
				]);
			};
			private _lines = _edges apply { [_corners select (_x select 0), _corners select (_x select 1)] };

			_index = PVAR(feedback) pushBack [_bld, _lines, [], 0];
			_bld setVariable [QPVAR(feedbackIndex), _index];
		};

		if (_index != -1) then {
			private _entry = PVAR(feedback) select _index;
			_entry set [2, FEEDBACK_COLORS select _state];
			_entry set [3, FEEDBACK_WIDTHS select _state];
		};
	};
} forEach _states;

if (PVAR(feedback) isNotEqualTo [] && {isNil QPVAR(feedbackEH)}) then {
	PVAR(feedbackEH) = addMissionEventHandler ["EachFrame", { call PFUNC(feedback_draw) }];
};
