#include "..\..\script_component.hpp"

/*
* Interior Fill categories: the subclasses of CfgZEIC in the addon config and the mission config (description.ext),
* sorted by their "order" property (default 100), then by display name. Built once per mission.
*
* Arguments:
* None
*
* Return Value:
* Categories [[display name, category class, shortcut ("" none, "ctrl", "shift", "ctrl+shift")], ...] <ARRAY>
*
* Example:
* call ZEIC_fnc_interiorFill_categories
*
* Public: Yes
*/

if (isNil QPVAR(interiorFillCategories)) then {
	private _categories = createHashMap;

	{
		{
			private _key = toLower configName _x;
			if !(_key in _categories) then {
				private _name = getText (_x >> "displayName");
				if (_name == "") then { _name = configName _x };
				private _order = [100, getNumber (_x >> "order")] select (isNumber (_x >> "order"));
				// "Shift+Ctrl" -> "ctrl+shift", the order of PFUNC(modifiers_get)
				private _keys = (toLowerANSI getText (_x >> "shortcut")) splitString "+ ";
				private _shortcut = (["ctrl", "shift", "alt"] select { _x in _keys }) joinString "+";
				_categories set [_key, [_order, _name, _key, _shortcut]];
			};
		} forEach ("true" configClasses (_x >> "CfgZEIC"));
	} forEach [configFile, missionConfigFile];

	private _list = values _categories;
	_list sort true;

	PVAR(interiorFillCategories) = _list apply { [_x select 1, _x select 2, _x select 3] };
};

PVAR(interiorFillCategories)
