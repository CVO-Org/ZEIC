#include "..\..\script_component.hpp"

/*
* Adds a row to a ZEIC dialog: the label on the left, room for the control on the right.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Label <STRING>
* 2: Tooltip <STRING> (default: none)
* 3: Height in rows <NUMBER> (default: 1)
*
* Return Value:
* Relative position of the control [x, y, w, h] <ARRAY>
*
* Public: No
*/

params ["_ctx", ["_label", "", [""]], ["_tooltip", "", [""]], ["_rows", 1, [0]]];

private _x0 = _ctx get "x";
private _y = _ctx get "y";
private _h = UI_H(_rows);

private _ctrl = [_ctx, QPVAR(ctrlLabel), [_x0, _y, UI_W(10), _h]] call PFUNC(ui_dialogAdd);
_ctrl ctrlSetText _label;
if (_tooltip != "") then { _ctrl ctrlSetTooltip _tooltip };

_ctx set ["y", _y + _h + UI_GAP];
[_x0 + UI_W(10.1), _y, UI_W(15.9), _h]
