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

params [["_bld", objNull, [objNull]], ["_allowDamage", false, [false]]];

if (is3DEN) exitWith {
	// TODO: Doesn't work in Eden? Find alternative method.
	// _bld set3DENAttribute ["allowDamage", false];

	private _counter = uiNamespace getVariable [QPVAR(layer_counter), 0];
	uiNamespace setVariable [QPVAR(layer_counter), _counter + 1];
	-1 add3DENLayer "ZEIC Interior " + str _counter
};

if !(_allowDamage) then { [_bld, false] remoteExecCall ["allowDamage", _bld] };

-1
