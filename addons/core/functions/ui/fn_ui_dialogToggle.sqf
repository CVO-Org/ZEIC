#include "..\..\script_component.hpp"

/*
* Adds a checkbox with its text to a ZEIC dialog. The state is stored on the display.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Text <STRING>
* 3: Checked <BOOL>
* 4: Tooltip <STRING> (default: none)
*
* Return Value:
* Checkbox <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_text", "", [""]], ["_checked", false, [false]], ["_tooltip", "", [""]]];

private _pad = _ctx get "pad";
private _y = _ctx get "y";
private _size = 5 * UI_GH;

private _box = [_ctx, QPVAR(ctrlCheckbox), [_pad, _y, _size * (pixelW / pixelH), _size]] call PFUNC(ui_dialogAdd);
private _label = [_ctx, QPVAR(ctrlText), [_pad + _size * (pixelW / pixelH) + UI_GW, _y, (_ctx get "w") - 2 * _pad - 6 * UI_GW, _size]] call PFUNC(ui_dialogAdd);
_label ctrlSetText _text;
if (_tooltip != "") then { _box ctrlSetTooltip _tooltip; _label ctrlSetTooltip _tooltip };

_box cbSetChecked _checked;
_box setVariable [QPVAR(key), _key];
(_ctx get "display") setVariable [_key, _checked];
_box ctrlAddEventHandler ["CheckedChanged", {
	params ["_box", "_state"];
	(ctrlParent _box) setVariable [_box getVariable QPVAR(key), _state == 1];
}];

_ctx set ["y", _y + 7 * UI_GH];
_box
