#include "..\..\script_component.hpp"

/*
* Fill modifiers: the subclasses of CfgZEIC_Modifiers in the addon config and the mission config (description.ext),
* sorted by their "order" property (default 100), then by display name. Built once per mission.
* A mission class with the name of an addon modifier extends it (see PFUNC(fillModifiers_resolve)), it isn't listed twice.
*
* Arguments:
* None
*
* Return Value:
* Modifiers [[display name, modifier class (lower case), tooltip], ...] <ARRAY>
*
* Example:
* call ZEIC_fnc_fillModifiers_list
*
* Public: Yes
*/

if (isNil QPVAR(fillModifiers)) then {
	private _modifiers = createHashMap;

	{
		{
			private _key = toLower configName _x;
			if !(_key in _modifiers) then {
				private _name = getText (_x >> "displayName");
				if (_name == "") then { _name = configName _x };
				private _order = [100, getNumber (_x >> "order")] select (isNumber (_x >> "order"));
				_modifiers set [_key, [_order, _name, _key, getText (_x >> "tooltip")]];
			};
		} forEach ("true" configClasses (_x >> "CfgZEIC_Modifiers"));
	} forEach [configFile, missionConfigFile];

	private _list = values _modifiers;
	_list sort true;

	PVAR(fillModifiers) = _list apply { [_x select 1, _x select 2, _x select 3] };
};

PVAR(fillModifiers)
