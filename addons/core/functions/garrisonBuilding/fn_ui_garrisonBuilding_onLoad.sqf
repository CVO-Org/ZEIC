#include "..\..\script_component.hpp"

/*
* Builds the Garrison Building dialog: the faction picker (see PFUNC(ui_garrisonBuilding_factionPicker)),
* radius and percentages, and the unit estimate below the sliders (see PFUNC(ui_garrisonBuilding_estimate)).
* Confirming calls PFUNC(ui_garrisonBuilding).
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
private _title = if (isNull _bld) then { LLSTRING(ModuleGarrisonBuilding_DisplayName) } else {
	format ["%1 - %2", LLSTRING(ModuleGarrisonBuilding_DisplayName), getText (configOf _bld >> "displayName")]
};

private _ctx = [_display, _title] call PFUNC(ui_dialogCreate);

[_ctx] call PFUNC(ui_garrisonBuilding_factionPicker);

private _fnc_estimate = { [_this select 0] call PFUNC(ui_garrisonBuilding_estimate) };
[_ctx, "radius", LLSTRING(Radius), [0, 250, 5], missionNamespace getVariable [QPVAR(UiGarrisonRadius), 0], LLSTRING(Radius_Tooltip), _bld, _fnc_estimate] call PFUNC(ui_dialogSlider);
[_ctx, "percent", LLSTRING(ModuleGarrisonBuilding_Buildings), [10, 100, 10], missionNamespace getVariable [QPVAR(UiGarrisonPercent), 50], LLSTRING(ModuleGarrisonBuilding_Buildings_Tooltip), [], _fnc_estimate] call PFUNC(ui_dialogSlider);
[_ctx, "positions", LLSTRING(ModuleGarrisonBuilding_Positions), [10, 100, 10], missionNamespace getVariable [QPVAR(UiGarrisonPositions), 50], LLSTRING(ModuleGarrisonBuilding_Positions_Tooltip), [], _fnc_estimate] call PFUNC(ui_dialogSlider);
_display setVariable ["estimate_ctrl", [_ctx, QPVAR(ctrlLabel), [_ctx, ""] call PFUNC(ui_dialogRow)] call PFUNC(ui_dialogAdd)];
[_display] call PFUNC(ui_garrisonBuilding_estimate);
[_ctx, "dynamic", LLSTRING(ModuleGarrisonBuilding_DynamicSimulation), missionNamespace getVariable [QPVAR(UiGarrisonDynamic), false], LLSTRING(ModuleGarrisonBuilding_DynamicSimulation_Tooltip)] call PFUNC(ui_dialogCheckbox);
[_ctx, "trigger", LLSTRING(ModuleGarrisonBuilding_Trigger), missionNamespace getVariable [QPVAR(UiCreateTrigger), false], LLSTRING(ModuleGarrisonBuilding_Trigger_Tooltip)] call PFUNC(ui_dialogCheckbox);

[_ctx, [LLSTRING(ModuleGarrisonBuilding_Description), LLSTRING(ModuleGarrisonBuilding_Shortcuts)], LLSTRING(ModuleGarrisonBuilding_Confirm), {
	private _selection = _this getVariable [QPVAR(selection), []];
	if (_selection isEqualTo []) exitWith {
		[LLSTRING(ModuleGarrisonBuilding_NoFaction), "ERROR"] call PFUNC(misc_logMsg);
		false
	};
	[_selection] call (_this getVariable QPVAR(rememberPair));

	[
		_selection joinString "#",
		_this getVariable ["positions", 50],
		_this getVariable ["dynamic", false],
		_this getVariable ["trigger", false],
		_this getVariable ["radius", 0],
		_this getVariable ["percent", 50]
	] call PFUNC(ui_garrisonBuilding);
	true
}] call PFUNC(ui_dialogFinish);

[_display] call PFUNC(ui_garrisonBuilding_selectPair);
