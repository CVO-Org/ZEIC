#include "../script_component.hpp"

params [
	["_type", "", [""]],
	["_data", "", [""]]
];

if (_data isEqualTo "") exitWith { diag_log format ['[ZEIC](Error)(fn_addCustomTemplate) Invalid Data: %1', _data]; };

(_data splitString ": ") params ["_bld", "_template"];
_template = parseSimpleArray _template;

switch (_type) do {
	case "mil": {
		if (isNil QPVAR(civ_customBuildings)) then {PVAR(civ_customBuildings) = []};
		private _path = [PVAR(civ_customBuildings), _bld] call BIS_fnc_findNestedElement;
		
		if (_path isNotEqualTo []) then {
			((PVAR(civ_customBuildings) # (_path # 0)) # 1) pushBackUnique _template;
		} else {
			PVAR(civ_customBuildings) pushBackUnique [_bld, [_template]];
		};
	};
	case "civ": {
		if (isNil QPVAR(mil_customBuildings)) then {PVAR(mil_customBuildings) = []};
		private _path = [PVAR(mil_customBuildings), _bld] call BIS_fnc_findNestedElement;
		
		if (_path isNotEqualTo []) then {
			((PVAR(mil_customBuildings) # (_path # 0)) # 1) pushBackUnique _template;
		} else {
			PVAR(mil_customBuildings) pushBackUnique [_bld, [_template]];
		};
	};
	default { diag_log format ['[ZEIC](Error)(fn_addCustomTemplate) Type not supported: %1', _type]; };
};
