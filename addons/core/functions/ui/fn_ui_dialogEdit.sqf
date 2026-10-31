#include "..\..\script_component.hpp"

/*
* Adds a text field row to a ZEIC dialog. The text is stored on the display while typing.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Label <STRING>
* 3: Text <STRING>
* 4: Tooltip <STRING> (default: none)
* 5: Code run on change, gets [display, text, control] <CODE> (default: none)
*
* Return Value:
* Edit <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_text", "", [""]], ["_tooltip", "", [""]], ["_onChange", {}, [{}]]];

private _display = _ctx get "display";
([_ctx, _label, _tooltip] call PFUNC(ui_dialogRow)) params ["_cx", "_cy", "_cw", "_ch"];
private _edit = [_ctx, QPVAR(ctrlEdit), [_cx, _cy + pixelH, _cw, _ch - pixelH]] call PFUNC(ui_dialogAdd);

_edit ctrlSetText _text;
if (_tooltip != "") then { _edit ctrlSetTooltip _tooltip };
_edit setVariable [QPVAR(key), _key];
_edit setVariable [QPVAR(onChange), _onChange];
_edit ctrlAddEventHandler ["KeyUp", {
	params ["_edit"];
	private _display = ctrlParent _edit;
	private _text = ctrlText _edit;
	private _key = _edit getVariable QPVAR(key);
	if (_text isEqualTo (_display getVariable [_key, ""])) exitWith {};
	_display setVariable [_key, _text];
	[_display, _text, _edit] call (_edit getVariable QPVAR(onChange));
}];

_display setVariable [_key, _text];
_display setVariable [format ["%1_ctrl", _key], _edit];
_edit
