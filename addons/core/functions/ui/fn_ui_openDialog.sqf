#include "..\..\script_component.hpp"

/*
* Opens a ZEIC dialog where the modules open theirs: on the Zeus display, on Eden's, or as a dialog.
*
* Arguments:
* 0: Display class, e.g. "Rsc_ZEIC_GarrisonBuilding" <STRING>
*
* Return Value:
* None
*
* Public: No
*/

params [["_class", "", [""]]];

if (is3DEN) exitWith { findDisplay 313 createDisplay _class };
if (!isNull findDisplay 312) exitWith { findDisplay 312 createDisplay _class };
createDialog _class;
