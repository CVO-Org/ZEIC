#include "..\..\script_component.hpp"

/*
* Reports buildings whose interior is done to the client that started an Advanced Fill, so its garrison job
* can go on with them (see PFUNC(advancedFill_waitForInterior)). Called where the interior job runs (server,
* or locally in Eden / singleplayer); the buildings are stored on the requesting client, per link id.
* With the collision check "units give way", the free building positions of each building come along (only their
* indices go over the network) and are kept on the building, on the requesting client only.
*
* Arguments:
* 0: Link id, "" for a fill that isn't linked (nothing happens) <STRING>
* 1: Buildings <ARRAY of OBJECTs>
* 2: Requesting client <NUMBER> (default: this client)
* 3: Free building position indices of each building, in the same order <ARRAY of ARRAYs> (default: [], all free)
*
* Return Value:
* None
*
* Public: No
*/

params [["_linkId", "", [""]], ["_buildings", [], [[]]], ["_requester", clientOwner, [0]], ["_free", [], [[]]]];

if (_linkId == "" || {_buildings isEqualTo []}) exitWith {};

if (is3DEN || {!isMultiplayer} || {_requester == clientOwner}) then {
	if (isNil QPVAR(interiorDone)) then { PVAR(interiorDone) = createHashMap };
	(PVAR(interiorDone) getOrDefaultCall [_linkId, { [] }, true]) append _buildings;
	{ (_buildings select _forEachIndex) setVariable [QPVAR(freePositions), [_linkId, _x]] } forEach _free;
} else {
	[_linkId, _buildings, _requester, _free] remoteExecCall [QPFUNC(advancedFill_interiorDone), _requester];
};
