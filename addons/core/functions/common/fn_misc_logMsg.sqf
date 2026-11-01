#include "..\..\script_component.hpp"

/*
* Shows a message in chat and writes it to the RPT.
* A message sent to another client (remoteExec) can be [stringtable key, arguments...]: it is translated
* on the client that shows it.
*
* Arguments:
* 0: Message, or [stringtable key, format arguments...] <STRING or ARRAY>
* 1: Level: "INFO", "WARNING", "ERROR", "DEBUG" (only with ZEIC_DEBUG) <STRING>
*
* Return Value:
* None
*
* Example:
* ["text", "DEBUG"] call ZEIC_fnc_misc_logMsg
*
* Public: No
*/

params [["_msg", "", ["", []]], ["_lev", "INFO", [""]]];

_lev = toUpper _lev;

if ((_lev isEqualTo "DEBUG") && !(missionNamespace getVariable [QPVAR(DEBUG), false])) exitWith {};

if (_msg isEqualType []) then {
	_msg = format ([localize (_msg select 0)] + (_msg select [1]));
};

systemChat format ["[%1] %2", _lev, _msg];
diag_log text format ["[ZEI][%1][%2] - %3", _lev, _fnc_scriptNameParent, _msg];
