#include "..\..\script_component.hpp"

/*
* Prepares a building before its interior is spawned.
* Eden: creates a new layer for the interior. Otherwise: makes the building indestructible unless damage is allowed,
* to stop floating items when the building is destroyed.
*
* Arguments:
* 0: Building <OBJECT>
* 1: Allow damage <BOOL>
*
* Return Value:
* Eden layer ID, -1 outside of Eden <NUMBER>
*
* Public: No
*/

params [["_bld", objNull, [objNull]], ["_allowDamage", false, [false]], ["_fillLayer", -1, [0]]];

if (is3DEN) exitWith {
	// TODO: Doesn't work in Eden? Find alternative method.
	// _bld set3DENAttribute ["allowDamage", false];

	[_fillLayer, getText (configOf _bld >> "displayName")] call PFUNC(eden_addLayer)
};

if !(_allowDamage) then { [_bld, false] remoteExecCall ["allowDamage", _bld] };

-1
