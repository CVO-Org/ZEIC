#include "..\..\script_component.hpp"

/*
* Self test: Save Building Scheme writes a template in config syntax that reads back to the same objects.
* Part of PFUNC(dev_selfTest).
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

// T21 Save Building Scheme (config output)
private _bld = [DEV_HOUSE, 44] call PFUNC(dev_spawn);
private _pallet = createVehicle ["Land_Pallets_F", _bld modelToWorld [1, 2, 0], [], 0, "CAN_COLLIDE"];
_pallet setDir (getDir _bld + 90);
private _offset = _bld worldToModel (getPosATL _pallet);

private _lines = [_bld, [_bld, _pallet]] call PFUNC(saveBuildingScheme_toConfig);
{ diag_log text format ["[ZEIC TEST] INFO T21 %1", _x] } forEach _lines;

["T21.1 building class with one template", (format ["class %1 {", DEV_HOUSE]) in _lines && {(_lines findIf { (_x find "    class saved_") == 0 }) != -1}] call PFUNC(dev_check);

// The object line as an array: config braces to SQF brackets
private _objectLines = _lines select { (_x find "            {") == 0 };
private _read = if (count _objectLines == 1) then {
	parseSimpleArray ("[" + (((_objectLines select 0) splitString "{}") joinString "") + "]")
} else { [] };
["T21.2 only the pallet is saved, not the building", count _objectLines == 1, count _objectLines] call PFUNC(dev_check);

// "{"Land_Pallets_F", {1.000, 2.000, 0.000}, 90}" -> ["Land_Pallets_F", 1, 2, 0, 90]
_read params [["_class", ""], ["_x0", 0], ["_y0", 0], ["_z0", 0], ["_dir", -1]];
["T21.3 class, position and direction read back",
	_class == "Land_Pallets_F" && {([_x0, _y0, _z0] vectorDistance _offset) < 0.01} && {_dir == 90},
	[_read, _offset]] call PFUNC(dev_check);

deleteVehicle _pallet;
