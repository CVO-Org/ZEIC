#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* the Object Fill type "Electronics (old)" (#65): listed right after "Electronics (modern)", a fill with it places
* only its objects (incl. the subclasses of the template addons), and the "Cold War era" fill modifier keeps them all.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["objectFillTypes"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The Object Fill type 'Electronics (old)' (#65)", {
        params ["_ctx"];

        // T29 Object Fill: Electronics (old) (#65)
        private _cfgType = configFile >> "CfgZEIC_ObjectFill" >> "Types" >> "electronicsOld";
        private _objects = getArray (_cfgType >> "objects");
        { _objects append getArray (_x >> "objects") } forEach ("true" configClasses _cfgType);
        _objects = _objects select { isClass (configFile >> "CfgVehicles" >> _x) };

        // ---- the dialog lists it right after Electronics (modern); it needs a target object to stay open
        private _table = ["Land_TablePlastic_01_F", 88] call autotest_helper_fnc_spawn;
        PVAR(UiLastObject) = _table;
        PVAR(UiObjectFillType) = "electronicsOld";
        createDialog "Rsc_ZEIC_ObjectFill";
        private _dlg = findDisplay 1704;
        private _types = _dlg getVariable [QPVAR(types), []];
        private _index = _types find "electronicsOld";
        private _ctrl = _dlg getVariable ["type_ctrl", controlNull];
        private _names = [_ctrl lbText (_index - 1), _ctrl lbText _index];
        ["listed and preselected, right after Electronics (modern)",
            _index > 0 && {(_types select (_index - 1)) == "electric"} && {(_dlg getVariable ["type", -1]) == _index} && {_names isEqualTo [LLSTRING(ModuleObjectFill_Type_Electric), LLSTRING(ModuleObjectFill_Type_ElectronicsOld)]},
            [_types, _names]] call autotest_fnc_check;
        _dlg closeDisplay 2;

        // ---- a fill places only its objects (and the floor object under the table)
        private _before = allSimpleObjects [];
        ["electronicsOld", 100, OBJECT_MODE_SIMPLE] call PFUNC(ui_objectFill);
        private _placed = ((allSimpleObjects []) - _before) apply { toLower typeOf _x };
        private _allowed = (_objects + [getText (_cfgType >> "floor")]) apply { toLower _x };
        private _wrong = _placed select { !(_x in _allowed) };
        ["a fill places only its objects", _placed isNotEqualTo [] && {_wrong isEqualTo []}, [count _placed, _wrong arrayIntersect _wrong]] call autotest_fnc_check;

        // ---- none of them is removed or replaced by the Cold War era fill modifier
        private _modifiers = [["coldwar"]] call PFUNC(fillModifiers_resolve);
        private _changed = _objects select { ([_x, _modifiers] call PFUNC(fillModifiers_apply)) != _x };
        ["the Cold War era fill modifier keeps all of them", _changed isEqualTo [], _changed] call autotest_fnc_check;
    }, 180]
]
