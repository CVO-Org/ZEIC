#include "..\..\script_component.hpp"

/*
* Checks that the server runs ZEIC, for modules (or parts of them) that do their work on the server.
* The server announces it with PVAR(serverActive) in PFUNC(init), which also covers singleplayer and a hosted game.
* Eden always passes. So this only fails on a client of a server without ZEIC.
* On failure, tells the player: Zeus's red feedback message when Zeus is open, else a message box,
* and in both cases chat and RPT (PFUNC(misc_logMsg)).
*
* Arguments:
* 0: Module name <STRING>
* 1: Part of the module that needs the server, e.g. the Move AI trigger <STRING> (default: "", the whole module)
*
* Return Value:
* true if the server runs ZEIC <BOOL>
*
* Example:
* if !([LLSTRING(ModuleInteriorFill_DisplayName)] call ZEIC_fnc_misc_serverCheck) exitWith {};
*
* Public: No
*/

params [["_module", "", [""]], ["_part", "", [""]]];

if (is3DEN || {missionNamespace getVariable [QPVAR(serverActive), false]}) exitWith { true };

private _msg = if (_part isEqualTo "") then {
	format [LLSTRING(NoServer), _module]
} else {
	format [LLSTRING(NoServer_Part), _module, _part]
};

[_msg, "ERROR"] call PFUNC(misc_logMsg);

if (isNull findDisplay 312) then {
	// A message box has to be spawned: BIS_fnc_guiMessage waits for the player
	[_msg, _module] spawn BIS_fnc_guiMessage;
} else {
	[objNull, _msg] call BIS_fnc_showCuratorFeedbackMessage;
};

false
