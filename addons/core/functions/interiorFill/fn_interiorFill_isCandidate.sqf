#include "..\..\script_component.hpp"

/*
* Checks whether a building can be furnished from the categories: it has building positions, or a template entry
* in one of the categories (e.g. bunkers, towers), or it is listed via PFUNC(addCustomHouse).
*
* Arguments:
* 0: Building <OBJECT>
* 1: Categories, e.g. ["mil", "civ"] <ARRAY of STRINGs or STRING>
*
* Return Value:
* Candidate <BOOL>
*
* Public: No
*/

params [["_bld", objNull, [objNull]], ["_categories", [], [[], ""]]];

if (_categories isEqualType "") then { _categories = [_categories] };
private _type = typeOf _bld;

((_bld buildingPos 0) isNotEqualTo [0,0,0])
|| {_categories findIf { isClass (configFile >> "CfgZEIC" >> _x >> _type) || {isClass (missionConfigFile >> "CfgZEIC" >> _x >> _type)} } != -1}
|| {_type in (missionNamespace getVariable [QPVAR(additionalBuildings), []])}
