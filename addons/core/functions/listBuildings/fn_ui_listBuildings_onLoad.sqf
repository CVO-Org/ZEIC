#include "..\..\script_component.hpp"

/*
* Builds the List Buildings dialog: category, maximum number of templates, mark positions.
* Confirming calls PFUNC(ui_listBuildings).
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

private _categories = call PFUNC(interiorFill_categories);
_display setVariable [QPVAR(categories), [""] + (_categories apply { _x select 1 })];

private _ctx = [_display, LLSTRING(LB_Title)] call PFUNC(ui_dialogCreate);

[_ctx, "category", LLSTRING(IF_Category), [LLSTRING(LB_CategoryAll)] + (_categories apply { _x select 0 }), missionNamespace getVariable [QPVAR(UiListCategory), 0]] call PFUNC(ui_dialogCombo);
[_ctx, "max", LLSTRING(LB_Max), [0, 15, 1], missionNamespace getVariable [QPVAR(UiListMax), 15], LLSTRING(LB_MaxTip)] call PFUNC(ui_dialogSlider);
[_ctx, "positions", LLSTRING(LB_Positions), missionNamespace getVariable [QPVAR(UiListPositions), false], LLSTRING(LB_PositionsTip)] call PFUNC(ui_dialogCheckbox);

[_ctx, LLSTRING(LB_Description), LLSTRING(LB_Confirm), {
	PVAR(UiListCategory) = _this getVariable ["category", 0];
	PVAR(UiListMax) = _this getVariable ["max", 15];
	PVAR(UiListPositions) = _this getVariable ["positions", false];
	[(_this getVariable QPVAR(categories)) select PVAR(UiListCategory), PVAR(UiListMax), PVAR(UiListPositions)] spawn PFUNC(ui_listBuildings);
	true
}] call PFUNC(ui_dialogFinish);
