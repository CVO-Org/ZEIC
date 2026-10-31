#include "..\..\script_component.hpp"

/*
* Places every building class with positions in rows (VR world, for template authors), each with one arrow
* per template below it: one row of arrows per category. Buildings with more templates than the maximum
* in a listed category are left out.
*
* Arguments:
* 0: Category class, "" for all categories <STRING>
* 1: Maximum number of templates <NUMBER>
* 2: Mark the building positions <BOOL>
*
* Return Value:
* None
*
* Public: No
*/

params [["_category", "", [""]], ["_maxTemplates", 15, [0]], ["_showPositions", false, [false]]];

private _categories = call PFUNC(interiorFill_categories);
if (_category != "") then { _categories = _categories select { (_x select 1) == _category } };

// One arrow colour per category, repeated if there are more categories
private _arrows = [
	["Sign_Arrow_Large_F", "red"],
	["Sign_Arrow_Large_Pink_F", "pink"],
	["Sign_Arrow_Large_Yellow_F", "yellow"],
	["Sign_Arrow_Large_Blue_F", "blue"],
	["Sign_Arrow_Large_Cyan_F", "cyan"]
];
{
	[format ["List Buildings: %1 = %2 arrows", _x select 0, (_arrows select (_forEachIndex mod count _arrows)) select 1], "INFO"] call PFUNC(misc_logMsg);
} forEach _categories;

private _fnc_create = {
	params ["_class", "_pos"];
	if (is3DEN) then {
		create3DENEntity ["Object", _class, _pos, true]
	} else {
		createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"]
	};
};
private _fnc_delete = {
	if (is3DEN) then { delete3DENEntities [_this] } else { deleteVehicle _this };
};

private _classNames = ("configName _x isKindOf 'Building' && {getNumber (_x >> 'scope') == 2}" configClasses (configFile >> "CfgVehicles")) apply { configName _x };
_classNames = _classNames select { (toLowerANSI _x find "ruin") == -1 };
[format ["Processing %1 classes.", count _classNames], "INFO"] call PFUNC(misc_logMsg);

private _origin = [1000, 1000, 0];
private _count = 0;
{
	private _pos = _origin vectorAdd [75 * (_count mod 75), 10 * (floor (_count / 75)) * 75, 0];
	private _bld = [_x, _pos] call _fnc_create;

	private _counts = if ((_bld buildingPos -1) isEqualTo []) then { [] } else {
		_categories apply { count ([_bld, _x select 1, true] call PFUNC(findTemplates)) }
	};

	if (_counts isEqualTo [] || {(_counts findIf { _x > _maxTemplates }) != -1}) then {
		_bld call _fnc_delete;
	} else {
		// One row of arrows per category below the building
		private _edge = abs ((boundingBox _bld) select 1 select 0);
		{
			private _arrow = (_arrows select (_forEachIndex mod count _arrows)) select 0;
			for "_i" from 1 to _x do {
				[_arrow, _pos vectorAdd [_i * 2, -_edge - 10 - 5 * _forEachIndex, 0]] call _fnc_create;
			};
		} forEach _counts;

		if (_showPositions) then {
			{ ["Sign_Arrow_Large_Green_F", _x] call _fnc_create } forEach (_bld buildingPos -1);
		};
		_count = _count + 1;
	};
} forEach _classNames;

[format ["Output %1 buildings with positions.", _count], "INFO"] call PFUNC(misc_logMsg);
