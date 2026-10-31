#include "..\..\script_component.hpp"

/*
* Creates a control of a ZEIC dialog at a position relative to the dialog's top left corner.
* PFUNC(ui_dialogFinish) moves all controls into place once the dialog's height is known.
*
* Arguments:
* 0: Dialog context <HASHMAP> - see PFUNC(ui_dialogCreate)
* 1: Control class <STRING>
* 2: Relative position [x, y, w, h] <ARRAY>
*
* Return Value:
* Control <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_class", "", [""]], ["_pos", [0, 0, 0, 0], [[]], 4]];

private _ctrl = (_ctx get "display") ctrlCreate [_class, -1];
_ctrl setVariable [QPVAR(relPos), _pos];
(_ctx get "controls") pushBack _ctrl;
_ctrl
