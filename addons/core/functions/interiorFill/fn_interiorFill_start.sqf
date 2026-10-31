#include "..\..\script_component.hpp"

/*
* Starts an Interior Fill for a list of buildings.
* Eden and singleplayer/host: processed locally. Multiplayer client: sent to the server in one request,
* the server spawns the objects globally and reports progress to all Zeus clients.
*
* Arguments:
* 0: Buildings <ARRAY of OBJECTs>
* 1: Category, e.g. "mil" <STRING>
* 2: Options [object mode <NUMBER>, allow damage <BOOL>, detail level <NUMBER>] <ARRAY>
*    Object mode: 0 simple objects (fastest), 1 normal objects, 2 normal objects editable in Zeus (slow in Zeus with many)
*
* Return Value:
* None
*
* Example:
* [[cursorObject], "mil", [0, false, 1]] call ZEIC_fnc_interiorFill_start
*
* Public: Yes
*/

params [["_buildings", [], [[]]], ["_category", "mil", [""]], ["_options", [], [[]]]];

if (is3DEN || {isServer}) then {
	[_buildings, _category, _options, clientOwner] call PFUNC(interiorFill_enqueue);
} else {
	[_buildings, _category, _options, clientOwner] remoteExecCall [QPFUNC(interiorFill_enqueue), 2];
};
