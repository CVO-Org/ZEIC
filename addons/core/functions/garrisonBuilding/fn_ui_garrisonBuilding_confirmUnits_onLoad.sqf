#include "..\..\script_component.hpp"

/*
* Builds the prompt of PFUNC(ui_garrisonBuilding_confirmUnits): the unit count, "Yes" and "Back".
* "Back", Escape or closing it any other way reopens the module's dialog.
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

(uiNamespace getVariable [QPVAR(confirmUnits), []]) params [["_title", ""], ["_units", 0], ["_buildings", 0], ["_onYes", {}], ["_args", []], ["_dialog", ""]];

private _ctx = [_display, _title] call PFUNC(ui_dialogCreate);
{
	private _label = [_ctx, QPVAR(ctrlLabel), [_ctx get "x", _ctx get "y", UI_W(26), UI_H(1)]] call PFUNC(ui_dialogAdd);
	_label ctrlSetText _x;
	_ctx set ["y", (_ctx get "y") + UI_H(1) + UI_GAP];
} forEach [
	format [LLSTRING(ConfirmUnits), GARRISON_CONFIRM_UNITS],
	format [LLSTRING(ConfirmUnits_Count), _units, _buildings]
];

[_ctx, LLSTRING(ConfirmUnits_Description), LLSTRING(Yes), {
	(uiNamespace getVariable [QPVAR(confirmUnits), []]) params ["", "", "", ["_onYes", {}], ["_args", []]];
	uiNamespace setVariable [QPVAR(confirmUnits), nil];
	_args call _onYes;
	true
}] call PFUNC(ui_dialogFinish);

// The Cancel button of PFUNC(ui_dialogFinish) is the second to last control
((_ctx get "controls") select -2) ctrlSetText LLSTRING(Back);

_display setVariable [QPVAR(dialog), _dialog];
_display displayAddEventHandler ["Unload", {
	params ["_display", "_exitCode"];
	if (_exitCode == 1) exitWith {};
	uiNamespace setVariable [QPVAR(confirmUnits), nil];
	(_display getVariable [QPVAR(dialog), ""]) spawn { [_this] call PFUNC(ui_openDialog) };
}];
