#include "..\..\script_component.hpp"

/*
* Adds a rounded panel to a ZEIC dialog: three rectangles and four corner pictures that meet without
* overlapping, so a see-through colour shows no seams. A radius of 0 gives a plain rectangle.
*
*   TL | Mid | TR      Mid runs the full height,
*   Lft|     | Rgt     Lft and Rgt only between the corners.
*   BL |     | BR
*
* Arguments:
* 0: Dialog context <HASHMAP>
* 1: Relative position [x, y, w, h] <ARRAY>
* 2: Corner radius (height units) <NUMBER>
* 3: Colour <ARRAY>
*
* Return Value:
* Pieces [mid, left, right, tl, tr, bl, br] or [rect] <ARRAY of CONTROLs>
*
* Public: No
*/

params ["_ctx", ["_pos", [0, 0, 0, 0], [[]], 4], ["_radius", 0, [0]], ["_color", UI_C_FIELD, [[]], 4]];

private _pieces = [];
// A plain rectangle needs one piece
for "_i" from 1 to ([1, 3] select (_radius > 0)) do { _pieces pushBack ([_ctx, QPVAR(ctrlRect), _pos] call PFUNC(ui_dialogAdd)) };
if (_radius > 0) then {
	{
		private _corner = [_ctx, QPVAR(ctrlCorner), _pos] call PFUNC(ui_dialogAdd);
		_corner ctrlSetText _x;
		_pieces pushBack _corner;
	} forEach [UI_TEX(corner_tl_ca), UI_TEX(corner_tr_ca), UI_TEX(corner_bl_ca), UI_TEX(corner_br_ca)];
};

[_pieces, _pos, _radius] call PFUNC(ui_panelLayout);
[_pieces, _color] call PFUNC(ui_panelColor);
_pieces
