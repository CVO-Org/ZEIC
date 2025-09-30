#include "../script_component.hpp"

params [["_mode","",[""]],["_input",[],[[]]]];

switch _mode do {
	case "attributesChanged3DEN";
	case "init": {
		_input params [["_logic",objNull,[objNull]],["_isActivated",true,[true]], ["_isCuratorPlaced",false,[true]]];
		
		// In MP only run for local client.
		if (!local _logic) exitWith {};
		
		if (!_isActivated) then { _logic setVariable ["bis_fnc_initModules_activate", true, !isServer] };
		
		// Delete the module to prevent any dependencies.
		if (_logic isKindOf "Logic") then {
			if (is3DEN) then { delete3DENEntities [_logic] } else { deleteVehicle _logic };
		};
		
		// Store the Object under the cursor or nearest of type.
		if (is3DEN) then {
			//systemChat str get3DENMouseOver;
			if (get3DENMouseOver # 0 == "Object") then {
				PVAR(UiLastObject) = get3DENMouseOver # 1;
			} else {
				PVAR(UiLastObject) = (nearestObjects [screenToWorld getMousePosition, ["Thing"], 10, true]) param [0, objNull];
			};
		} else {
			//systemChat str curatorMouseOver;
			if (curatorMouseOver # 0 == "Object") then {
				PVAR(UiLastObject) = curatorMouseOver # 1;
			} else {
				PVAR(UiLastObject) = (nearestObjects [screenToWorld getMousePosition, ["Thing"], 10, true]) param [0, objNull];
			};
		};
		
		// Start Display 1704
		if ((inputAction "lookAround") isEqualTo 1) then {
			// Skip UI and use default values.
			[] call PFUNC(ui_objectFill);
		} else {
			if (is3DEN) then {
				findDisplay 313 createDisplay "Rsc_ZEIC_ObjectFill"; // Eden
			} else {
				findDisplay 312 createDisplay "Rsc_ZEIC_ObjectFill";  // Zeus
			};
		};
	};
};

true
