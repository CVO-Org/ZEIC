#include "..\..\script_component.hpp"

// Spawns some markers indicating building positions within the object.
// This is intended to highlight positions to avoid when decorating houses.
params [["_mode","",[""]],["_input",[],[[]]]];

[format["Passed Mode: %1 - Input: %2", _mode, _input], "DEBUG"] call PFUNC(misc_logMsg);

switch _mode do {
	case "attributesChanged3DEN";
	case "init": {
		_input params [["_logic",objNull,[objNull]],["_isActivated",true,[true]], ["_isCuratorPlaced",false,[true]]];
		
		// In MP only run for local client.
		if (!local _logic) exitWith {};

		private _pos = getPosATL _logic;

		// Delete the module to prevent any dependencies.
		if (_logic isKindOf "Logic") then {
			if (is3DEN) then { delete3DENEntities [_logic] } else { deleteVehicle _logic };
		};

		// Leave the placement mode, the module is done with one click
		[] call PFUNC(endPlacement);

		// The nearest building with positions (the module is deleted either way)
		private _bldArr = (nearestObjects [_pos, [], 25, true]) select { (_x buildingPos -1) isNotEqualTo [] };
		if (_bldArr isEqualTo []) exitWith { [format [LLSTRING(NoBuilding), LLSTRING(ModuleMarkPositions_DisplayName)], "ERROR"] call PFUNC(misc_logMsg) };
		_bldArr resize 1;
				
		collect3DENHistory {
			{ 
				private _bld = _x;
				private _bPos = _bld buildingPos -1;
				if (_bPos isNotEqualTo []) then {
					{		
						private _obj = create3DENEntity ["Object", ["Sign_Arrow_Large_Green_F", "Sign_Arrow_Large_Blue_F"] select surfaceIsWater _x, [0, 0, 0]];
						_obj set3DENAttribute ["rotation", [ 0, 0, 0]];
						_obj set3DENAttribute ["description", format["Building Position: %1", _bPos find _x]];
						if (surfaceIsWater _x) then {
							_obj set3DENAttribute ["position", ASLToATL _x]							
						} else {
							_obj set3DENAttribute ["position", _x]
						};
					} forEach _bPos;
				};
			} forEach _bldArr;
		};
	};
};

true
