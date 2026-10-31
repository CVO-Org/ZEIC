#include "..\..\script_component.hpp"

/*
* KeyDown / KeyUp handler of PFUNC(modifiers_install): stores the modifier state including the key itself.
*
* Arguments:
* 0: Event arguments [display, key, shift, ctrl, alt] <ARRAY>
* 1: Key pressed (true) or released (false) <BOOL>
*
* Return Value:
* None
*
* Public: No
*/

params ["_args", "_down"];
_args params ["", "_key", "_shift", "_ctrl", "_alt"];

if (_key in [42, 54]) then { _shift = _down };  // left/right Shift
if (_key in [29, 157]) then { _ctrl = _down };  // left/right Ctrl
if (_key in [56, 184]) then { _alt = _down };   // left/right Alt
uiNamespace setVariable [QPVAR(modifiers), [_shift, _ctrl, _alt]];
