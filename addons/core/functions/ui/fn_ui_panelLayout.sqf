#include "..\..\script_component.hpp"

/*
* Lays out the pieces of a rounded panel (see PFUNC(ui_dialogPanel)) at a relative position.
* Edges and sizes are rounded to whole screen pixels, so the pieces meet exactly.
*
* Arguments:
* 0: Pieces <ARRAY of CONTROLs>
* 1: Relative position [x, y, w, h] <ARRAY>
* 2: Corner radius (height units) <NUMBER>
*
* Return Value:
* None
*
* Public: No
*/

params [["_pieces", [], [[]]], ["_pos", [0, 0, 0, 0], [[]], 4], ["_radius", 0, [0]]];

private _fnc_snapX = { (round (_this / pixelW)) * pixelW };
private _fnc_snapY = { (round (_this / pixelH)) * pixelH };

_pos params ["_x", "_y", "_w", "_h"];
_x = _x call _fnc_snapX;
_y = _y call _fnc_snapY;
_w = _w call _fnc_snapX;
_h = _h call _fnc_snapY;

if (count _pieces == 1) exitWith {
	(_pieces select 0) setVariable [QPVAR(relPos), [_x, _y, _w, _h]];
};

// Square corners on screen: the same number of pixels both ways
private _rh = (_radius min (_h / 2)) call _fnc_snapY;
private _rw = (_rh / pixelH) * pixelW;

_pieces params ["_mid", "_left", "_right", "_tl", "_tr", "_bl", "_br"];
_mid setVariable [QPVAR(relPos), [_x + _rw, _y, _w - 2 * _rw, _h]];
_left setVariable [QPVAR(relPos), [_x, _y + _rh, _rw, _h - 2 * _rh]];
_right setVariable [QPVAR(relPos), [_x + _w - _rw, _y + _rh, _rw, _h - 2 * _rh]];
_tl setVariable [QPVAR(relPos), [_x, _y, _rw, _rh]];
_tr setVariable [QPVAR(relPos), [_x + _w - _rw, _y, _rw, _rh]];
_bl setVariable [QPVAR(relPos), [_x, _y + _h - _rh, _rw, _rh]];
_br setVariable [QPVAR(relPos), [_x + _w - _rw, _y + _h - _rh, _rw, _rh]];
