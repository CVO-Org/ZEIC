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
		PVAR(UiLastBuilding) = objNull;
		PVAR(UiLastPosition) = screenToWorld getMousePosition;
		
		if (is3DEN) then {
			//systemChat str get3DENMouseOver;
			if (get3DENMouseOver # 0 == "Object") then { PVAR(UiLastBuilding) = get3DENMouseOver # 1;  };
		} else {
			//systemChat str curatorMouseOver;
			if (curatorMouseOver # 0 == "Object") then { PVAR(UiLastBuilding) = curatorMouseOver # 1 };
		};
		
		// If object isn't valid, reset it
		// Buildings, and other objects (e.g. tents) only if a category has templates for them; not e.g. a weapon on the ground
		private _type = typeOf PVAR(UiLastBuilding);
		private _hasTemplates = (call PFUNC(interiorFill_categories)) findIf {
			isClass (configFile >> "CfgZEIC" >> (_x select 1) >> _type) || {isClass (missionConfigFile >> "CfgZEIC" >> (_x select 1) >> _type)}
		} != -1 || {_type in (missionNamespace getVariable [QPVAR(additionalBuildings), []])};
		if !(PVAR(UiLastBuilding) isKindOf "building" || _hasTemplates) then { PVAR(UiLastBuilding) = objNull };
						
		// Find a valid nearby building.
		if (isNull PVAR(UiLastBuilding)) then {
			private _nearArr = nearestObjects [(screenToWorld getMousePosition), ["building"], 25, true];
			private _objArr = _nearArr select { sizeOf typeOf _x > 2 || (_x buildingPos -1) isNotEqualTo [] };

			if (_objArr isNotEqualTo []) then { PVAR(UiLastBuilding) = _objArr select 0 };
		};
		
		if (isNull PVAR(UiLastBuilding)) exitWith {
			[LLSTRING(MSG_NoBuilding), "ERROR"] call PFUNC(misc_logMsg);
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
