#include "..\..\script_component.hpp"

/*
* Colours a rounded panel (see PFUNC(ui_dialogPanel)): the rectangles' background, the corners' tint.
*
* Arguments:
* 0: Pieces <ARRAY of CONTROLs>
* 1: Colour <ARRAY>
*
* Return Value:
* None
*
* Public: No
*/

params [["_pieces", [], [[]]], ["_color", UI_C_FIELD, [[]], 4]];

{
	if (_forEachIndex < 3) then { _x ctrlSetBackgroundColor _color } else { _x ctrlSetTextColor _color };
} forEach _pieces;
