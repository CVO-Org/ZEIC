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
private _subtitle = if (isNull _bld) then { "" } else {
	format ["%1 - %2 m",
		getText (configOf _bld >> "displayName"),
		round ((missionNamespace getVariable [QPVAR(UiLastPosition), getPos _bld]) distance2D _bld)
	]
};

private _ctx = [_display, LLSTRING(IF_Title), _subtitle] call PFUNC(ui_dialogCreate);

private _categories = call PFUNC(interiorFill_categories);
[_ctx, "category", LLSTRING(IF_Category), _categories apply { _x select 0 }, missionNamespace getVariable [QPVAR(UiInteriorType), 0]] call PFUNC(ui_dialogSegments);

[_ctx, "radius", LLSTRING(IF_Radius), [0, 250, 10], missionNamespace getVariable [QPVAR(UiInteriorRadius), 0], {
	if (_this == 0) then { LLSTRING(IF_RadiusNearest) } else { format [LLSTRING(UI_Meters), _this] }
}] call PFUNC(ui_dialogSlider);

// Eden always places editable entities and can't make buildings indestructible
if (!is3DEN) then {
	[_ctx, "objects", LLSTRING(IF_Objects),
		[LLSTRING(IF_ObjectsSimple), LLSTRING(IF_ObjectsNormal), LLSTRING(IF_ObjectsEditable)],
		missionNamespace getVariable [QPVAR(UiInteriorObjects), OBJECT_MODE_SIMPLE],
		[LLSTRING(IF_ObjectsSimpleTip), LLSTRING(IF_ObjectsNormalTip), LLSTRING(IF_ObjectsEditableTip)]
	] call PFUNC(ui_dialogSegments);

	[_ctx, "damage", LLSTRING(IF_AllowDamage), missionNamespace getVariable [QPVAR(UiInteriorDamage), false], LLSTRING(IF_AllowDamageTip)] call PFUNC(ui_dialogToggle);
};

[_ctx, LLSTRING(IF_Hint), LLSTRING(IF_Confirm), {
	[
		_this getVariable ["category", 0],
		_this getVariable ["radius", 0],
		_this getVariable ["objects", OBJECT_MODE_SIMPLE],
		_this getVariable ["damage", false]
	] call PFUNC(ui_interiorFill);
}] call PFUNC(ui_dialogFinish);
