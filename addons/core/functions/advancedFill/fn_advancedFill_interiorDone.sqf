#include "..\..\script_component.hpp"

/*
* Reports buildings whose interior is done to the client that started an Advanced Fill, so its garrison job
* can go on with them (see PFUNC(advancedFill_waitForInterior)). Called where the interior job runs (server,
* or locally in Eden / singleplayer); the buildings are stored on the requesting client, per link id.
*
* Arguments:
* 0: Link id, "" for a fill that isn't linked (nothing happens) <STRING>
* 1: Buildings <ARRAY of OBJECTs>
* 2: Requesting client <NUMBER> (default: this client)
*
* Return Value:
* None
*
* Public: No
*/

params [["_linkId", "", [""]], ["_buildings", [], [[]]], ["_requester", clientOwner, [0]]];

if (_linkId == "" || {_buildings isEqualTo []}) exitWith {};

if (is3DEN || {!isMultiplayer} || {_requester == clientOwner}) then {
	if (isNil QPVAR(interiorDone)) then { PVAR(interiorDone) = createHashMap };
	(PVAR(interiorDone) getOrDefaultCall [_linkId, { [] }, true]) append _buildings;
} else {
	[_linkId, _buildings, _requester] remoteExecCall [QPFUNC(advancedFill_interiorDone), _requester];
};
