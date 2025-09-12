#include "../../script_component.hpp"

// ["text", "DEBUG"] call PFUNC(misc_logMsg);
params ["_msg", "_lev"];

_lev = toUpper _lev;

if ((_lev isEqualTo "DEBUG") && !(missionNamespace getVariable [QPVAR(DEBUG), false])) exitWith {};

systemChat format ["[%1] %2", _lev, _msg];
diag_log text format ["[ZEI][%1][%2] - %3", _lev, _fnc_scriptNameParent, _msg];
