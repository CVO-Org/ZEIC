#include "..\..\script_component.hpp"

/*
* Updates the unit estimate of a garrison dialog (the label stored as "estimate_ctrl" on the display):
* the share of the buildings within the radius (or the one building), each with its share of positions.
* Reads the display values "radius", "percent" and "positions". Which buildings get picked is random,
* so the units are the average over all candidates.
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

private _ctrl = _display getVariable ["estimate_ctrl", controlNull];
if (isNull _ctrl) exitWith {};
private _bld = missionNamespace getVariable [QPVAR(UiLastBuilding), objNull];
private _radius = _display getVariable ["radius", 0];

// The candidates only change with the radius
private _cache = _display getVariable [QPVAR(estimateCandidates), []];
if (_cache isEqualTo [] || {(_cache select 0) != _radius}) then {
	private _candidates = if (_radius > 0) then { [getPos _bld, _radius, 100] call PFUNC(garrisonBuilding_selectBuildings) } else { [_bld] - [objNull] };
	_cache = [_radius, _candidates apply { count (_x buildingPos -1) }];
	_display setVariable [QPVAR(estimateCandidates), _cache];
};
private _positions = _cache select 1;

private _buildings = if (_radius > 0) then { count ([_positions, _display getVariable ["percent", 50]] call PFUNC(misc_selectShare)) } else { count _positions };
private _units = 0;
{ _units = _units + _x } forEach ([_positions, _display getVariable ["positions", 50]] call PFUNC(garrisonBuilding_unitCounts));
if (_positions isNotEqualTo []) then { _units = round (_units * _buildings / count _positions) };

_ctrl ctrlSetText (switch (_buildings) do {
	case 0: { LLSTRING(ModuleGarrisonBuilding_EstimateNone) };
	case 1: { format [LLSTRING(ModuleGarrisonBuilding_EstimateSingle), _units] };
	default { format [LLSTRING(ModuleGarrisonBuilding_Estimate), _units, _buildings] };
});
