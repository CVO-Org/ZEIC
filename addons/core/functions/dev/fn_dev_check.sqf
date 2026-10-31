#include "..\..\script_component.hpp"

/*
* Self test: records one check. Writes a [ZEIC TEST] line to the RPT, failed checks also to chat.
*
* Arguments:
* 0: Name <STRING>
* 1: Passed <BOOL>
* 2: Extra info, written after the name <ANY> (default: none)
*
* Return Value:
* None
*
* Public: No
*/

params ["_name", "_ok", ["_info", ""]];

private _line = format ["[ZEIC TEST] %1 %2", ["FAIL", "PASS"] select _ok, _name];
if (_info isNotEqualTo "") then { _line = _line + " | " + str _info };
diag_log text _line;
if (!_ok) then { systemChat _line };
PVAR(dev_results) pushBack _ok;
