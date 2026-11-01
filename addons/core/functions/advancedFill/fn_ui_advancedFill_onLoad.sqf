#include "..\..\script_component.hpp"

/*
* Builds the Advanced Fill dialog: three tabs, Interior, Garrison and Settings, as buttons at the top that show
* one tab's rows at a time. Interior and Garrison each have a checkbox in their tab button; a part that is off
* is greyed out, and the two can never both be off: turning off the last one turns the other back on.
* - Interior: category, object mode and damage, as in Interior Fill.
* - Garrison: the faction picker (see PFUNC(ui_garrisonBuilding_factionPicker)), positions, dynamic simulation, trigger.
* - Settings: radius, share of the buildings, the unit estimate (see PFUNC(ui_garrisonBuilding_estimate)), and the
*   collision check with what gives way at blocked positions (see PFUNC(advancedFill_start)).
* Starts with the last used settings; confirming calls PFUNC(ui_advancedFill).
*
* Display values besides the rows: "interior", "garrison" (parts on) <BOOL>, "tab" (shown tab) <NUMBER>.
* Code on the display: QPVAR(setPart) [display, "interior" or "garrison", on], QPVAR(showTab) [display, index].
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
private _title = if (isNull _bld) then { LLSTRING(ModuleAdvancedFill_DisplayName) } else {
	format ["%1 - %2", LLSTRING(ModuleAdvancedFill_DisplayName), getText (configOf _bld >> "displayName")]
};
private _last = missionNamespace getVariable [QPVAR(UiAdvancedFill), createHashMap];

private _ctx = [_display, _title] call PFUNC(ui_dialogCreate);
private _controls = _ctx get "controls";

_display setVariable ["interior", _last getOrDefault ["interior", true]];
_display setVariable ["garrison", _last getOrDefault ["garrison", true]];

// ---- tab buttons: Interior and Garrison with their checkbox on the left
private _x0 = _ctx get "x";
private _tabY = _ctx get "y";
private _tabButtons = [];
{
	_x params ["_part", "_label"];
	private _left = _x0 + UI_W(_forEachIndex * 8.7);
	private _buttonLeft = _left;
	if (_part != "") then {
		private _checkbox = [_ctx, QPVAR(ctrlCheckbox), [_left, _tabY, UI_W(1), UI_H(1)]] call PFUNC(ui_dialogAdd);
		_checkbox ctrlSetTooltip LLSTRING(ModuleAdvancedFill_Part_Tooltip);
		_checkbox setVariable [QPVAR(key), _part];
		_checkbox ctrlAddEventHandler ["CheckedChanged", {
			params ["_checkbox", "_checked"];
			private _display = ctrlParent _checkbox;
			private _part = _checkbox getVariable QPVAR(key);
			// Also fired when the other part turns this one back on
			if ((_display getVariable _part) isEqualTo (_checked == 1)) exitWith {};
			[_display, _part, _checked == 1] call (_display getVariable QPVAR(setPart));
		}];
		_display setVariable [format ["%1_ctrl", _part], _checkbox];
		_buttonLeft = _left + UI_W(1);
	};
	private _button = [_ctx, QPVAR(ctrlTab), [_buttonLeft, _tabY, _left + UI_W(8.6) - _buttonLeft, UI_H(1)]] call PFUNC(ui_dialogAdd);
	_button ctrlSetText _label;
	_button setVariable [QPVAR(index), _forEachIndex];
	_button ctrlAddEventHandler ["ButtonClick", {
		params ["_button"];
		private _display = ctrlParent _button;
		[_display, _button getVariable QPVAR(index)] call (_display getVariable QPVAR(showTab));
	}];
	_tabButtons pushBack _button;
} forEach [
	["interior", LLSTRING(ModuleAdvancedFill_Interior)],
	["garrison", LLSTRING(ModuleAdvancedFill_Garrison)],
	["", LLSTRING(ModuleAdvancedFill_Settings)]
];
_display setVariable [QPVAR(tabButtons), _tabButtons];

// ---- tab contents: all start below the buttons, the dialog is as tall as the tallest one
private _contentY = _tabY + UI_H(1) + UI_H(0.5);
private _bottom = _contentY;
private _tabControls = [];
private _fnc_tab = {
	params ["_code"];
	_ctx set ["y", _contentY];
	private _first = count _controls;
	call _code;
	_bottom = _bottom max (_ctx get "y");
	_tabControls pushBack (_controls select [_first]);
};

// Interior. Eden always places editable entities and can't make buildings indestructible.
[{
	[_ctx, "category", LLSTRING(Category), (call PFUNC(interiorFill_categories)) apply { _x select 0 }, _last getOrDefault ["category", missionNamespace getVariable [QPVAR(UiInteriorType), 0]]] call PFUNC(ui_dialogCombo);
	if (!is3DEN) then {
		[_ctx, "objects", LLSTRING(ObjectMode),
			[LLSTRING(ObjectMode_Simple), LLSTRING(ObjectMode_Normal), LLSTRING(ObjectMode_Editable)],
			_last getOrDefault ["objects", OBJECT_MODE_SIMPLE],
			[LLSTRING(ObjectMode_Simple_Tooltip), LLSTRING(ObjectMode_Normal_Tooltip), LLSTRING(ObjectMode_Editable_Tooltip)]
		] call PFUNC(ui_dialogToolbox);
		[_ctx, "damage", LLSTRING(ModuleInteriorFill_AllowDamage), _last getOrDefault ["damage", false], LLSTRING(ModuleInteriorFill_AllowDamage_Tooltip)] call PFUNC(ui_dialogCheckbox);
	};
}] call _fnc_tab;

// Garrison
private _fnc_estimate = { (_this select 0) call ((_this select 0) getVariable QPVAR(updateEstimate)) };
[{
	[_ctx] call PFUNC(ui_garrisonBuilding_factionPicker);
	[_ctx, "positions", LLSTRING(ModuleGarrisonBuilding_Positions), [10, 100, 10], _last getOrDefault ["positions", 50], LLSTRING(ModuleGarrisonBuilding_Positions_Tooltip), [], _fnc_estimate] call PFUNC(ui_dialogSlider);
	[_ctx, "dynamic", LLSTRING(ModuleGarrisonBuilding_DynamicSimulation), _last getOrDefault ["dynamic", false], LLSTRING(ModuleGarrisonBuilding_DynamicSimulation_Tooltip)] call PFUNC(ui_dialogCheckbox);
	[_ctx, "trigger", LLSTRING(ModuleGarrisonBuilding_Trigger), _last getOrDefault ["trigger", false], LLSTRING(ModuleGarrisonBuilding_Trigger_Tooltip)] call PFUNC(ui_dialogCheckbox);
}] call _fnc_tab;

// Settings
[{
	[_ctx, "radius", LLSTRING(Radius), [0, 250, 5], _last getOrDefault ["radius", 0], LLSTRING(Radius_Tooltip), _bld, _fnc_estimate] call PFUNC(ui_dialogSlider);
	[_ctx, "percent", LLSTRING(Percentage), [10, 100, 10], _last getOrDefault ["percent", 50], LLSTRING(Percentage_Tooltip), [], _fnc_estimate] call PFUNC(ui_dialogSlider);
	_display setVariable ["estimate_ctrl", [_ctx, QPVAR(ctrlLabel), [_ctx, ""] call PFUNC(ui_dialogRow)] call PFUNC(ui_dialogAdd)];
	[_ctx, "collision", LLSTRING(ModuleAdvancedFill_Collision), _last getOrDefault ["collision", true], LLSTRING(ModuleAdvancedFill_Collision_Tooltip)] call PFUNC(ui_dialogCheckbox);
	[_ctx, "blocked", LLSTRING(ModuleAdvancedFill_Blocked),
		[LLSTRING(ModuleAdvancedFill_Blocked_UnitsGiveWay), LLSTRING(ModuleAdvancedFill_Blocked_FurnitureGivesWay)],
		_last getOrDefault ["blocked", COLLISION_UNITS_GIVE_WAY], LLSTRING(ModuleAdvancedFill_Blocked_Tooltip)
	] call PFUNC(ui_dialogCombo);
}] call _fnc_tab;

_display setVariable [QPVAR(tabControls), _tabControls];
_ctx set ["y", _bottom];

// The unit estimate only means something with the garrison on
_display setVariable [QPVAR(updateEstimate), {
	params ["_display"];
	if (_display getVariable ["garrison", false]) then {
		[_display] call PFUNC(ui_garrisonBuilding_estimate);
	} else {
		(_display getVariable ["estimate_ctrl", controlNull]) ctrlSetText "";
	};
}];

// Shows the tab, greys out a part that is off, marks the shown tab button
_display setVariable [QPVAR(updateTabs), {
	params ["_display"];
	private _tab = _display getVariable ["tab", 0];
	private _color = [
		profileNamespace getVariable ["GUI_BCG_RGB_R", 0.13],
		profileNamespace getVariable ["GUI_BCG_RGB_G", 0.54],
		profileNamespace getVariable ["GUI_BCG_RGB_B", 0.21],
		profileNamespace getVariable ["GUI_BCG_RGB_A", 0.8]
	];
	{
		private _part = ["interior", "garrison", ""] select _forEachIndex;
		private _on = _part == "" || {_display getVariable [_part, true]};
		private _shown = _forEachIndex == _tab;
		{
			_x ctrlShow _shown;
			_x ctrlEnable _on;
			_x ctrlSetFade ([0.6, 0] select _on);
			_x ctrlCommit 0;
		} forEach _x;

		private _button = (_display getVariable QPVAR(tabButtons)) select _forEachIndex;
		_button ctrlSetBackgroundColor ([[0, 0, 0, 0.5], _color] select _shown);
		_button ctrlSetTextColor [1, 1, 1, [0.4, 1] select _on];
	} forEach (_display getVariable QPVAR(tabControls));
	{
		private _checkbox = _display getVariable format ["%1_ctrl", _x];
		if (cbChecked _checkbox isNotEqualTo (_display getVariable _x)) then { _checkbox cbSetChecked (_display getVariable _x) };
	} forEach ["interior", "garrison"];
	_display call (_display getVariable QPVAR(updateEstimate));
}];

// Turns a part on or off. Both off isn't possible: the other part is turned back on.
_display setVariable [QPVAR(setPart), {
	params ["_display", "_part", "_on"];
	_display setVariable [_part, _on];
	if (!(_display getVariable "interior") && {!(_display getVariable "garrison")}) then {
		_display setVariable [["interior", "garrison"] select (_part == "interior"), true];
	};
	_display call (_display getVariable QPVAR(updateTabs));
}];

_display setVariable [QPVAR(showTab), {
	params ["_display", "_tab"];
	_display setVariable ["tab", _tab];
	_display call (_display getVariable QPVAR(updateTabs));
}];

[_ctx, [LLSTRING(ModuleAdvancedFill_Description), LLSTRING(ModuleAdvancedFill_Shortcuts)], LLSTRING(ModuleAdvancedFill_Confirm), {
	private _garrison = _this getVariable ["garrison", false];
	private _selection = _this getVariable [QPVAR(selection), []];
	if (_garrison && {_selection isEqualTo []}) exitWith {
		[LLSTRING(ModuleAdvancedFill_NoFaction), "ERROR"] call PFUNC(misc_logMsg);
		[_this, 1] call (_this getVariable QPVAR(showTab));
		false
	};
	if (_garrison) then { [_selection] call (_this getVariable QPVAR(rememberPair)) };

	[createHashMapFromArray [
		["interior", _this getVariable ["interior", false]],
		["category", _this getVariable ["category", 0]],
		["objects", _this getVariable ["objects", OBJECT_MODE_SIMPLE]],
		["damage", _this getVariable ["damage", false]],
		["garrison", _garrison],
		["pair", _selection],
		["positions", _this getVariable ["positions", 50]],
		["dynamic", _this getVariable ["dynamic", false]],
		["trigger", _this getVariable ["trigger", false]],
		["radius", _this getVariable ["radius", 0]],
		["percent", _this getVariable ["percent", 50]],
		["collision", _this getVariable ["collision", true]],
		["blocked", _this getVariable ["blocked", COLLISION_UNITS_GIVE_WAY]]
	]] call PFUNC(ui_advancedFill);
	true
}] call PFUNC(ui_dialogFinish);

// Start with the most recent pair (the last one confirmed here or in Garrison Building), on the first tab whose part is on
[_display] call PFUNC(ui_garrisonBuilding_selectPair);
[_display, [1, 0] select (_display getVariable "interior")] call (_display getVariable QPVAR(showTab));
