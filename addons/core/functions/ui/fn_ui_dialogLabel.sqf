#include "..\..\script_component.hpp"

/*
* Adds a section label (small, muted, upper case) to a ZEIC dialog.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Text <STRING>
*
* Return Value:
* Label control <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_text", "", [""]]];

private _ctrl = [_ctx, QPVAR(ctrlLabel), [_ctx get "pad", _ctx get "y", (_ctx get "w") - 2 * (_ctx get "pad"), 2.6 * UI_GH]] call PFUNC(ui_dialogAdd);
_ctrl ctrlSetText toUpper _text;
_ctx set ["y", (_ctx get "y") + 3 * UI_GH];
_ctrl
