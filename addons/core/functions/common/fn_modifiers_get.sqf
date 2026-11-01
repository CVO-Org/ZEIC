#include "..\..\script_component.hpp"

/*
* Returns the modifier keys held right now on the Zeus or Eden display (see PFUNC(modifiers_install)).
* Alt also counts when the "look around" action is held (Alt by default), in case tracking isn't installed.
*
* Arguments:
* None
*
* Return Value:
* Shortcut: the held modifiers in a fixed order, e.g. "ctrl", "shift", "ctrl+shift", "alt", "" for none <STRING>
*
* Public: No
*/

(uiNamespace getVariable [QPVAR(modifiers), [false, false, false]]) params ["_shift", "_ctrl", "_alt"];
if (inputAction "lookAround" > 0) then { _alt = true };

private _held = [];
if (_ctrl) then { _held pushBack "ctrl" };
if (_shift) then { _held pushBack "shift" };
if (_alt) then { _held pushBack "alt" };
_held joinString "+"
