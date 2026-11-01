#include "..\..\script_component.hpp"

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

		// Leave the placement mode, the module is done with one click
		[] call PFUNC(endPlacement);

		PVAR(UiLastPosition) = screenToWorld getMousePosition;
		PVAR(UiLastBuilding) = call PFUNC(interiorFill_findBuilding);

		if (isNull PVAR(UiLastBuilding)) exitWith {
			[format [LLSTRING(NoBuilding), LLSTRING(ModuleAdvancedFill_DisplayName)], "ERROR"] call PFUNC(misc_logMsg);
		};

		// Alt repeats the last fill with all its settings, incl. which parts are on
		if ((call PFUNC(modifiers_get)) == "alt") then {
			if (isNil QPVAR(UiAdvancedFill)) exitWith { [LLSTRING(ModuleAdvancedFill_NoLast), "ERROR"] call PFUNC(misc_logMsg) };
			[PVAR(UiAdvancedFill)] call PFUNC(ui_advancedFill);
		} else {
			// Start Display 1706
			if (_isCuratorPlaced) then {
				findDisplay 312 createDisplay "Rsc_ZEIC_AdvancedFill";  // Zeus
			} else {
				if (is3DEN) then {
					findDisplay 313 createDisplay "Rsc_ZEIC_AdvancedFill"; // Eden
				} else {
					createDialog "Rsc_ZEIC_AdvancedFill";
				};
			};
		};
	};
};

true
