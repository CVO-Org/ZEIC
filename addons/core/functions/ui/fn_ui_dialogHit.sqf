#include "..\..\script_component.hpp"

/*
* Adds an invisible click area to a ZEIC dialog that repaints its panel on hover. The look comes from
* a paint code that gets the hit control and reads its variables (hover, selected, pieces, text).
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Relative position [x, y, w, h] <ARRAY>
* 2: Panel pieces <ARRAY of CONTROLs>
* 3: Text control <CONTROL>
* 4: Paint code, or "segment", "primary", "secondary" <CODE or STRING>
*
* Return Value:
* Hit control <CONTROL>
*
* Public: No
*/

params ["_ctx", ["_pos", [0, 0, 0, 0], [[]], 4], ["_pieces", [], [[]]], ["_text", controlNull, [controlNull]], ["_paint", "secondary", ["", {}]]];

if (_paint isEqualType "") then {
	_paint = switch (_paint) do {
		case "segment": { {
			params ["_hit"];
			private _hover = _hit getVariable [QPVAR(hover), false];
			if (_hit getVariable [QPVAR(selected), false]) then {
				[_hit getVariable QPVAR(pieces), [UI_C_ACCENT_SOFT, UI_C_ACCENT_SOFT_HOVER] select _hover] call PFUNC(ui_panelColor);
				(_hit getVariable QPVAR(text)) ctrlSetTextColor UI_C_ACCENT;
			} else {
				[_hit getVariable QPVAR(pieces), [UI_C_FIELD, UI_C_FIELD_HOVER] select _hover] call PFUNC(ui_panelColor);
				(_hit getVariable QPVAR(text)) ctrlSetTextColor ([UI_C_TEXT2, UI_C_TEXT] select _hover);
			};
		} };
		case "primary": { {
			params ["_hit"];
			[_hit getVariable QPVAR(pieces), [UI_C_ACCENT, UI_C_ACCENT_HOVER] select (_hit getVariable [QPVAR(hover), false])] call PFUNC(ui_panelColor);
			(_hit getVariable QPVAR(text)) ctrlSetTextColor UI_C_ON_ACCENT;
		} };
		default { {
			params ["_hit"];
			[_hit getVariable QPVAR(pieces), [UI_C_FIELD_HOVER, UI_C_RAISED] select (_hit getVariable [QPVAR(hover), false])] call PFUNC(ui_panelColor);
			(_hit getVariable QPVAR(text)) ctrlSetTextColor UI_C_TEXT;
		} };
	};
};

private _hit = [_ctx, QPVAR(ctrlHit), _pos] call PFUNC(ui_dialogAdd);
_hit setVariable [QPVAR(pieces), _pieces];
_hit setVariable [QPVAR(text), _text];
_hit setVariable [QPVAR(paint), _paint];

_hit ctrlAddEventHandler ["MouseEnter", {
	params ["_hit"];
	_hit setVariable [QPVAR(hover), true];
	[_hit] call (_hit getVariable QPVAR(paint));
}];
_hit ctrlAddEventHandler ["MouseExit", {
	params ["_hit"];
	_hit setVariable [QPVAR(hover), false];
	[_hit] call (_hit getVariable QPVAR(paint));
}];

[_hit] call _paint;
_hit
