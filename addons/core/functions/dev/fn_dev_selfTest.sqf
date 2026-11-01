#include "..\..\script_component.hpp"

/*
* Runs the ZEIC self test. Starts on every scenario start (postInit) when the mod is built with
* _ZEIC_DEV_ 1 (dev builds, see addons\main\script_dev.hpp); release builds set it to 0.
* Can also be run by hand from the debug console: [] call ZEIC_fnc_dev_selfTest;
*
* Every check writes one line to the RPT, prefixed with [ZEIC TEST]; a summary follows at the end.
* Test buildings are spawned in a 1.2 x 1 km test area and left in place for inspection.
* Only terrains with a known test area are supported (VR, Altis).
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

if (!isServer || {!hasInterface} || {is3DEN}) exitWith {};

private _origin = switch (toLowerANSI worldName) do {
	case "vr": { [1000, 1000, 0] };
	case "altis": { [23500, 18200, 0] }; // Almyra
	default { [] };
};
if (_origin isEqualTo []) exitWith {
	diag_log text format ["[ZEIC TEST] SKIP self test: no test area on %1 (see ZEIC_fnc_dev_selfTest)", worldName];
};

PVAR(dev_origin) = _origin;
PVAR(dev_results) = [];

[] spawn {
	// Give the mission a moment to settle (Zeus, other mods' postInit)
	sleep 5;

	diag_log text format ["[ZEIC TEST] ===== start | %1 at %2 | ZEN %3 | GM %4 | CUP %5 =====",
		worldName,
		PVAR(dev_origin),
		isClass (configFile >> "CfgPatches" >> "zen_common"),
		isClass (configFile >> "CfgPatches" >> "gm_core"),
		isClass (configFile >> "CfgPatches" >> "CUP_Editor_Buildings_Config")
	];

	{ call _x } forEach [
		PFUNC(dev_test_addon),
		PFUNC(dev_test_scriptApi),
		PFUNC(dev_test_mergedCases),
		PFUNC(dev_test_createTemplate),
		PFUNC(dev_test_queue),
		PFUNC(dev_test_objectModes),
		PFUNC(dev_test_configTemplates),
		PFUNC(dev_test_templateObjects),
		PFUNC(dev_test_saveScheme),
		PFUNC(dev_test_missionTemplates),
		PFUNC(dev_test_garrison),
		PFUNC(dev_test_garrisonUnits),
		PFUNC(dev_test_garrisonTrigger),
		PFUNC(dev_test_advancedFill),
		PFUNC(dev_test_advancedFillCollision),
		PFUNC(dev_test_rowOrder),
		PFUNC(dev_test_dialog),
		PFUNC(dev_test_garrisonDialog),
		PFUNC(dev_test_moduleDialogs),
		PFUNC(dev_test_shortcuts)
	];

	private _passed = { _x } count PVAR(dev_results);
	private _summary = format ["[ZEIC TEST] ===== done | %1 passed | %2 failed =====", _passed, count PVAR(dev_results) - _passed];
	diag_log text _summary;
	systemChat _summary;
};
