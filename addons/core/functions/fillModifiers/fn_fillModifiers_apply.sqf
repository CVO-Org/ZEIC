#include "..\..\script_component.hpp"

/*
* Applies the fill modifiers to one object class, in the order replace -> remove -> keep. Classes match by isKindOf,
* so a parent class covers all its children. The result per class is cached in the modifiers (once per fill).
*
* Arguments:
* 0: Object class <STRING>
* 1: Modifiers, see PFUNC(fillModifiers_resolve) <HASHMAP> (default: empty, none)
*
* Return Value:
* Object class to spawn, "" for nothing <STRING>
*
* Example:
* ["Land_PlasticCase_01_medium_F", [["coldwar"]] call ZEIC_fnc_fillModifiers_resolve] call ZEIC_fnc_fillModifiers_apply
*
* Public: No
*/

params [["_item", "", [""]], ["_modifiers", createHashMap, [createHashMap]]];

if (_item == "" || {count _modifiers == 0}) exitWith { _item };

private _results = _modifiers get "results";
private _key = toLower _item;
if (_key in _results) exitWith { _results get _key };

private _rule = (_modifiers get "replace") findIf { _item isKindOf (_x select 0) };
if (_rule != -1) then { _item = (_modifiers get "replace") select _rule select 1 };

if ((_modifiers get "remove") findIf { _item isKindOf _x } != -1) then { _item = "" };

private _keep = _modifiers get "keep";
if (_item != "" && {_keep isNotEqualTo []} && {_keep findIf { _item isKindOf _x } == -1}) then { _item = "" };

_results set [_key, _item];
_item
