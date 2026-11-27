#include "..\..\script_component.hpp"

/*
* Called by the Interior Fill dialog (or a shortcut): saves the settings for next time, picks the buildings and
* starts the fill. The work itself is done by PFUNC(interiorFill_start).
*
* Arguments:
* 0: Category classes, e.g. ["mil", "civ"] <ARRAY of STRINGs> (an index in PFUNC(interiorFill_categories) works too)
* 1: Radius, 0 for the building under the module <NUMBER>
* 2: Object mode <NUMBER>
* 3: Allow damage <BOOL>
* 4: Share of the buildings in percent <NUMBER>
* 5: Remember the categories for next time <BOOL> (default: true; false for a category's shortcut)
*
* Return Value:
* None
*
* Public: No
*/

params [
		["_categories", [], [[], 0]],
		["_area", 0],
		["_objectMode", OBJECT_MODE_SIMPLE],
		["_allowDamage", false],
		["_chance", 100],
		["_rememberCategories", true]
	];

if (_categories isEqualType 0) then {
	private _all = call PFUNC(interiorFill_categories);
	_categories = [(_all param [_categories, _all select 0]) select 1];
};
if (_categories isEqualTo []) exitWith {
	[format [LLSTRING(NoCategory), LLSTRING(ModuleInteriorFill_DisplayName)], "ERROR"] call PFUNC(misc_logMsg);
};
private _fillArea = _area isNotEqualTo 0;

// Save UI Settings for next time
if (_rememberCategories) then { PVAR(UiInteriorCategories) = +_categories };
PVAR(UiInteriorRadius) = _area;
PVAR(UiInteriorObjects) = _objectMode;
PVAR(UiInteriorDamage) = _allowDamage;
PVAR(UiInteriorChance) = _chance;

private _bldTmp = missionNamespace getVariable [QPVAR(UiLastBuilding), objNull];
private _bldArr = [];

if (isNull _bldTmp || _fillArea) then {
	// Around the spot where the module was placed (the mouse is over the dialog by now)
	private _center = missionNamespace getVariable [QPVAR(UiLastPosition), screenToWorld getMousePosition];
	_bldTmp = nearestObjects [_center, ["Building"], [_area, 15] select (_area isEqualTo 0), true];
	// Candidates: buildings with positions, or with a template entry in one of the categories (e.g. bunkers, towers), or listed via PFUNC(addCustomHouse)
	_bldArr = _bldTmp select { [_x, _categories] call PFUNC(interiorFill_isCandidate) };

	if (_fillArea) then {
		// Chance: a random share of the buildings that aren't furnished yet (at least one)
		if (_chance < 100) then {
			_bldArr = [_bldArr select { isNull (_x getVariable [QPVAR(furnished), objNull]) && {!(_x getVariable [QPVAR(queued), false])} }, _chance] call PFUNC(misc_selectShare);
		};
	} else {
		_bldArr resize 1;
	};
} else {
	_bldArr = [_bldTmp];
};

_bldArr = _bldArr - [objNull];

// Don't continue if no objects were found.
if (_bldArr isEqualTo []) exitWith {
	[LLSTRING(ModuleInteriorFill_NoBuildingsFound), "INFO"] call PFUNC(misc_logMsg);
};

// Processed over several frames by the queue, see PFUNC(interiorFill_start).
[_bldArr, _categories, [_objectMode, _allowDamage]] call PFUNC(interiorFill_start);
