#include "..\..\script_component.hpp"

/*
* Adds a toolbox row (one choice out of a few, side by side) to a ZEIC dialog. The selected index is stored on the display.
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Key <STRING>
* 2: Label <STRING>
* 3: Options <ARRAY of STRINGs>
* 4: Selected index <NUMBER>
* 5: Tooltips, one per option <ARRAY of STRINGs> (default: none)
* 6: Code run on change, gets [display, index, control] <CODE> (default: none)
*
* Return Value:
* Toolbox <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_key", "", [""]], ["_label", "", [""]], ["_options", [], [[]]], ["_selected", 0, [0]], ["_tooltips", [], [[]]], ["_onChange", {}, [{}]]];

private _display = _ctx get "display";

// The toolbox's config reads its rows and columns from here when it is created
parsingNamespace setVariable [QPVAR(toolboxRows), 1];
parsingNamespace setVariable [QPVAR(toolboxColumns), count _options max 1];
private _toolbox = [_ctx, QPVAR(ctrlToolbox), [_ctx, _label] call PFUNC(ui_dialogRow)] call PFUNC(ui_dialogAdd);

{
	private _index = _toolbox lbAdd _x;
	if (_forEachIndex < count _tooltips) then { _toolbox lbSetTooltip [_index, _tooltips select _forEachIndex] };
} forEach _options;

_selected = (_selected min (count _options - 1)) max 0;
_toolbox lbSetCurSel _selected;
_toolbox setVariable [QPVAR(key), _key];
_toolbox setVariable [QPVAR(onChange), _onChange];
_toolbox ctrlAddEventHandler ["ToolBoxSelChanged", {
	params ["_toolbox", "_index"];
	private _display = ctrlParent _toolbox;
	_display setVariable [_toolbox getVariable QPVAR(key), _index];
	[_display, _index, _toolbox] call (_toolbox getVariable QPVAR(onChange));
}];

_display setVariable [_key, _selected];
_display setVariable [format ["%1_ctrl", _key], _toolbox];
_toolbox
