#include "..\..\script_component.hpp"

/*
* Sorts buildings in reading order for the queue: in rows of QUEUE_ROW_SIZE meters from north to south,
* and from east to west within a row. A large fill then sweeps across the area instead of jumping around.
*
* Arguments:
* 0: Buildings <ARRAY of OBJECTs>
* 1: Row height in meters <NUMBER> (default: QUEUE_ROW_SIZE)
*
* Return Value:
* Sorted buildings <ARRAY of OBJECTs>
*
* Public: No
*/

params [["_buildings", [], [[]]], ["_rowSize", QUEUE_ROW_SIZE, [0]]];

private _keyed = [];
{
	private _pos = getPosWorld _x;
	// Ascending sort: north (higher y) first, then east (higher x) first, index keeps it stable
	_keyed pushBack [-(floor ((_pos select 1) / _rowSize)), -(_pos select 0), _forEachIndex];
} forEach _buildings;

_keyed sort true;

_keyed apply { _buildings select (_x select 2) }
