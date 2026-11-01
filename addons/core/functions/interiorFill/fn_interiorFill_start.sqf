#include "..\..\script_component.hpp"

/*
* Starts an Interior Fill for a list of buildings.
* Eden and singleplayer/host: processed locally. Multiplayer client: sent to the server in one request,
* the server spawns the objects globally and reports progress to all Zeus clients.
*
* Arguments:
* 0: Buildings <ARRAY of OBJECTs>
* 1: Category, e.g. "mil" <STRING>
* 2: Options [object mode <NUMBER>, allow damage <BOOL>] <ARRAY>
*    Object mode: 0 simple objects (fastest), 1 normal objects, 2 normal objects editable in Zeus (slow in Zeus with many)
* 3: Link id: reports every building to this client once its interior is done, see PFUNC(advancedFill_interiorDone)
*    <STRING> (default: "", none)
* 4: Eden layers shared with a garrison, see PFUNC(advancedFill_layer) <HASHMAP> (default: empty, the fill's own layers)
* 5: Collision check of an Advanced Fill, see PFUNC(advancedFill_blockedPositions) <NUMBER> (default: COLLISION_OFF)
*    COLLISION_UNITS_GIVE_WAY: the free building positions are reported with each building (needs a link id)
*    COLLISION_FURNITURE_GIVES_WAY: template objects that would block a reserved position are left out
* 6: Reserved building positions [buildings, position indices of each building] <ARRAY> (default: [], none)
*
* Return Value:
* None
*
* Example:
* [[cursorObject], "mil", [0, false, 1]] call ZEIC_fnc_interiorFill_start
*
* Public: Yes
*/

params [["_buildings", [], [[]]], ["_category", "mil", [""]], ["_options", [], [[]]], ["_linkId", "", [""]], ["_layers", createHashMap, [createHashMap]], ["_collision", COLLISION_OFF, [0]], ["_reserved", [], [[]]]];

if (is3DEN || {isServer}) then {
	[_buildings, _category, _options, clientOwner, _linkId, _layers, _collision, _reserved] call PFUNC(interiorFill_enqueue);
} else {
	[_buildings, _category, _options, clientOwner, _linkId, createHashMap, _collision, _reserved] remoteExecCall [QPFUNC(interiorFill_enqueue), 2];
};
