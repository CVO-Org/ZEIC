#include "..\..\script_component.hpp"

/*
* Builds the Garrison Building dialog. The units come from one of two lists, both with one row per
* faction + subcategory pair (side icon, flag, faction, subcategory):
* - Recently used: the last 5 pairs of this game session (uiNamespace).
* - All pairs, narrowed by the side and search filters.
* Picking in one list clears the other. Confirming calls PFUNC(ui_garrisonBuilding).
* Below the sliders an estimate of the units and buildings follows radius and percentages.
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
private _factions = call PFUNC(garrisonBuilding_factions);

// Recently used entries whose faction and subcategory still exist (the modset may have changed)
private _recent = (uiNamespace getVariable [QPVAR(garrisonRecent), []]) select {
	_x params ["_faction", "_subcat"];
	private _index = _factions findIf { (_x select 1) == _faction };
	_index != -1 && {((_factions select _index) select 4) findIf { (_x select 1) == _subcat } != -1}
};
_display setVariable [QPVAR(recent), _recent];
_display setVariable [QPVAR(selection), []];

// Columns of both lists: side icon, flag, faction, subcategory
#define PAIR_COLUMNS [0, 0.05, 0.11, 0.52]

// Adds one pair as a row: [list, faction info, subcategory info]
_display setVariable [QPVAR(addPair), {
	params ["_list", "_faction", "_subcat"];
	_faction params ["_name", "_class", "_side", "", "", "_flag"];
	_subcat params ["_subcatName", "_subcatClass", "_count"];
	private _row = _list lnbAddRow ["", "", _name, format ["%1 (%2)", _subcatName, _count]];
	_list lnbSetPicture [[_row, 0], SIDE_ICONS select _side];
	_list lnbSetPictureColor [[_row, 0], [[east, west, independent, civilian] select _side] call BIS_fnc_sideColor];
	_list lnbSetPictureColorSelected [[_row, 0], [1, 1, 1, 1]];
	_list lnbSetPicture [[_row, 1], _flag];
	_list lnbSetData [[_row, 0], _class + "#" + _subcatClass];
	{ _list lnbSetTooltip [[_row, _x], format ["%1 / %2", _class, _subcatClass]] } forEach [0, 1, 2, 3];
	_row
}];

// Fills the pair list from the side and search filters, keeps the selected pair if it is still shown.
// Every word of the search has to match the faction (name or class), the subcategory or a side keyword.
_display setVariable [QPVAR(fillPairs), {
	params ["_display"];
	private _list = _display getVariable "pairs_ctrl";
	private _side = [-1, 1, 0, 2, 3] select (_display getVariable ["side", 0]);
	private _words = (toLowerANSI (_display getVariable ["search", ""])) splitString " ";
	private _selected = (_display getVariable [QPVAR(selection), []]) joinString "#";
	private _fromRecent = lnbCurSelRow (_display getVariable ["recent_ctrl", controlNull]) > -1;
	private _sideWords = [
		"opfor east red " + localize "STR_EAST",
		"blufor west blue " + localize "STR_WEST",
		"indep independent guer guerrila resistance greenfor " + localize "STR_GUERRILA",
		"civ civilian " + localize "STR_CIVILIAN"
	] apply { toLowerANSI _x };

	_display setVariable [QPVAR(busy), true];
	lnbClear _list;
	private _keep = -1;
	{
		private _faction = _x;
		_faction params ["_name", "_class", "_factionSide", "", "_subcats"];
		if (_side == -1 || {_factionSide == _side}) then {
			{
				private _text = toLowerANSI ([_name, _class, _x select 0, _x select 1, _sideWords select _factionSide] joinString " ");
				if (_words findIf { (_text find _x) == -1 } == -1) then {
					private _row = [_list, _faction, _x] call (_display getVariable QPVAR(addPair));
					if ((_list lnbData [_row, 0]) == _selected) then { _keep = _row };
				};
			} forEach _subcats;
		};
	} forEach (call PFUNC(garrisonBuilding_factions));
	// A pair picked in the recently used list stays picked there
	if (!_fromRecent) then { _list lnbSetCurSelRow _keep };
	_display setVariable ["pairs", _keep];
	_display setVariable [QPVAR(busy), false];

	// A pair that is filtered out is no longer picked
	if (!_fromRecent && {_keep == -1}) then { _display setVariable [QPVAR(selection), []] };
}];

// Updates the estimate: the share of the buildings within the radius (or the one building), each with its share of positions.
// Which buildings get picked is random, so the units are the average over all candidates.
_display setVariable [QPVAR(updateEstimate), {
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
}];

private _ctx = [_display, _title] call PFUNC(ui_dialogCreate);

if (_recent isNotEqualTo []) then {
	// As tall as its entries (at most 5), so a short list leaves no empty space
	private _list = [_ctx, "recent", LLSTRING(ModuleGarrisonBuilding_Recent), count _recent, LLSTRING(ModuleGarrisonBuilding_Recent_Tooltip), {
		params ["_display", "_index"];
		if (_display getVariable [QPVAR(busy), false] || {_index < 0}) exitWith {};
		_display setVariable [QPVAR(selection), (_display getVariable QPVAR(recent)) select _index];

		// Clears the other list
		_display setVariable [QPVAR(busy), true];
		(_display getVariable "pairs_ctrl") lnbSetCurSelRow -1;
		_display setVariable [QPVAR(busy), false];
	}, nil, nil, PAIR_COLUMNS] call PFUNC(ui_dialogList);

	{
		_x params ["_faction", "_subcat"];
		private _factionInfo = _factions select (_factions findIf { (_x select 1) == _faction });
		private _subcatInfo = (_factionInfo select 4) select ((_factionInfo select 4) findIf { (_x select 1) == _subcat });
		[_list, _factionInfo, _subcatInfo] call (_display getVariable QPVAR(addPair));
	} forEach _recent;
};

[_ctx, "search", LLSTRING(ModuleGarrisonBuilding_Search), "", LLSTRING(ModuleGarrisonBuilding_Search_Tooltip), {
	params ["_display"];
	_display call (_display getVariable QPVAR(fillPairs));
}] call PFUNC(ui_dialogEdit);

[_ctx, "side", LLSTRING(ModuleGarrisonBuilding_Side), [LLSTRING(ModuleGarrisonBuilding_Side_All), localize "STR_WEST", localize "STR_EAST", localize "STR_GUERRILA", localize "STR_CIVILIAN"], 0, [], {
	params ["_display"];
	_display call (_display getVariable QPVAR(fillPairs));
}] call PFUNC(ui_dialogToolbox);

[_ctx, "pairs", LLSTRING(ModuleGarrisonBuilding_Faction), 7, "", {
	params ["_display", "_index", "_list"];
	if (_display getVariable [QPVAR(busy), false] || {_index < 0}) exitWith {};
	_display setVariable [QPVAR(selection), (_list lnbData [_index, 0]) splitString "#"];

	// Clears the other list
	_display setVariable [QPVAR(busy), true];
	(_display getVariable ["recent_ctrl", controlNull]) lnbSetCurSelRow -1;
	_display setVariable [QPVAR(busy), false];
}, nil, nil, PAIR_COLUMNS] call PFUNC(ui_dialogList);

private _fnc_estimate = { (_this select 0) call ((_this select 0) getVariable QPVAR(updateEstimate)) };
[_ctx, "radius", LLSTRING(Radius), [0, 250, 5], missionNamespace getVariable [QPVAR(UiGarrisonRadius), 0], LLSTRING(Radius_Tooltip), _bld, _fnc_estimate] call PFUNC(ui_dialogSlider);
[_ctx, "percent", LLSTRING(ModuleGarrisonBuilding_Buildings), [10, 100, 10], missionNamespace getVariable [QPVAR(UiGarrisonPercent), 50], LLSTRING(ModuleGarrisonBuilding_Buildings_Tooltip), [], _fnc_estimate] call PFUNC(ui_dialogSlider);
[_ctx, "positions", LLSTRING(ModuleGarrisonBuilding_Positions), [10, 100, 10], missionNamespace getVariable [QPVAR(UiGarrisonPositions), 50], LLSTRING(ModuleGarrisonBuilding_Positions_Tooltip), [], _fnc_estimate] call PFUNC(ui_dialogSlider);
_display setVariable ["estimate_ctrl", [_ctx, QPVAR(ctrlLabel), [_ctx, ""] call PFUNC(ui_dialogRow)] call PFUNC(ui_dialogAdd)];
_display call (_display getVariable QPVAR(updateEstimate));
[_ctx, "dynamic", LLSTRING(ModuleGarrisonBuilding_DynamicSimulation), missionNamespace getVariable [QPVAR(UiGarrisonDynamic), false], LLSTRING(ModuleGarrisonBuilding_DynamicSimulation_Tooltip)] call PFUNC(ui_dialogCheckbox);
[_ctx, "trigger", LLSTRING(ModuleGarrisonBuilding_Trigger), missionNamespace getVariable [QPVAR(UiCreateTrigger), false], LLSTRING(ModuleGarrisonBuilding_Trigger_Tooltip)] call PFUNC(ui_dialogCheckbox);

[_ctx, [LLSTRING(ModuleGarrisonBuilding_Description), LLSTRING(ModuleGarrisonBuilding_Shortcuts)], LLSTRING(ModuleGarrisonBuilding_Confirm), {
	private _selection = _this getVariable [QPVAR(selection), []];
	if (_selection isEqualTo []) exitWith {
		[LLSTRING(ModuleGarrisonBuilding_NoFaction), "ERROR"] call PFUNC(misc_logMsg);
		false
	};

	// Most recent first, at most 5
	private _recent = (uiNamespace getVariable [QPVAR(garrisonRecent), []]) - [_selection];
	_recent = ([_selection] + _recent) select [0, 5];
	uiNamespace setVariable [QPVAR(garrisonRecent), _recent];

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

// Start with the most recent pair, otherwise the last used pair, otherwise the last used faction's "Men" (or its first
// subcategory), otherwise the first "Men" of the list (or its first row)
_display call (_display getVariable QPVAR(fillPairs));
if (_recent isNotEqualTo []) exitWith {
	(_display getVariable "recent_ctrl") lnbSetCurSelRow 0;
};

private _list = _display getVariable "pairs_ctrl";
private _rows = (lnbSize _list) select 0;
if (_rows == 0) exitWith {};
private _data = [];
for "_i" from 0 to (_rows - 1) do { _data pushBack (_list lnbData [_i, 0]) };
private _lastFaction = missionNamespace getVariable [QPVAR(UiGarrisonFaction), ""];
private _index = _data find format ["%1#%2", _lastFaction, missionNamespace getVariable [QPVAR(UiGarrisonCategory), ""]];
if (_index == -1) then { _index = _data find format ["%1#EdSubcat_Personnel", _lastFaction] };
if (_index == -1) then { _index = _data findIf { ((_x splitString "#") param [0, ""]) == _lastFaction } };
if (_index == -1) then { _index = _data findIf { ((_x splitString "#") param [1, ""]) == "EdSubcat_Personnel" } };
_list lnbSetCurSelRow (_index max 0);
