#include "..\..\script_component.hpp"

/*
* Checks whether a building can be furnished from a category: it has building positions, or a template entry
* in the category (e.g. bunkers, towers), or it is listed via PFUNC(addCustomHouse).
*
* Arguments:
* 0: Building <OBJECT>
* 1: Category, e.g. "mil" <STRING>
*
* Return Value:
* Candidate <BOOL>
*
* Public: No
*/

params [["_bld", objNull, [objNull]], ["_category", "", [""]]];

((_bld buildingPos 0) isNotEqualTo [0,0,0])
|| {isClass (configFile >> "CfgZEIC" >> _category >> typeOf _bld)}
|| {isClass (missionConfigFile >> "CfgZEIC" >> _category >> typeOf _bld)}
|| {typeOf _bld in (missionNamespace getVariable [QPVAR(additionalBuildings), []])}
