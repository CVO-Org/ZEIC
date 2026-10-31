#include "..\..\script_component.hpp"

/*
* Builds the Object Switch dialog: the set to convert to and the radius.
* Only sets whose mod is loaded are listed; each entry keeps its set ID for PFUNC(ui_objectSwitch).
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

// [name, set ID in PFUNC(ui_objectSwitch), required CfgPatches class ("" = vanilla)]
private _sets = [
	[LLSTRING(OS_SetDesert), 0, ""],
	[LLSTRING(OS_SetJungle), 1, ""],
	[LLSTRING(OS_SetWoodland), 2, ""],
	[LLSTRING(OS_SetDesertCUP), 3, "CUP_Core"],
	[LLSTRING(OS_SetWoodlandCUP), 4, "CUP_Core"],
	[LLSTRING(OS_SetBrownSOG), 5, "vn_data_f"],
	[LLSTRING(OS_SetGreenSOG), 6, "vn_data_f"]
] select { (_x select 2) == "" || {isClass (configFile >> "CfgPatches" >> (_x select 2))} };
_display setVariable [QPVAR(sets), _sets apply { _x select 1 }];

private _ctx = [_display, LLSTRING(OS_Title)] call PFUNC(ui_dialogCreate);

private _last = (_sets findIf { (_x select 1) == (missionNamespace getVariable [QPVAR(UiSwitchCombo), 0]) }) max 0;
[_ctx, "set", LLSTRING(OS_Set), _sets apply { _x select 0 }, _last, LLSTRING(OS_SetTip)] call PFUNC(ui_dialogCombo);

[_ctx, "radius", LLSTRING(OS_Radius), [5, 250, 5], missionNamespace getVariable [QPVAR(UiSwitchRadius), 50], LLSTRING(OS_RadiusTip)] call PFUNC(ui_dialogSlider);

[_ctx, LLSTRING(OS_Description), LLSTRING(OS_Confirm), {
	[
		(_this getVariable QPVAR(sets)) select (_this getVariable ["set", 0]),
		_this getVariable ["radius", 50]
	] call PFUNC(ui_objectSwitch);
	true
}] call PFUNC(ui_dialogFinish);
