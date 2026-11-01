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
private _title = if (isNull _bld) then { LLSTRING(IF_Title) } else {
	format ["%1 - %2", LLSTRING(IF_Title), getText (configOf _bld >> "displayName")]
};

private _ctx = [_display, _title] call PFUNC(ui_dialogCreate);

private _categories = call PFUNC(interiorFill_categories);

// "Alt: ... , Ctrl: Military with the last settings, ..." from the categories' shortcuts
private _shortcuts = format [LLSTRING(IF_Shortcut), (_categories select { (_x select 2) != "" } apply {
	", " + format [LLSTRING(IF_ShortcutCategory), ((_x select 2) splitString "+" apply { (toUpper (_x select [0, 1])) + (_x select [1]) }) joinString "+", _x select 0]
}) joinString ""] + ".";
[_ctx, "category", LLSTRING(IF_Category), _categories apply { _x select 0 }, missionNamespace getVariable [QPVAR(UiInteriorType), 0]] call PFUNC(ui_dialogCombo);

[_ctx, "radius", LLSTRING(IF_Radius), [0, 250, 5], missionNamespace getVariable [QPVAR(UiInteriorRadius), 0], LLSTRING(IF_RadiusTip), missionNamespace getVariable [QPVAR(UiLastPosition), []]] call PFUNC(ui_dialogSlider);
[_ctx, "chance", LLSTRING(IF_Chance), [10, 100, 10], missionNamespace getVariable [QPVAR(UiInteriorChance), 100], LLSTRING(IF_ChanceTip)] call PFUNC(ui_dialogSlider);

// Eden always places editable entities and can't make buildings indestructible
if (!is3DEN) then {
	[_ctx, "objects", LLSTRING(IF_Objects),
		[LLSTRING(IF_ObjectsSimple), LLSTRING(IF_ObjectsNormal), LLSTRING(IF_ObjectsEditable)],
		missionNamespace getVariable [QPVAR(UiInteriorObjects), OBJECT_MODE_SIMPLE],
		[LLSTRING(IF_ObjectsSimpleTip), LLSTRING(IF_ObjectsNormalTip), LLSTRING(IF_ObjectsEditableTip)]
	] call PFUNC(ui_dialogToolbox);

	[_ctx, "damage", LLSTRING(IF_AllowDamage), missionNamespace getVariable [QPVAR(UiInteriorDamage), false], LLSTRING(IF_AllowDamageTip)] call PFUNC(ui_dialogCheckbox);
};

[_ctx, [LLSTRING(IF_Description), _shortcuts], LLSTRING(IF_Confirm), {
	[
		_this getVariable ["category", 0],
		_this getVariable ["radius", 0],
		_this getVariable ["objects", OBJECT_MODE_SIMPLE],
		_this getVariable ["damage", false],
		_this getVariable ["chance", 100]
	] call PFUNC(ui_interiorFill);
	true
}] call PFUNC(ui_dialogFinish);
