#include "..\..\script_component.hpp"

/*
* Reads the settings of the Advanced Fill dialog, as PFUNC(ui_advancedFill) takes them (also what a preset saves).
* Categories, fill modifiers and the faction + subcategory are class names.
*
* Arguments:
* 0: Display <DISPLAY>
*
* Return Value:
* Settings <HASHMAP>
*
* Public: No
*/

params [["_display", displayNull, [displayNull]]];

createHashMapFromArray [
	["interior", _display getVariable ["interior", false]],
	["categories", _display getVariable ["categories", []]],
	["objects", _display getVariable ["objects", OBJECT_MODE_SIMPLE]],
	["damage", _display getVariable ["damage", false]],
	["modifiers", ((call PFUNC(fillModifiers_list)) select { _display getVariable [format ["modifier_%1", _x select 1], false] }) apply { _x select 1 }],
	["garrison", _display getVariable ["garrison", false]],
	["pair", _display getVariable [QPVAR(selection), []]],
	["positions", _display getVariable ["positions", 50]],
	["dynamic", _display getVariable ["dynamic", false]],
	["trigger", _display getVariable ["trigger", false]],
	["radius", _display getVariable ["radius", 0]],
	["percent", _display getVariable ["percent", 50]],
	["collision", _display getVariable ["collision", true]],
	["blocked", _display getVariable ["blocked", COLLISION_UNITS_GIVE_WAY]]
]
