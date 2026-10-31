#include "..\..\script_component.hpp"

/*
* Adds a checkbox row to a ZEIC dialog. The state is stored on the display.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Label <STRING>
* 3: Checked <BOOL>
* 4: Tooltip <STRING> (default: none)
*
* Return Value:
* Checkbox <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_checked", false, [false]], ["_tooltip", "", [""]]];

private _display = _ctx get "display";
([_ctx, _label, _tooltip] call PFUNC(ui_dialogRow)) params ["_cx", "_cy", "", "_ch"];
private _checkbox = [_ctx, QPVAR(ctrlCheckbox), [_cx, _cy, UI_W(1), _ch]] call PFUNC(ui_dialogAdd);

_checkbox cbSetChecked _checked;
if (_tooltip != "") then { _checkbox ctrlSetTooltip _tooltip };
_checkbox setVariable [QPVAR(key), _key];
_checkbox ctrlAddEventHandler ["CheckedChanged", {
	params ["_checkbox", "_checked"];
	(ctrlParent _checkbox) setVariable [_checkbox getVariable QPVAR(key), _checked == 1];
}];

_display setVariable [_key, _checked];
_display setVariable [format ["%1_ctrl", _key], _checkbox];
_checkbox
