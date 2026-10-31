#include "..\..\script_component.hpp"

/*
* One step of an Interior Fill job (called by the processing queue).
* - No building in progress: start the next one (pick its template, or report it as having none).
* - Building in progress: spawn its next object. In Eden the whole building is spawned at once,
*   so it becomes one undo step (collect3DENHistory can't span frames).
*
* Arguments:
* 0: Job <HASHMAP> - see PFUNC(interiorFill_enqueue)
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
		[_job] call PFUNC(interiorFill_finishJob);
	} else {
		_job set ["index", _index + 1];
		_bld = _buildings select _index;

		if (!isNull _bld) then {
			private _items = [_bld, _job get "category", true] call PFUNC(interiorFill_selectTemplate);

			if (_items isEqualTo []) then {
				(_job get "missing") pushBack typeOf _bld;
				_bld setVariable [QPVAR(queued), nil];
				[_bld, FEEDBACK_NONE] call PFUNC(feedback_report);
			} else {
				_job set ["current", _bld];
				_job set ["items", _items];
				_job set ["itemIndex", 0];
				_job set ["objects", []];
				_job set ["layer", [_bld, _job get "allowDamage"] call PFUNC(interiorFill_prepareBuilding)];
				[_bld, FEEDBACK_PROCESSING] call PFUNC(feedback_report);
			};
		};
	};

	_finished
};

// ---- spawn objects of the current building
private _items = _job get "items";
private _objects = _job get "objects";
private _spawnArgs = [_job get "addZeus", _job get "detail", _job get "layer"];

if (is3DEN) then {
	collect3DENHistory {
		{
			private _obj = ([_bld, _x] + _spawnArgs) call PFUNC(interiorFill_spawnObject);
			if (!isNull _obj) then { _objects pushBack _obj };
		} forEach _items;
	};
	_job set ["itemIndex", count _items];
} else {
	private _itemIndex = _job get "itemIndex";
	private _obj = ([_bld, _items select _itemIndex] + _spawnArgs) call PFUNC(interiorFill_spawnObject);
	if (!isNull _obj) then { _objects pushBack _obj };
	_job set ["itemIndex", _itemIndex + 1];
};

if ((_job get "itemIndex") >= count _items) then {
	[_bld, _objects, _job get "addZeus"] call PFUNC(interiorFill_finishBuilding);

	if (_objects isEqualTo []) then {
		[_bld, FEEDBACK_NONE] call PFUNC(feedback_report);
	} else {
		_job set ["furnished", (_job get "furnished") + 1];
		[_bld, FEEDBACK_DONE] call PFUNC(feedback_report);
	};

	_job set ["current", objNull];
};

false
