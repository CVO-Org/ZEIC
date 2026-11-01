#include "..\..\script_component.hpp"

/*
* Fills the pair list of the faction picker (see PFUNC(ui_garrisonBuilding_factionPicker)) and picks the first pair:
* the most recent pair, otherwise the last used pair, otherwise the last used faction's "Men" (or its first
* subcategory), otherwise the first "Men" of the list (or its first row).
* Called once the dialog is finished (its controls are in place).
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

_display call (_display getVariable QPVAR(fillPairs));
if ((_display getVariable [QPVAR(recent), []]) isNotEqualTo []) exitWith {
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
