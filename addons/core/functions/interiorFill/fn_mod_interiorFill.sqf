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
			if (is3DEN) then {delete3DENEntities [_logic]} else {deleteVehicle _logic};
		};

		// Leave the placement mode, the module is done with one click
		[] call PFUNC(endPlacement);
		
		// Work out which building to fill. The position is the center of area fills.
		PVAR(UiLastPosition) = screenToWorld getMousePosition;
		PVAR(UiLastBuilding) = call PFUNC(interiorFill_findBuilding);

		if (isNull PVAR(UiLastBuilding)) exitWith {
			[format [LLSTRING(NoBuilding), LLSTRING(ModuleInteriorFill_DisplayName)], "ERROR"] call PFUNC(misc_logMsg);
		};
		
		// Shortcuts skip the dialog: Alt repeats the last fill, a category's shortcut fills that category
		// with the last settings (see the "shortcut" property in CfgZEIC)
		private _shortcut = call PFUNC(modifiers_get);
		private _shortcutCategory = if (_shortcut in ["", "alt"]) then { -1 } else {
			(call PFUNC(interiorFill_categories)) findIf { (_x select 2) == _shortcut }
		};

		if (_shortcut == "alt" || {_shortcutCategory != -1}) then {
			[
				[_shortcutCategory, missionNamespace getVariable [QPVAR(UiInteriorType), 0]] select (_shortcutCategory == -1),
				missionNamespace getVariable[QPVAR(UiInteriorRadius), 0],
				missionNamespace getVariable[QPVAR(UiInteriorObjects), OBJECT_MODE_SIMPLE],
				missionNamespace getVariable[QPVAR(UiInteriorDamage), false],
				missionNamespace getVariable[QPVAR(UiInteriorChance), 100]
			] call PFUNC(ui_interiorFill);
		} else {
			// Start Display 1705
			if (_isCuratorPlaced) then { 
				findDisplay 312 createDisplay "Rsc_ZEIC_InteriorFill";  // Zeus
			} else {
				if (is3DEN) then {
					findDisplay 313 createDisplay "Rsc_ZEIC_InteriorFill"; // Eden
				} else {
					createDialog "Rsc_ZEIC_InteriorFill";
				};
			};
		};
	};
};

true
