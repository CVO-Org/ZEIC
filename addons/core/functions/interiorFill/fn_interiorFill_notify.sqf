#include "..\..\script_component.hpp"

/*
* Shows an Interior Fill message to the client that started the fill (locally in Eden / singleplayer).
*
* Arguments:
* 0: Message <STRING>
* 1: Requesting client <NUMBER>
*
* Return Value:
* None
*
* Public: No
*/

params [["_msg", "", ["", []]], ["_requester", clientOwner, [0]]];

if (is3DEN || {!isMultiplayer} || {_requester == clientOwner}) then {
	[_msg, "INFO"] call PFUNC(misc_logMsg);
} else {
	[_msg, "INFO"] remoteExecCall [QPFUNC(misc_logMsg), _requester];
};
