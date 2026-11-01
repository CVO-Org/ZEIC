#include "..\..\script_component.hpp"

/*
* Builds the Interior Fill dialog: category, radius, and (outside Eden) object mode and damage.
* Starts with the last used values; confirming calls PFUNC(ui_interiorFill).
*
* Arguments:
* 0: Display <DISPLAY>
*
* Return Value:
* None
*
* Public: No
*/

params ["_display"];

private _bld = missionNamespace getVariable [QPVAR(UiLastBuilding), objNull];
private _title = if (isNull _bld) then { LLSTRING(ModuleInteriorFill_DisplayName) } else {
	format ["%1 - %2", LLSTRING(ModuleInteriorFill_DisplayName), getText (configOf _bld >> "displayName")]
};

private _ctx = [_display, _title] call PFUNC(ui_dialogCreate);

private _categories = call PFUNC(interiorFill_categories);

// One tooltip line per category with a shortcut ("Ctrl: Military"), below the Alt line
private _shortcuts = format [LLSTRING(ModuleInteriorFill_Shortcuts), (_categories select { (_x select 2) != "" } apply {
	"\n" + format [LLSTRING(ModuleInteriorFill_ShortcutCategory), ((_x select 2) splitString "+" apply { (toUpper (_x select [0, 1])) + (_x select [1]) }) joinString "+", _x select 0]
}) joinString ""];
[_ctx, "category", LLSTRING(Category), _categories apply { _x select 0 }, missionNamespace getVariable [QPVAR(UiInteriorType), 0]] call PFUNC(ui_dialogCombo);

[_ctx, "radius", LLSTRING(Radius), [0, 250, 5], missionNamespace getVariable [QPVAR(UiInteriorRadius), 0], LLSTRING(Radius_Tooltip), missionNamespace getVariable [QPVAR(UiLastPosition), []]] call PFUNC(ui_dialogSlider);
[_ctx, "chance", LLSTRING(Percentage), [10, 100, 10], missionNamespace getVariable [QPVAR(UiInteriorChance), 100], LLSTRING(Percentage_Tooltip)] call PFUNC(ui_dialogSlider);

// Eden always places editable entities and can't make buildings indestructible
if (!is3DEN) then {
	[_ctx, "objects", LLSTRING(ObjectMode),
		[LLSTRING(ObjectMode_Simple), LLSTRING(ObjectMode_Normal), LLSTRING(ObjectMode_Editable)],
		missionNamespace getVariable [QPVAR(UiInteriorObjects), OBJECT_MODE_SIMPLE],
		[LLSTRING(ObjectMode_Simple_Tooltip), LLSTRING(ObjectMode_Normal_Tooltip), LLSTRING(ObjectMode_Editable_Tooltip)]
	] call PFUNC(ui_dialogToolbox);

	[_ctx, "damage", LLSTRING(ModuleInteriorFill_AllowDamage), missionNamespace getVariable [QPVAR(UiInteriorDamage), false], LLSTRING(ModuleInteriorFill_AllowDamage_Tooltip)] call PFUNC(ui_dialogCheckbox);
};

[_ctx, [LLSTRING(ModuleInteriorFill_Description), _shortcuts], LLSTRING(ModuleInteriorFill_Confirm), {
	[
		_this getVariable ["category", 0],
		_this getVariable ["radius", 0],
		_this getVariable ["objects", OBJECT_MODE_SIMPLE],
		_this getVariable ["damage", false],
		_this getVariable ["chance", 100]
	] call PFUNC(ui_interiorFill);
	true
}] call PFUNC(ui_dialogFinish);
