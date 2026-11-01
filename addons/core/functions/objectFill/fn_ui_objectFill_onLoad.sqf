#include "..\..\script_component.hpp"

/*
* Builds the Object Fill dialog: type, fill percent and (outside Eden) object mode.
* Starts with the last used values; confirming calls PFUNC(ui_objectFill).
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

private _object = missionNamespace getVariable [QPVAR(UiLastObject), objNull];
private _title = if (isNull _object) then { LLSTRING(OF_Title) } else {
	format ["%1 - %2", LLSTRING(OF_Title), getText (configOf _object >> "displayName")]
};

private _ctx = [_display, _title] call PFUNC(ui_dialogCreate);

// Random, then the types of CfgZEIC_ObjectFill by their "order"
private _types = ("true" configClasses (configFile >> "CfgZEIC_ObjectFill" >> "Types")) apply { [getNumber (_x >> "order"), getText (_x >> "displayName"), configName _x] };
_types sort true;
_types = [[LLSTRING(OF_TypeRandom), ""]] + (_types apply { [_x select 1, _x select 2] });
_display setVariable [QPVAR(types), _types apply { _x select 1 }];

private _last = (_types findIf { (_x select 1) isEqualTo (missionNamespace getVariable [QPVAR(UiObjectFillType), ""]) }) max 0;
[_ctx, "type", LLSTRING(OF_Type), _types apply { _x select 0 }, _last] call PFUNC(ui_dialogCombo);

[_ctx, "percent", LLSTRING(OF_Percent), [10, 100, 10], missionNamespace getVariable [QPVAR(UiObjectFillPercent), 30], LLSTRING(OF_PercentTip)] call PFUNC(ui_dialogSlider);

// Eden always places editable entities
if (!is3DEN) then {
	[_ctx, "objects", LLSTRING(IF_Objects),
		[LLSTRING(IF_ObjectsSimple), LLSTRING(IF_ObjectsNormal), LLSTRING(IF_ObjectsEditable)],
		missionNamespace getVariable [QPVAR(UiObjectFillObjects), OBJECT_MODE_SIMPLE],
		[LLSTRING(IF_ObjectsSimpleTip), LLSTRING(IF_ObjectsNormalTip), LLSTRING(IF_ObjectsEditableTip)]
	] call PFUNC(ui_dialogToolbox);
};

[_ctx, [LLSTRING(OF_Description), LLSTRING(OF_Shortcut)], LLSTRING(OF_Confirm), {
	[
		(_this getVariable QPVAR(types)) select (_this getVariable ["type", 0]),
		_this getVariable ["percent", 30],
		_this getVariable ["objects", OBJECT_MODE_SIMPLE]
	] call PFUNC(ui_objectFill);
	true
}] call PFUNC(ui_dialogFinish);
