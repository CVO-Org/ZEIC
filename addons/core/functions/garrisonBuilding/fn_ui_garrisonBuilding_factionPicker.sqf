#include "..\..\script_component.hpp"

/*
* Adds the faction picker rows to a ZEIC dialog (Garrison Building, Advanced Fill). The units come from one of
* two lists, both with one row per faction + subcategory pair (side icon, flag, faction, subcategory):
* - Recently used: the last 5 pairs of this game session (uiNamespace).
* - All pairs, narrowed by the side and search filters.
* Picking in one list clears the other. The picked pair is stored on the display as QPVAR(selection) [faction, subcategory].
* Once the dialog is finished, PFUNC(ui_garrisonBuilding_selectPair) picks the first pair; on confirm,
* QPVAR(rememberPair) (code on the display) adds the picked pair to the recently used ones.
*
* Arguments:
* 0: Dialog context <HASHMAP>
*
* Return Value:
* None
*
* Public: No
*/

params ["_ctx"];

private _display = _ctx get "display";
private _factions = call PFUNC(garrisonBuilding_factions);

// Recently used entries whose faction and subcategory still exist (the modset may have changed)
private _recent = (uiNamespace getVariable [QPVAR(garrisonRecent), []]) select {
	_x params ["_faction", "_subcat"];
	private _index = _factions findIf { (_x select 1) == _faction };
	_index != -1 && {((_factions select _index) select 4) findIf { (_x select 1) == _subcat } != -1}
};
_display setVariable [QPVAR(recent), _recent];
_display setVariable [QPVAR(selection), []];

// Columns of both lists: side icon, flag, faction, subcategory. Pictures are as tall as a row and keep their
// aspect ratio, so the flag column is two rows wide (flags are 2:1) out of the list's 26.
#define PAIR_COLUMNS [0, 0.045, 0.135, 0.55]

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

// Most recent first, at most 5
_display setVariable [QPVAR(rememberPair), {
	params ["_selection"];
	private _recent = (uiNamespace getVariable [QPVAR(garrisonRecent), []]) - [_selection];
	_recent = ([_selection] + _recent) select [0, 5];
	uiNamespace setVariable [QPVAR(garrisonRecent), _recent];
}];

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

[_ctx, "pairs", LLSTRING(ModuleGarrisonBuilding_Faction), 8, "", {
	params ["_display", "_index", "_list"];
	if (_display getVariable [QPVAR(busy), false] || {_index < 0}) exitWith {};
	_display setVariable [QPVAR(selection), (_list lnbData [_index, 0]) splitString "#"];

	// Clears the other list
	_display setVariable [QPVAR(busy), true];
	(_display getVariable ["recent_ctrl", controlNull]) lnbSetCurSelRow -1;
	_display setVariable [QPVAR(busy), false];
}, nil, nil, PAIR_COLUMNS] call PFUNC(ui_dialogList);
