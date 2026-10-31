#include "..\..\script_component.hpp"

/*
* Replaces an object class with a random variant from its group in CfgZEIC_Variants, and checks that it exists.
*
* The groups are read once per game session into a HashMap (object class -> members that exist).
* An object in several groups uses the group with the highest "priority" (default 0), otherwise the first one.
* An empty string in a group means "sometimes nothing".
*
* Arguments:
* 0: Object class <STRING>
* 1: Pick a random variant <BOOL> (default: true)
*
* Return Value:
* Object class to spawn, "" for nothing <STRING>
*
* Public: No
*/

params ["_item", ["_doRandom", true]];

private _variants = uiNamespace getVariable QPVAR(variants);
if (isNil "_variants") then {
	_variants = createHashMap;
	private _priorities = createHashMap;

	{
		private _priority = getNumber (_x >> "priority");
		private _members = (getArray (_x >> "objects")) select { _x == "" || {isClass (configFile >> "CfgVehicles" >> _x)} };

		{
			private _key = toLower _x;
			if (_x != "" && {_priority > (_priorities getOrDefault [_key, -1])}) then {
				_variants set [_key, _members];
				_priorities set [_key, _priority];
			};
		} forEach _members;
	} forEach ("true" configClasses (configFile >> "CfgZEIC_Variants"));

	uiNamespace setVariable [QPVAR(variants), _variants];
};

// If item is present, replace it with a random variant.
if (_doRandom) then {
	private _members = _variants getOrDefault [toLower _item, []];
	if (_members isNotEqualTo []) then { _item = selectRandom _members };
};

if (_item != "" && { !isClass (configFile >> "CfgVehicles" >> _item) }) then {
	[format ["Invalid Classname (%1)", _item], "ERROR"] call PFUNC(misc_logMsg);
	_item = "";
};

_item	// return
