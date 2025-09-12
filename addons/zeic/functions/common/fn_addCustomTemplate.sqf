#include "../../script_component.hpp"

params ["_type", "_data"];

(_data splitString ": ") params ["_bld", "_template"];
_template = parseSimpleArray _template;

if ((_type isEqualTo true && {_type}) || (_type isEqualTo "" && {_type == "civ"})) then {
	if (isNil QPVAR(civ_customBuildings)) then {PVAR(civ_customBuildings) = []};
	private _path = [PVAR(civ_customBuildings), _bld] call BIS_fnc_findNestedElement;
	
	if (_path isNotEqualTo []) then {
		((PVAR(civ_customBuildings) # (_path # 0)) # 1) pushBackUnique _template;
	} else {
		PVAR(civ_customBuildings) pushBackUnique [_bld, [_template]];
	};
} else {
	if (isNil QPVAR(mil_customBuildings)) then {PVAR(mil_customBuildings) = []};
	private _path = [PVAR(mil_customBuildings), _bld] call BIS_fnc_findNestedElement;
	
	if (_path isNotEqualTo []) then {
		((PVAR(mil_customBuildings) # (_path # 0)) # 1) pushBackUnique _template;
	} else {
		PVAR(mil_customBuildings) pushBackUnique [_bld, [_template]];
	};
};
