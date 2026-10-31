#include "..\..\script_component.hpp"

/*
* Finds the infantry classes of a faction + editor subcategory that are suitable for a garrison
* (armed, no parachute, no crew/pilots/divers/officers etc.).
*
* Arguments:
* 0: Faction class <STRING>
* 1: Editor subcategory class <STRING>
*
* Return Value:
* Unit classes, [] if the faction has none <ARRAY of STRINGs>
*
* Public: No
*/

params [["_factClass", "", [""]], ["_catClass", "", [""]]];

private _tempList = "getText (_x >> 'faction') == _factClass && getText (_x >> 'editorSubcategory') == _catClass && (configName _x) isKindoF 'CAManBase' && getNumber(_x >> 'scope') == 2" configClasses (configFile >> "CfgVehicles");

// Filter out invalid unit types matching strings.
private _fnc_notInString = {
	params ["_type"];

	private _notInString = true;
	{
		if (toLower _type find _x >= 0) exitWith { _notInString = false };
	} forEach [ "_story", "_vr", "competitor", "ghillie", "miller", "survivor", "crew", "diver", "pilot", "rangemaster", "uav", "unarmed", "officer" ];

	_notInString
};

// Include units with at least one weapon and a non-parachute backpack.
private _menList = _tempList select { ((configName _x) call _fnc_notInString) && (count getArray(_x >> "weapons") > 2) && (toLower getText (_x >> "backpack") find "para" < 0) };

// If no units remain, use the original list.
if (_menList isEqualTo []) then { _menList = _tempList };

_menList apply { configName _x }
