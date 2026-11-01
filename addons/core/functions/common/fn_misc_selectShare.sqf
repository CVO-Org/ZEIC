#include "..\..\script_component.hpp"

/*
* Picks a random share of a list, e.g. the buildings within a radius that get furnished or garrisoned.
* The count is rounded to the nearest whole number (7 at 30 %: 2), at least 1 if the list isn't empty.
*
* Arguments:
* 0: Items <ARRAY>
* 1: Share in percent, 1-100 <NUMBER>
*
* Return Value:
* The picked items in random order, [] for an empty list <ARRAY>
*
* Example:
* [_buildings, 30] call ZEIC_fnc_misc_selectShare
*
* Public: No
*/

params [["_items", [], [[]]], ["_percent", 100, [0]]];

if (_items isEqualTo []) exitWith { [] };

private _count = 1 max round ((count _items) * ((_percent min 100) max 1) / 100);
(_items call BIS_fnc_arrayShuffle) select [0, _count]
