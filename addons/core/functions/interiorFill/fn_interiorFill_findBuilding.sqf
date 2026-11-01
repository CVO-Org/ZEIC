#include "..\..\script_component.hpp"

/*
* Finds the building a module was placed on (Interior Fill, Advanced Fill): the object under the mouse if it is a
* building, or another object (e.g. a tent) that a category has templates for; otherwise the nearest building
* within 25 m of the mouse.
*
* Arguments:
* None
*
* Return Value:
* Building, objNull if none <OBJECT>
*
* Public: No
*/

private _bld = objNull;
if (is3DEN) then {
	if (get3DENMouseOver # 0 == "Object") then { _bld = get3DENMouseOver # 1 };
} else {
	if (curatorMouseOver # 0 == "Object") then { _bld = curatorMouseOver # 1 };
};

// Buildings, and other objects (e.g. tents) only if a category has templates for them; not e.g. a weapon on the ground
private _type = typeOf _bld;
private _hasTemplates = (call PFUNC(interiorFill_categories)) findIf {
	isClass (configFile >> "CfgZEIC" >> (_x select 1) >> _type) || {isClass (missionConfigFile >> "CfgZEIC" >> (_x select 1) >> _type)}
} != -1 || {_type in (missionNamespace getVariable [QPVAR(additionalBuildings), []])};
if !(_bld isKindOf "building" || _hasTemplates) then { _bld = objNull };

if (isNull _bld) then {
	private _nearArr = nearestObjects [(screenToWorld getMousePosition), ["building"], 25, true];
	private _objArr = _nearArr select { sizeOf typeOf _x > 2 || (_x buildingPos -1) isNotEqualTo [] };

	if (_objArr isNotEqualTo []) then { _bld = _objArr select 0 };
};

_bld
