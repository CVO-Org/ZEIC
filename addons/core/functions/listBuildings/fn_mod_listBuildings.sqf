#include "..\..\script_component.hpp"

params [["_mode","",[""]],["_input",[],[[]]]];

switch _mode do {
	case "attributesChanged3DEN";
	case "init": {
		_input params [["_logic",objNull,[objNull]],["_isActivated",true,[true]], ["_isCuratorPlaced",false,[true]]];
		
		// In MP only run for local client.
		if (!local _logic) exitWith {};
		
		// Delete the module to prevent any dependencies.
		if (_logic isKindOf "Logic") then {
			if (is3DEN) then { delete3DENEntities [_logic] } else { deleteVehicle _logic };
		};

		// Leave the placement mode, the module is done with one click
		[] call PFUNC(endPlacement);
		
		if (toLowerANSI worldName != "vr") exitWith {
			[LLSTRING(MSG_VROnly), "ERROR"] call PFUNC(misc_logMsg)
		};
		
		// Start Display 1702
		if (_isCuratorPlaced) then { 
			findDisplay 312 createDisplay "Rsc_ZEIC_ListBuildings";  // Zeus
		} else {
			if (is3DEN) then {
				findDisplay 313 createDisplay "Rsc_ZEIC_ListBuildings"; // Eden
			} else {
				createDialog "Rsc_ZEIC_ListBuildings";
			};
		};
	};
};

true
