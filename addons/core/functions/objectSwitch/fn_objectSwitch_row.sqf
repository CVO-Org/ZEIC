#include "..\..\script_component.hpp"

/*
* Finds the Object Switch row (CfgZEIC_ObjectSwitch >> Objects) an object class belongs to, in any set.
* The first row in config order wins. The lookup is built once per game session (uiNamespace).
*
* Arguments:
* 0: Object class <STRING>
*
* Return Value:
* Row <CONFIG> (configNull if the class isn't in any set)
*
* Public: No
*/

params [["_class", "", [""]]];

private _lookup = uiNamespace getVariable QPVAR(objectSwitchLookup);
if (isNil "_lookup") then {
	_lookup = createHashMap;
	{
		private _row = _x;
		{
			private _key = toLowerANSI getText _x;
			if !(_key in _lookup) then { _lookup set [_key, _row] };
		} forEach configProperties [_row, "isText _x", false];
	} forEach ("true" configClasses (configFile >> "CfgZEIC_ObjectSwitch" >> "Objects"));
	uiNamespace setVariable [QPVAR(objectSwitchLookup), _lookup];
};

_lookup getOrDefault [toLowerANSI _class, configNull]
