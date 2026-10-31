#include "..\..\script_component.hpp"

/*
* Picks the next template for a building (round-robin, so neighbouring buildings get different layouts).
*
* Arguments:
* 0: Building <OBJECT>
* 1: Category, e.g. "mil" <STRING>
* 2: Info only: don't ask for a template in chat if there is none <BOOL>
*
* Return Value:
* Object entries of the template, [] if the building has no template <ARRAY>
*
* Public: No
*/

params [["_bld", objNull, [objNull]], ["_category", "mil", [""]], ["_infoOnly", true, [true]]];

private _templates = [_bld, _category, _infoOnly] call PFUNC(findTemplates);
if (_templates isEqualTo []) exitWith { [] };

if (isNil QPVAR(counter)) then { PVAR(counter) = 0 };
if (PVAR(counter) >= count _templates) then { PVAR(counter) = 0 };
private _items = _templates select PVAR(counter);
PVAR(counter) = PVAR(counter) + 1;

_items
