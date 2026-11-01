#include "..\..\script_component.hpp"


// Increase the default radius by setting 'PVAR(SaveRadius)' to larger number.
params [["_mode","",[""]],["_input",[],[[]]]];

switch _mode do {
	case "attributesChanged3DEN";
	case "init": {
		_input params [["_logic",objNull,[objNull]],["_isActivated",true,[true]], ["_isCuratorPlaced",false,[true]]];
		
		// In MP only run for local client.
		if (!local _logic) exitWith {};

		// Delete the module to prevent any dependencies.
		if (_logic isKindOf "Logic") then {
			if (_isCuratorPlaced) then {deleteVehicle _logic} else {delete3DENEntities [_logic]};
		};

		// Leave the placement mode, the module is done with one click
		[] call PFUNC(endPlacement);
		
		[_isCuratorPlaced] spawn {
			params ["_isCuratorPlaced"];
			([get3DENMouseOver, curatorMouseOver] select _isCuratorPlaced) params [["_mouseType", ""], ["_mouseObj", objNull]];
			
			if (_mouseType != "Object" || {isNull _mouseObj}) exitWith {
				[LLSTRING(ModuleSaveBuildingScheme_NoBuilding), "ERROR"] call PFUNC(misc_logMsg);
			};
			
			private _bldArr = [_mouseObj] select {((_x buildingPos -1) isNotEqualTo []) || typeOf _x in (missionNamespace getVariable [QPVAR(additionalBuildings), []])};
			
			// Don't continue if array is empty.
			if (_bldArr isEqualTo [] && inputAction "LookAround" < 1) exitWith {
				[LLSTRING(ModuleSaveBuildingScheme_Invalid), "ERROR"] call PFUNC(misc_logMsg);
			};
			
			// Array is empty, but 'LookAround' was pressed, force the object.
			if (_bldArr isEqualTo []) then { _bldArr = [_mouseObj] };
			
			private _keyObj = _bldArr select 0;
			private _keyObjType = typeOf _keyObj;
			private _nearObjects = _keyObj nearObjects ((sizeOf _keyObjType) + (missionNamespace getVariable [QPVAR(SaveRadius),5]));
			private _lines = [_keyObj, _nearObjects] call PFUNC(saveBuildingScheme_toConfig);

			copyToClipboard (_lines joinString toString [13, 10]);
			diag_log text format ["********** [ZEIC - BUILDING OUTPUT ""%1""] **********", _keyObjType];
			{ diag_log text _x } forEach _lines;
			[format [LLSTRING(ModuleSaveBuildingScheme_Done), _keyObjType, { (_x select [0, 13]) == "            {" } count _lines], "INFO"] call PFUNC(misc_logMsg);
			if ((_keyObj call BIS_fnc_getPitchBank) isNotEqualTo [0,0]) then {
				// Warn if building has been rotated (objects are not offset according to the building)
				// TODO: Add support for all building angles?
				[LLSTRING(ModuleSaveBuildingScheme_NotLevel), "WARNING"] call PFUNC(misc_logMsg);
			};
			if (toLowerANSI worldName != "vr") then {
				[LLSTRING(ModuleSaveBuildingScheme_NotVR), "WARNING"] call PFUNC(misc_logMsg);
			};
		};
	};
};

true
