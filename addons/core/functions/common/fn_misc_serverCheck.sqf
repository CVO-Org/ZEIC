#include "..\..\script_component.hpp"

/*
* Checks that the server runs ZEIC, for modules (or parts of them) that do their work on the server.
* The server sets PVAR(serverActive) in PFUNC(init). Eden, singleplayer and a hosted game are the server
* themselves, so this only fails on a client of a server without ZEIC.
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

#if _ZEIC_DEV_
// Self test (PFUNC(dev_test_serverCheck)): act like a client of a server, which singleplayer can't be
private _isServer = isServer && {!(missionNamespace getVariable [QPVAR(dev_asClient), false])};
#else
private _isServer = isServer;
#endif

if (_isServer || {!isNil QPVAR(serverActive)}) exitWith { true };

#if _ZEIC_DEV_
PVAR(dev_refused) = [_module, _part];
#endif

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
