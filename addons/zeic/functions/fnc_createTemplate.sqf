#include "..\script_component.hpp"

// Called from PFUNC(ui_interiorFill)
params [
		["_bld", objNull],
		["_fillType", "mil"],
		["_fillArea", false],
		["_addZeus", true],
		["_allowDamage", false],
		["_detail", 1]
	];

[format ["Passed - B: %1 T: %2 A: %3 Z: %4 D: %5 M: %6", _bld, _fillType, _fillArea, _addZeus, _allowDamage, _detail], "DEBUG"] call PFUNC(misc_logMsg);
	
// Skip previously processed houses
if (isNull _bld || !isNull (_bld getVariable [QPVAR(furnished), objNull])) exitWith {};

private _templates = [];

_templates = [_bld, _fillType, _fillArea] call PFUNC(findTemplates);

// Furnish house if list is assigned and no people inside
if (_templates isNotEqualTo []) then {

	// Non-random template selection
	if (isNil QPVAR(counter)) then {PVAR(counter) = 0};
	if (PVAR(counter) >= count _templates) then {PVAR(counter) = 0};
	private _items = _templates select PVAR(counter);  
	PVAR(counter) = PVAR(counter) + 1;
	
	// Random template selection
	//_items = selectRandom _templates;
				
	// Spawn items depending on Zeus/Eden
	private _obj = objNull; // Used to track Undo in Eden.
		
	if (is3DEN) then {
		// TODO: Doesn't work in Eden? Find alternative method.
		// _bld set3DENAttribute ["allowDamage", false]; 

		private _counter = uiNamespace getVariable [QPVAR(layer_counter), 0];
		private _ZEIC_Layer = -1 add3DENLayer "ZEIC Interior " + str _counter;
		uiNamespace setVariable [QPVAR(layer_counter), _counter + 1];

		
		{ 
			_x params ["_item", "_offset", ["_angle", 0], ["_rot", [0, 0, 0]]];

			_item = [_item] call PFUNC(randomiseObject);

			if (_item != "" && ([_item, _detail] call PFUNC(checkDetailLevel)) ) then {
				_obj = create3DENEntity ["Object", _item, [0,0,0], true];
				_obj set3DENAttribute ["objectIsSimple", true]; 
				_obj set3DENLayer _ZEIC_Layer;
				_obj setVectorDirAndUp [vectorDir _bld, vectorUp _bld];

				if (_rot isNotEqualTo [0,0,0]) then { 
					// Apply further rotation to object. 
					[_obj, (_rot select 0)*-1] call PFUNC(misc_rotateAroundOwnAxisX);
					[_obj, (_rot select 1)*-1] call PFUNC(misc_rotateAroundOwnAxisY); 
					[_obj, (_rot select 2)*-1] call PFUNC(misc_rotateAroundOwnAxisZ);
				} else {
					[_obj, _angle*-1] call PFUNC(misc_rotateAroundOwnAxisZ);
				};
				
				_obj set3DENAttribute ["rotation", [_obj] call PFUNC(misc_Vector2Eden)];
				
				_pos = (_bld modelToWorld _offset);
				
				if (surfaceIsWater _pos) then {
					_obj set3DENAttribute ["position", ASLToATL _pos];
				} else {
					_obj set3DENAttribute ["position",_pos];
				};
			};
		} forEach _items;		
	} else {
		// Stop floating items when building is destroyed.
		if !(_allowDamage) then { [_bld, false] remoteExecCall ["allowDamage", _bld]; };

		{ 
			_x params ["_item", "_offset", ["_angle", 0], ["_rot", [0, 0, 0]]];
			_item = [_item] call PFUNC(randomiseObject);
			
			if (_item != "" && ([_item, _detail] call PFUNC(checkDetailLevel)) ) then {
				if (_addZeus) then {
					_obj = createVehicle [_item, (_bld modelToWorld _offset), [], 0, "CAN_COLLIDE"];
					[_obj, false] remoteExec ["enableSimulationGlobal", 2];
					{ [_x, [ [_obj], true]] remoteExec ["addCuratorEditableObjects", 2] } forEach allCurators;
				} else {
					_obj = createSimpleObject [_item, AGLToASL (_bld modelToWorld _offset)];
				};
				
				_obj setVectorDirAndUp [vectorDir _bld, vectorUp _bld];
				
				if (_rot isNotEqualTo [0,0,0]) then { 
					// Apply further rotation to object. 
					[_obj, (_rot select 0)*-1] call PFUNC(misc_rotateAroundOwnAxisX);
					[_obj, (_rot select 1)*-1] call PFUNC(misc_rotateAroundOwnAxisY); 
					[_obj, (_rot select 2)*-1] call PFUNC(misc_rotateAroundOwnAxisZ);
				} else {
					[_obj, _angle*-1] call PFUNC(misc_rotateAroundOwnAxisZ);
				};
			};
		} forEach _items;
	};
	
	_bld setVariable [QPVAR(furnished), _obj];
};
