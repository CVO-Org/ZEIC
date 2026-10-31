#include "..\..\script_component.hpp"

/*
* Self test: CfgPatches of the mod and all functions compiled.
* Part of PFUNC(dev_selfTest), needs its scheduled environment.
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

// T0 CfgPatches (#29)
private _cfgCore = configFile >> "CfgPatches" >> "ZEIC_core";
["T0.1 CfgPatches ZEIC_core exists", isClass _cfgCore] call PFUNC(dev_check);
["T0.2 CfgPatches ZEIC_main exists", isClass (configFile >> "CfgPatches" >> "ZEIC_main")] call PFUNC(dev_check);
["T0.3 no CfgPatches named ADDON", !isClass (configFile >> "CfgPatches" >> "ADDON")] call PFUNC(dev_check);
["T0.4 ZEIC_core requires ZEIC_main", (getArray (_cfgCore >> "requiredAddons") findIf { _x == "ZEIC_main" }) != -1, getArray (_cfgCore >> "requiredAddons")] call PFUNC(dev_check);

private _curatorModules = getArray (_cfgCore >> "units") select { getNumber (configFile >> "CfgVehicles" >> _x >> "scopeCurator") == 2 };
["T0.5 ZEIC_core lists the 4 Zeus modules", count _curatorModules == 4, _curatorModules] call PFUNC(dev_check);
["T0.6 Zeus module injection removed", isNil QPFUNC(zeus_addModules)] call PFUNC(dev_check);

// T1 all functions compiled (#29, #30)
private _functions = [];
{
	{ _functions pushBack format ["ZEIC_fnc_%1", configName _x] } forEach ("true" configClasses _x);
} forEach ("true" configClasses (configFile >> "CfgFunctions" >> "ZEIC"));
private _broken = _functions select { !((missionNamespace getVariable [_x, 0]) isEqualType {}) };
["T1 all ZEIC functions compiled", _broken isEqualTo [], [count _functions, _broken]] call PFUNC(dev_check);
