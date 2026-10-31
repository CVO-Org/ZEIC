#include "..\..\script_component.hpp"

/*
* One step of an Interior Fill job (called by the processing queue).
* - No building in progress: start the next one (pick its template, or report it as having none).
* - Building in progress: spawn its next object.
*   In Eden every building has its own layer, so a whole interior can still be deleted at once.
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
				// Eden: one layer for the whole fill, created with its first building
				if (is3DEN && {(_job get "fillLayer") == -1}) then {
					private _category = _job get "category";
					private _categoryName = ((call PFUNC(interiorFill_categories)) select { (_x select 1) == _category }) param [0, [toUpper _category]] select 0;
					_job set ["fillLayer", ["ZEIC Interiors", _categoryName] call PFUNC(eden_addLayer)];
				};
				_job set ["layer", [_bld, _job get "allowDamage", _job get "fillLayer"] call PFUNC(interiorFill_prepareBuilding)];
				[_bld, FEEDBACK_PROCESSING] call PFUNC(feedback_report);
			};
		};
	};

	_finished
};

// ---- spawn the next object of the current building
private _items = _job get "items";
private _objects = _job get "objects";
private _itemIndex = _job get "itemIndex";

private _obj = [_bld, _items select _itemIndex, _job get "objectMode", _job get "layer"] call PFUNC(interiorFill_spawnObject);
if (!isNull _obj) then { _objects pushBack _obj };
_job set ["itemIndex", _itemIndex + 1];

if ((_job get "itemIndex") >= count _items) then {
	[_bld, _objects, _job get "objectMode"] call PFUNC(interiorFill_finishBuilding);

	if (_objects isEqualTo []) then {
		[_bld, FEEDBACK_NONE] call PFUNC(feedback_report);
	} else {
		_job set ["furnished", (_job get "furnished") + 1];
		[_bld, FEEDBACK_DONE] call PFUNC(feedback_report);
	};

	_job set ["current", objNull];
};

false
