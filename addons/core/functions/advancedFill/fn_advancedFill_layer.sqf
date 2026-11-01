#include "..\..\script_component.hpp"

/*
* Eden layers of an Advanced Fill, shared by its interior and garrison jobs (see PFUNC(advancedFill_start)):
*
*   ZEIC Advanced Fill               <- root
*     001 - CSAT + Military          <- one layer per fill: faction + category (or just the one part)
*       001 - House (Large)          <- one layer per building, made by whichever job gets there first
*         Objects                    <- the interior
*         Units                      <- the garrison, its trigger is in the building layer
*
* Arguments:
* 0: Layers of the fill <HASHMAP> - "name" of the fill layer; "fill", "buildings" and "layers" are added here
* 1: Building <OBJECT>
* 2: Sub-layer: "Objects" or "Units", "" for the building layer itself <STRING>
*
* Return Value:
* Layer ID <NUMBER>
*
* Public: No
*/

params ["_layers", ["_bld", objNull, [objNull]], ["_sub", "", [""]]];

// Parallel lists: objects can't be hash map keys
private _buildings = _layers getOrDefaultCall ["buildings", { [] }, true];
private _ids = _layers getOrDefaultCall ["layers", { [] }, true];
private _index = _buildings find _bld;
if (_index == -1) then {
	_index = _buildings pushBack _bld;
	private _fill = _layers getOrDefaultCall ["fill", { ["ZEIC Advanced Fill", _layers get "name"] call PFUNC(eden_addLayer) }, true];
	_ids pushBack createHashMapFromArray [["", [_fill, getText (configOf _bld >> "displayName")] call PFUNC(eden_addLayer)]];
};

private _buildingLayers = _ids select _index;
_buildingLayers getOrDefaultCall [_sub, { (_buildingLayers get "") add3DENLayer _sub }, true]
