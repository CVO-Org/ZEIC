#include "..\..\script_component.hpp"

/*
* Works out how many units each building of a garrison gets: a percentage of its positions.
* So that a few large buildings don't take most of the units, every building counts with at most
* 1.5 x the median position count of all the buildings (one building: the median is itself, nothing is capped).
* Rounded to the nearest whole number, at least 1 unit per building with positions.
*
* Example: 8 huts with 4 positions and an office block with 60 at 50 %: median 4, cap 6, so 2 units per hut and 3 in the office block.
*
* Arguments:
* 0: Position count of each building <ARRAY of NUMBERs>
* 1: Share of each building's positions to fill in percent, 1-100 <NUMBER>
*
* Return Value:
* Unit count of each building, in the same order <ARRAY of NUMBERs>
*
* Example:
* [[4, 4, 60], 50] call ZEIC_fnc_garrisonBuilding_unitCounts // [2, 2, 3]
*
* Public: No
*/

params [["_positions", [], [[]]], ["_percent", 50, [0]]];

if (_positions isEqualTo []) exitWith { [] };

_percent = (_percent min 100) max 1;

private _sorted = +_positions;
_sorted sort true;
private _count = count _sorted;
private _half = floor (_count / 2);
private _median = if (_count % 2 == 1) then {
	_sorted select _half
} else {
	((_sorted select (_half - 1)) + (_sorted select _half)) / 2
};
private _cap = 1.5 * _median;

_positions apply {
	if (_x <= 0) then { 0 } else {
		(1 max round ((_x min _cap) * _percent / 100)) min _x
	}
}
