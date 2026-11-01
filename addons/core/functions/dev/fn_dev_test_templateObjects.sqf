#include "..\..\script_component.hpp"

/*
* Self test: every object in the loaded template addons exists (templates with a missing object are skipped
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

{ diag_log text format ["[ZEIC TEST] INFO T20 missing object %1 in %2", _x, _y] } forEach _missing;
["T20 every object in the loaded templates exists", count _missing == 0, [_templates, keys _missing]] call PFUNC(dev_check);
