#include "..\..\script_component.hpp"

/*
* Queues an Interior Fill job. Runs on the server, or locally in Eden.
* Buildings that are already furnished or queued are skipped, the rest are marked as queued right away.
*
* Arguments:
* 0: Buildings <ARRAY of OBJECTs>
* 1: Category, e.g. "mil" <STRING>
* 2: Options [object mode <NUMBER>, allow damage <BOOL>] <ARRAY> (a 3rd element, the removed detail level, is ignored)
*    Object mode: 0 simple objects, 1 normal objects, 2 normal objects editable in Zeus (true/false = 2/0)
* 3: Requesting client (receives the summary message) <NUMBER>
*
* Return Value:
* None
*
* Public: No
*/

params [["_buildings", [], [[]]], ["_category", "mil", [""]], ["_options", [], [[]]], ["_requester", clientOwner, [0]]];
_options params [["_objectMode", OBJECT_MODE_SIMPLE, [0, true]], ["_allowDamage", false, [false]]];

// Older callers passed "editable in Zeus" as a boolean
if (_objectMode isEqualType true) then { _objectMode = [OBJECT_MODE_SIMPLE, OBJECT_MODE_EDITABLE] select _objectMode };

_buildings = _buildings select {
	!isNull _x
	&& {!(_x getVariable [QPVAR(queued), false])}
	&& {isNull (_x getVariable [QPVAR(furnished), objNull])}
};
_buildings = [_buildings arrayIntersect _buildings] call PFUNC(queue_sortBuildings);

if (_buildings isEqualTo []) exitWith {
	["Interior Fill: all selected buildings are already furnished.", _requester] call PFUNC(interiorFill_notify);
};

{
	_x setVariable [QPVAR(queued), true];
	[_x, FEEDBACK_QUEUED] call PFUNC(feedback_report);
} forEach _buildings;

[createHashMapFromArray [
	["step", PFUNC(interiorFill_step)],
	["buildings", _buildings],
	["index", 0],
	["category", toLower _category],
	["objectMode", _objectMode],
	["allowDamage", _allowDamage],
	["requester", _requester],
	// current building
	["current", objNull],
	["items", []],
	["itemIndex", 0],
	["objects", []],
	["layer", -1],
	["fillLayer", -1],
	// results
	["furnished", 0],
	["missing", []]
]] call PFUNC(queue_add);
