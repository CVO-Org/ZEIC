#include "..\..\script_component.hpp"

/*
* Self test: Templates and categories from the mission's description.ext (the test missions have them).
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

// T12 mission templates and categories (description.ext, #24)
if (!isClass (missionConfigFile >> "CfgZEIC" >> "zeic_test")) exitWith {
	diag_log text "[ZEIC TEST] SKIP T12 the mission has no test templates (see description.ext of the test missions)";
};

private _categoryClasses = (call PFUNC(interiorFill_categories)) apply { _x select 1 };
["T12.1 categories sorted by order: mil, civ, cbrn first", (_categoryClasses select [0, 3]) isEqualTo ["mil", "civ", "cbrn"], _categoryClasses] call PFUNC(dev_check);
["T12.2 mission category listed", "zeic_test" in _categoryClasses] call PFUNC(dev_check);
private _missionFound = ["Land_i_House_Small_03_V1_F", "zeic_test", true] call PFUNC(findTemplates);
["T12.3 mission category: template with missing object skipped", count _missionFound == 1, count _missionFound] call PFUNC(dev_check);
["T12.4 mission template added to an addon category",
	[["Land_Pallets_F", [0, 0, 0.5], 45]] in (["Land_i_House_Small_03_V1_F", "mil", true] call PFUNC(findTemplates))] call PFUNC(dev_check);
