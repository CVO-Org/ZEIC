#include "..\..\script_component.hpp"

/*
* Builds the Object Switch dialog: the set to convert to and the radius.
* The sets come from CfgZEIC_ObjectSwitch: only those of loaded addons exist.
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

// The sets of the loaded addons (CfgZEIC_ObjectSwitch)
private _sets = call PFUNC(objectSwitch_sets);
_display setVariable [QPVAR(sets), _sets apply { _x select 1 }];

private _ctx = [_display, LLSTRING(ModuleObjectSwitch_DisplayName)] call PFUNC(ui_dialogCreate);

private _last = (_sets findIf { (_x select 1) isEqualTo (missionNamespace getVariable [QPVAR(UiSwitchCombo), "desert"]) }) max 0;
[_ctx, "set", LLSTRING(ModuleObjectSwitch_Set), _sets apply { _x select 0 }, _last, LLSTRING(ModuleObjectSwitch_Set_Tooltip)] call PFUNC(ui_dialogCombo);

[_ctx, "radius", LLSTRING(Radius), [5, 250, 5], missionNamespace getVariable [QPVAR(UiSwitchRadius), 50], LLSTRING(ModuleObjectSwitch_Radius_Tooltip), missionNamespace getVariable [QPVAR(UiLastPosition), []]] call PFUNC(ui_dialogSlider);

[_ctx, LLSTRING(ModuleObjectSwitch_Description), LLSTRING(ModuleObjectSwitch_Confirm), {
	[
		(_this getVariable QPVAR(sets)) select (_this getVariable ["set", 0]),
		_this getVariable ["radius", 50]
	] call PFUNC(ui_objectSwitch);
	true
}] call PFUNC(ui_dialogFinish);
