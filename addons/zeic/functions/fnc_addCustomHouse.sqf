#include "..\script_component.hpp"

params [["_house", "", [""]]];

if !(isClass (configFile >> "CfgVehicles" >> _house)) exitWith {
	[format ["Building class '%1' not found in CfgVehicles.", _house], "ERROR"] call PFUNC(misc_logMsg);
};
if (isNil QPVAR(additionalBuildings)) then {PVAR(additionalBuildings) = []};

PVAR(additionalBuildings) pushBackUnique _house;
