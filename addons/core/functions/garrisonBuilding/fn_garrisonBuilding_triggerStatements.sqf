#include "..\..\script_component.hpp"

/*
* Statements of a garrison's "Move AI" trigger. Plain vanilla code, since Eden saves them into the mission
* (no ZEIC dependency). The trigger fires once and only acts on its own group, stored on the trigger
* (variable ZEIC_group); in Eden the group is found once by its id (group variable ZEIC_garrison, set in the units' init).
* - Condition: an enemy of the garrison's side is among the players in the area. Deletes the trigger when no unit
*   of the group is alive any more.
* - Activation: about 20 % of the units may move. After a random 30-120 s (trigger variable ZEIC_releaseDelay
*   overrides it, for the self test) all units may move and follow their leader, so they can hunt the players,
*   and the trigger deletes itself.
* - No deactivation: the trigger isn't repeatable.
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
	"private _group = thisTrigger getVariable ['ZEIC_group', grpNull];",
	"{",
	"    if (alive _x && {random 1 < 0.2}) then {",
	"        _x remoteExec ['doStop', _x];",
	"        [_x, 'PATH'] remoteExec ['enableAI', _x];",
	"    };",
	"} forEach units _group;",
	"[thisTrigger, _group, thisTrigger getVariable ['ZEIC_releaseDelay', 30 + random 90]] spawn {",
	"    params ['_trigger', '_group', '_delay'];",
	"    sleep _delay;",
	"    {",
	"        if (alive _x) then {",
	"            [_x, leader _x] remoteExec ['doFollow', _x];",
	"            [_x, 'PATH'] remoteExec ['enableAI', _x];",
	"        };",
	"    } forEach units _group;",
	"    deleteVehicle _trigger;",
	"};"
] joinString endl;

[_condition, _onActivation, ""]
