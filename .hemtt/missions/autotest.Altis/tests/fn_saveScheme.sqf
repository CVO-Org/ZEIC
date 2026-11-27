#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* Save Building Scheme writes a template in config syntax that reads back to the same objects.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["saveScheme"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["Save Building Scheme writes a template in config syntax that reads back to the same objects", {
        params ["_ctx"];

        // T21 Save Building Scheme (config output)
        private _bld = [DEV_HOUSE, 44] call autotest_helper_fnc_spawn;
        private _pallet = createVehicle ["Land_Pallets_F", _bld modelToWorld [1, 2, 0], [], 0, "CAN_COLLIDE"];
        _pallet setDir (getDir _bld + 90);
        private _offset = _bld worldToModel (getPosATL _pallet);

        private _lines = [_bld, [_bld, _pallet]] call PFUNC(saveBuildingScheme_toConfig);
        { diag_log text format ["[ZEIC TEST] INFO T21 %1", _x] } forEach _lines;

        ["building class with one template", (format ["class %1 {", DEV_HOUSE]) in _lines && {(_lines findIf { (_x find "    class saved_") == 0 }) != -1}] call autotest_fnc_check;

        // The object line as an array: config braces to SQF brackets
        private _objectLines = _lines select { (_x find "            {") == 0 };
        private _read = if (count _objectLines == 1) then {
            parseSimpleArray ("[" + (((_objectLines select 0) splitString "{}") joinString "") + "]")
        } else { [] };
        ["only the pallet is saved, not the building", count _objectLines == 1, count _objectLines] call autotest_fnc_check;

        // "{"Land_Pallets_F", {1.000, 2.000, 0.000}, 90}" -> ["Land_Pallets_F", 1, 2, 0, 90]
        _read params [["_class", ""], ["_x0", 0], ["_y0", 0], ["_z0", 0], ["_dir", -1]];
        ["class, position and direction read back",
            _class == "Land_Pallets_F" && {([_x0, _y0, _z0] vectorDistance _offset) < 0.01} && {_dir == 90},
            [_read, _offset]] call autotest_fnc_check;

        // The header the submission form and tools\import-template.ps1 rely on
        private _categoryLine = _lines param [_lines findIf { (_x find "// Category: ") == 0 }, ""];
        ["header names the building, a category and the mods",
            (format ["// Building: %1", DEV_HOUSE]) in _lines
            && {"// Required mods: none (vanilla)" in _lines}
            && {((_categoryLine select [13]) splitString " ") param [0, ""] in ["mil", "civ", "cbrn"]},
            _lines select [0, 6]] call autotest_fnc_check;

        deleteVehicle _pallet;
    }, 180]
]
