#include "../../script_component.hpp"

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
		
		PVAR(UiLastBuilding) = objNull;
		
		// Find nearest building
		private _nearArr = (nearestObjects [(screenToWorld getMousePosition), [], 25, true]) select { count (_x buildingPos -1) > 0 };
		if (count _nearArr > 0) then { PVAR(UiLastBuilding) = _nearArr select 0 };
		
		if (isNull PVAR(UiLastBuilding)) exitWith { ["No valid buildings within 25m", "ERROR"] call PFUNC(misc_logMsg) };
		
		if ((inputAction "lookAround") isEqualTo 1) then {
			if (isNil QPVAR(UiGarrisonFaction) || isNil QPVAR(UiGarrisonCategory) || isNil QPVAR(UiGarrisonDynamic)) exitWith { ["Select your faction in the GUI first!", "ERROR"] call PFUNC(misc_logMsg) };
			[
				format["%1#%2", PVAR(UiGarrisonFaction), PVAR(UiGarrisonCategory)],
				4,
				missionNamespace getVariable [QPVAR(UiGarrisonDynamic), true],
				missionNamespace getVariable [QPVAR(UiCreateTrigger), false]
			] call PFUNC(ui_garrisonBuilding);
		} else {
			// Start Display 1702
			if (_isCuratorPlaced) then { 
				findDisplay 312 createDisplay "Rsc_ZEIC_GarrisonBuilding";  // Zeus
			} else {
				if (is3DEN) then {
					findDisplay 313 createDisplay "Rsc_ZEIC_GarrisonBuilding"; // Eden
				} else {
					createDialog "Rsc_ZEIC_GarrisonBuilding";
				};
			};
		};
	};
};

true
