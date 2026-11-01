#include "..\..\script_component.hpp"

/*
* Statements of a garrison's "Move AI" trigger. Plain vanilla code, since Eden saves them into the mission
* (no ZEIC dependency). The trigger is repeatable and only acts on its own group, stored on the trigger
* (variable ZEIC_group); in Eden the group is found once by its id (group variable ZEIC_garrison, set in the units' init).
* - Condition: an enemy of the garrison's side is among the players in the area. Deletes the trigger when no unit
*   of the group is alive any more.
* - Activation: about 20 % of the units that are still held in place may move (each unit once).
* - Deactivation (the players left): all units may move and follow their leader, so they can hunt the players.
*   The trigger has done its job and deletes itself.
* Units are reached on their owner (enableAI, doStop and doFollow need a local unit).
*
* Arguments:
* 0: Garrison id, for Eden (empty: the group is set on the trigger) <STRING>
*
* Return Value:
* [condition, on activation, on deactivation] <ARRAY of STRINGs>
*
* Public: No
*/

params [["_id", "", [""]]];

private _condition = [
	"private _group = thisTrigger getVariable ['ZEIC_group', grpNull];",
	format ["if (isNull _group && {'%1' != ''}) then {", _id],
	format ["    _group = (allGroups select { (_x getVariable ['ZEIC_garrison', '']) == '%1' }) param [0, grpNull];", _id],
	"    thisTrigger setVariable ['ZEIC_group', _group];",
	"};",
	"if ((units _group) findIf { alive _x } == -1) then { deleteVehicle thisTrigger; false } else {",
	"    this && {thisList findIf { ((side _group) getFriend (side group _x)) < 0.6 } != -1}",
	"}"
] joinString endl;

private _onActivation = [
	"private _released = thisTrigger getVariable ['ZEIC_released', []];",
	"{",
	"    if (alive _x && {!(_x in _released)} && {random 1 < 0.2}) then {",
	"        _released pushBack _x;",
	"        _x remoteExec ['doStop', _x];",
	"        [_x, 'PATH'] remoteExec ['enableAI', _x];",
	"    };",
	"} forEach units (thisTrigger getVariable ['ZEIC_group', grpNull]);",
	"thisTrigger setVariable ['ZEIC_released', _released];"
] joinString endl;

private _onDeactivation = [
	"{",
	"    if (alive _x) then {",
	"        [_x, leader _x] remoteExec ['doFollow', _x];",
	"        [_x, 'PATH'] remoteExec ['enableAI', _x];",
	"    };",
	"} forEach units (thisTrigger getVariable ['ZEIC_group', grpNull]);",
	"deleteVehicle thisTrigger;"
] joinString endl;

[_condition, _onActivation, _onDeactivation]
