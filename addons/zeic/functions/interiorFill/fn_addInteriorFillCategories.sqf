#include "../../script_component.hpp"

/*
* Author: Zorn
* Function to fill the dynamically fill UI with Categories
*
* Arguments:
*
* Return Value:
* None
*
* Example:
* ['something', player] call prefix_component_fnc_functionname
*
* Public: No
*/


if (isNil QPVAR(interiorFillCategories) ) then {

    private _array = [
        // Display Name, Fill Type
        ["Military", "mil"],
        ["Civilian", "civ"],
        ["CBRN", "cbrn"]
    ];

    if PVAR(isLoaded_optre) then {
        _array pushBack ["OPTRE - Military", "optre_mil"];
        _array pushBack ["OPTRE - Civilian", "optre_civ"];
    };

    PVAR(interiorFillCategories) = _array;
};

{ (findDisplay 1705 displayCtrl 10) lbAdd (_x select 0) } forEach PVAR(interiorFillCategories);
