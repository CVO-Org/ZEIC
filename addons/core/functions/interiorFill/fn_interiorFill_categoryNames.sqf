#include "..\..\script_component.hpp"

/*
* Display names of Interior Fill categories, e.g. for Eden layer names. A class that isn't a category is shown in
* upper case.
*
* Arguments:
* 0: Category classes, e.g. ["mil", "civ"] <ARRAY of STRINGs>
*
* Return Value:
* Display names, e.g. ["Military", "Civilian"] <ARRAY of STRINGs>
*
* Public: No
*/

params [["_classes", [], [[]]]];

private _categories = call PFUNC(interiorFill_categories);
_classes apply {
	private _class = toLower _x;
	(_categories select { (_x select 1) == _class }) param [0, [toUpper _class]] select 0
}
