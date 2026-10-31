#include "..\..\script_component.hpp"

// Fills the category list of the Interior Fill dialog, see PFUNC(interiorFill_categories).
{ (findDisplay 1705 displayCtrl 10) lbAdd (_x select 0) } forEach (call PFUNC(interiorFill_categories));
