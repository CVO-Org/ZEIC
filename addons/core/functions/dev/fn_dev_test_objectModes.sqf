#include "..\..\script_component.hpp"

/*
* Self test: The three object modes of Interior Fill (simple, normal, editable).
* Part of PFUNC(dev_selfTest), needs its scheduled environment.
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

private _houseClass = DEV_HOUSE;

// T9 object modes (#22)
{
	_x params ["_mode", "_name", "_expectSimple"];
	private _bld = [_houseClass, 30 + _mode] call PFUNC(dev_spawn);
	isNil { [[_bld], "mil", [_mode, false, 1]] call PFUNC(interiorFill_start) };

	private _timeout = diag_tickTime + 15;
	waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };

	private _obj = _bld getVariable ["ZEIC_furnished", objNull];
	[format ["T9.%1 mode %1 (%2) spawns %3", _mode, _name, ["normal objects", "simple objects"] select _expectSimple],
		!isNull _obj && {isSimpleObject _obj isEqualTo _expectSimple}, [_obj, isSimpleObject _obj]] call PFUNC(dev_check);

	if (_mode == 2) then {
		if (allCurators isEqualTo []) then {
			diag_log text "[ZEIC TEST] SKIP T9.2b no curator in the mission";
		} else {
			["T9.2b editable objects are added to the curator", _obj in curatorEditableObjects (allCurators select 0)] call PFUNC(dev_check);
		};
	} else {
		if (allCurators isNotEqualTo []) then {
			[format ["T9.%1b objects are not added to the curator", _mode], !(_obj in curatorEditableObjects (allCurators select 0))] call PFUNC(dev_check);
		};
	};
} forEach [
	[0, "simple", true],
	[1, "objects", false],
	[2, "editable in Zeus", false]
];
