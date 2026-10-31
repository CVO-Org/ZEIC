#include "..\..\script_component.hpp"

/*
* Adds a numbered Eden layer: "001 - name", the number following the layers already inside the parent.
* With a root name instead of a parent, the top-level layer of that name is used (and created if it
* doesn't exist yet), so the fills of a module stay together across saves.
*
*   ZEIC Interiors              <- root
*     001 - Military            <- one layer per fill
*       001 - House (Large)     <- one layer per building
*
* Arguments:
* 0: Parent layer ID, or the name of a root layer <NUMBER or STRING>
* 1: Name, after the number <STRING>
*
* Return Value:
* Layer ID <NUMBER>
*
* Public: No
*/

params [["_parent", -1, [0, ""]], ["_name", "", [""]]];

if (_parent isEqualType "") then {
	private _rootName = _parent;
	private _layers = (all3DENEntities select 6) select { ((_x get3DENAttribute "name") param [0, ""]) == _rootName };
	_parent = if (_layers isEqualTo []) then { -1 add3DENLayer _rootName } else { _layers select 0 };
};

private _number = 1 + ({ _x isEqualType 0 } count (get3DENLayerEntities _parent));
private _padded = str _number;
while { count _padded < 3 } do { _padded = "0" + _padded };

_parent add3DENLayer format ["%1 - %2", _padded, _name]
