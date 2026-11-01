#include "..\..\script_component.hpp"

/*
* Builds the Garrison Building dialog. The units come from one of two sources:
* - Recently used: the last 5 faction + subcategory pairs of this game session (uiNamespace).
* - Side, search and faction list, then the subcategory.
* Picking in one source clears the other. Confirming calls PFUNC(ui_garrisonBuilding).
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
_display setVariable [QPVAR(faction), ""];

// Fills the subcategory list for a faction and makes faction + subcategory the selection
_display setVariable [QPVAR(fillSubcats), {
	params ["_display", "_faction", ["_preferred", ""]];
	private _subcatList = _display getVariable "subcat_ctrl";
	private _subcats = ((call PFUNC(garrisonBuilding_factions)) select { (_x select 1) == _faction }) param [0, []] param [4, []];

	_display setVariable [QPVAR(busy), true];
	lbClear _subcatList;
	{
		private _index = _subcatList lbAdd format ["%1 (%2)", _x select 0, _x select 2];
		_subcatList lbSetData [_index, _x select 1];
	} forEach _subcats;
	// The preferred one, otherwise "Men", otherwise the one with most units (first)
	private _select = _subcats findIf { (_x select 1) == _preferred };
	if (_select == -1) then { _select = _subcats findIf { (_x select 1) == "EdSubcat_Personnel" } };
	_subcatList lbSetCurSel (_select max 0);
	(_display getVariable ["recent_ctrl", controlNull]) lbSetCurSel -1;
	_display setVariable [QPVAR(busy), false];

	_display setVariable [QPVAR(faction), _faction];
	_display setVariable [QPVAR(selection), [_faction, _subcatList lbData lbCurSel _subcatList]];
}];

// Fills the faction list from the side and search filters, keeps the selected faction if it is still shown
_display setVariable [QPVAR(fillFactions), {
	params ["_display"];
	private _list = _display getVariable "faction_ctrl";
	private _side = [-1, 1, 0, 2, 3] select (_display getVariable ["side", 0]);
	private _search = toLowerANSI (_display getVariable ["search", ""]);
	private _selected = _display getVariable [QPVAR(faction), ""];

	_display setVariable [QPVAR(busy), true];
	lbClear _list;
	private _keep = -1;
	{
		_x params ["_name", "_class", "_factionSide", "_icon"];
		if ((_side == -1 || {_factionSide == _side}) && {_search == "" || {(toLowerANSI _name find _search) != -1} || {(toLowerANSI _class find _search) != -1}}) then {
			private _index = _list lbAdd _name;
			_list lbSetData [_index, _class];
			_list lbSetPicture [_index, _icon];
			_list lbSetTooltip [_index, _class];
			if (_class == _selected) then { _keep = _index };
		};
	} forEach (call PFUNC(garrisonBuilding_factions));
	_list lbSetCurSel _keep;
	_display setVariable ["faction", _keep];
	_display setVariable [QPVAR(busy), false];

	// A faction that is filtered out is no longer picked
	if (_keep == -1 && {_selected != ""}) then {
		_display setVariable [QPVAR(faction), ""];
		_display setVariable [QPVAR(selection), []];
		lbClear (_display getVariable "subcat_ctrl");
	};
}];

private _ctx = [_display, _title] call PFUNC(ui_dialogCreate);

if (_recent isNotEqualTo []) then {
	private _list = [_ctx, "recent", LLSTRING(ModuleGarrisonBuilding_Recent), 3, LLSTRING(ModuleGarrisonBuilding_Recent_Tooltip), {
		params ["_display", "_index"];
		if (_display getVariable [QPVAR(busy), false] || {_index < 0}) exitWith {};
		_display setVariable [QPVAR(selection), (_display getVariable QPVAR(recent)) select _index];

		// Clears the other source
		_display setVariable [QPVAR(busy), true];
		_display setVariable [QPVAR(faction), ""];
		(_display getVariable "faction_ctrl") lbSetCurSel -1;
		lbClear (_display getVariable "subcat_ctrl");
		_display setVariable [QPVAR(busy), false];
	}] call PFUNC(ui_dialogList);

	{
		_x params ["_faction", "_subcat"];
		private _factionInfo = _factions select (_factions findIf { (_x select 1) == _faction });
		private _subcatInfo = (_factionInfo select 4) select ((_factionInfo select 4) findIf { (_x select 1) == _subcat });
		private _index = _list lbAdd format ["%1 - %2", _factionInfo select 0, _subcatInfo select 0];
		_list lbSetPicture [_index, _factionInfo select 3];
	} forEach _recent;
};

[_ctx, "search", LLSTRING(ModuleGarrisonBuilding_Search), "", LLSTRING(ModuleGarrisonBuilding_Search_Tooltip), {
	params ["_display"];
	_display call (_display getVariable QPVAR(fillFactions));
}] call PFUNC(ui_dialogEdit);

[_ctx, "side", LLSTRING(ModuleGarrisonBuilding_Side), [LLSTRING(ModuleGarrisonBuilding_Side_All), localize "STR_WEST", localize "STR_EAST", localize "STR_GUERRILA", localize "STR_CIVILIAN"], 0, [], {
	params ["_display"];
	_display call (_display getVariable QPVAR(fillFactions));
}] call PFUNC(ui_dialogToolbox);

// Faction and subcategory lists side by side
[_ctx, "faction", LLSTRING(ModuleGarrisonBuilding_Faction), 7, "", {
	params ["_display", "_index", "_list"];
	if (_display getVariable [QPVAR(busy), false] || {_index < 0}) exitWith {};
	[_display, _list lbData _index] call (_display getVariable QPVAR(fillSubcats));
}, [0, 13.9], false] call PFUNC(ui_dialogList);

[_ctx, "subcat", LLSTRING(ModuleGarrisonBuilding_Subcategory), 7, "", {
	params ["_display", "_index", "_list"];
	private _faction = _display getVariable [QPVAR(faction), ""];
	if (_display getVariable [QPVAR(busy), false] || {_index < 0} || {_faction == ""}) exitWith {};
	_display setVariable [QPVAR(selection), [_faction, _list lbData _index]];
	(_display getVariable ["recent_ctrl", controlNull]) lbSetCurSel -1;
}, [14, 12]] call PFUNC(ui_dialogList);

private _positions = count (_bld buildingPos -1);
[_ctx, "units", LLSTRING(ModuleGarrisonBuilding_Units), [1, 12 max _positions, 1], missionNamespace getVariable [QPVAR(UiGarrisonUnits), 1 max round (_positions / 3)], LLSTRING(ModuleGarrisonBuilding_Units_Tooltip)] call PFUNC(ui_dialogSlider);
[_ctx, "radius", LLSTRING(Radius), [0, 250, 5], missionNamespace getVariable [QPVAR(UiGarrisonRadius), 0], LLSTRING(Radius_Tooltip), _bld] call PFUNC(ui_dialogSlider);
[_ctx, "percent", LLSTRING(Percentage), [10, 100, 10], missionNamespace getVariable [QPVAR(UiGarrisonPercent), 50], LLSTRING(Percentage_Tooltip)] call PFUNC(ui_dialogSlider);
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
		_this getVariable ["units", 4],
		_this getVariable ["dynamic", false],
		_this getVariable ["trigger", false],
		_this getVariable ["radius", 0],
		_this getVariable ["percent", 50]
	] call PFUNC(ui_garrisonBuilding);
	true
}] call PFUNC(ui_dialogFinish);

// Start with the most recent pair, otherwise the last used (or first) faction
_display call (_display getVariable QPVAR(fillFactions));
if (_recent isNotEqualTo []) exitWith {
	(_display getVariable "recent_ctrl") lbSetCurSel 0;
};

private _list = _display getVariable "faction_ctrl";
if (lbSize _list == 0) exitWith {};
private _last = missionNamespace getVariable [QPVAR(UiGarrisonFaction), ""];
private _index = 0;
for "_i" from 0 to (lbSize _list - 1) do { if ((_list lbData _i) == _last) exitWith { _index = _i } };

_display setVariable [QPVAR(busy), true];
_list lbSetCurSel _index;
_display setVariable ["faction", _index];
_display setVariable [QPVAR(busy), false];
[_display, _list lbData _index, missionNamespace getVariable [QPVAR(UiGarrisonCategory), ""]] call (_display getVariable QPVAR(fillSubcats));
