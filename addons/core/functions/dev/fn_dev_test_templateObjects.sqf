#include "..\..\script_component.hpp"

/*
* Self test: every object in the loaded template addons, Object Fill and Object Switch config exists (templates with a missing object are skipped
* when filling, so a typo silently costs a template). Lists the broken ones in the RPT.
* Part of PFUNC(dev_selfTest).
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

// T20 template objects exist
private _missing = createHashMap; // object class -> ["category/building/template", ...]
private _templates = 0;
{
	private _category = configName _x;
	{
		private _building = configName _x;
		{
			_templates = _templates + 1;
			private _where = format ["%1/%2/%3", _category, _building, configName _x];
			{
				private _class = _x select 0;
				if !(isClass (configFile >> "CfgVehicles" >> _class)) then {
					(_missing getOrDefaultCall [_class, { [] }, true]) pushBack _where;
				};
			} forEach getArray (_x >> "objects");
		} forEach configProperties [_x, "isClass _x", true];
	} forEach ("true" configClasses _x);
} forEach ("true" configClasses (configFile >> "CfgZEIC"));

// Object Fill props and floor objects, Object Switch sets (only the sets of loaded addons exist)
private _fnc_check = {
	params ["_class", "_where"];
	if (_class != "" && {!isClass (configFile >> "CfgVehicles" >> _class)}) then {
		(_missing getOrDefaultCall [_class, { [] }, true]) pushBack _where;
	};
};
{
	private _type = configName _x;
	[getText (_x >> "floor"), "ObjectFill/" + _type + "/floor"] call _fnc_check;
	{ [_x, "ObjectFill/" + _type] call _fnc_check } forEach getArray (_x >> "objects");
	{
		private _where = format ["ObjectFill/%1/%2", _type, configName _x];
		{ [_x, _where] call _fnc_check } forEach getArray (_x >> "objects");
	} forEach ("true" configClasses _x);
} forEach ("true" configClasses (configFile >> "CfgZEIC_ObjectFill" >> "Types"));
{
	private _row = configName _x;
	{ [getText _x, format ["ObjectSwitch/%1/%2", _row, configName _x]] call _fnc_check } forEach configProperties [_x, "isText _x", false];
} forEach ("true" configClasses (configFile >> "CfgZEIC_ObjectSwitch" >> "Objects"));

{ diag_log text format ["[ZEIC TEST] INFO T20 missing object %1 in %2", _x, _y] } forEach _missing;
["T20 every object in the loaded templates, Object Fill and Object Switch exists", count _missing == 0, [_templates, keys _missing]] call PFUNC(dev_check);
