#include "..\..\script_component.hpp"

params [["_mode","",[""]],["_input",[],[[]]]];

switch _mode do {
	case "attributesChanged3DEN";
	case "init": {
		_input params [["_logic",objNull,[objNull]],["_isActivated",true,[true]], ["_isCuratorPlaced",false,[true]]];
		
		// In MP only run for local client.
		if (!local _logic) exitWith {};
		
		if (!_isActivated) then { _logic setVariable ["bis_fnc_initModules_activate", true, !isServer] };

		// A target of an earlier placement must never be reused (#66)
		PVAR(UiLastObject) = objNull;
		private _modulePos = getPosATL _logic;

		// Delete the module to prevent any dependencies.
		if (_logic isKindOf "Logic") then {
			if (is3DEN) then { delete3DENEntities [_logic] } else { deleteVehicle _logic };
		};

		// Leave the placement mode, the module is done with one click
		[] call PFUNC(endPlacement);

		// Store the Object under the cursor or nearest of type. The module itself can still be under the cursor
		// (deleting it takes effect at the end of the frame), so logics don't count.
		private _mouseOver = [curatorMouseOver, get3DENMouseOver] select is3DEN;
		private _source = "mouse-over";
		if (_mouseOver param [0, ""] == "Object" && {!((_mouseOver # 1) isKindOf "Logic")}) then {
			PVAR(UiLastObject) = _mouseOver # 1;
		} else {
			_source = "nearest";
			PVAR(UiLastObject) = (nearestObjects [_modulePos, ["Thing"], 10, true]) param [0, objNull];
		};
		[format ["Object Fill target: %1 (%2, mode %3, module at %4) | old mouse search: %5 at %6", typeOf PVAR(UiLastObject), _source, _mode, _modulePos,
			(nearestObjects [screenToWorld getMousePosition, ["Thing"], 10, true]) apply { typeOf _x }, screenToWorld getMousePosition], "INFO"] call PFUNC(misc_logMsg);

		if (isNull PVAR(UiLastObject)) exitWith { [LLSTRING(ModuleObjectFill_NoObject), "ERROR"] call PFUNC(misc_logMsg) };

		// Start Display 1704
		if ((inputAction "lookAround") isEqualTo 1) then {
			// Skip the dialog, use the last settings
			[
				missionNamespace getVariable [QPVAR(UiObjectFillType), ""],
				missionNamespace getVariable [QPVAR(UiObjectFillPercent), 30],
				missionNamespace getVariable [QPVAR(UiObjectFillObjects), OBJECT_MODE_SIMPLE]
			] call PFUNC(ui_objectFill);
		} else {
			// Eden, Zeus, or the mission display when called by script (self test)
			private _parent = findDisplay ([312, 313] select is3DEN);
			if (isNull _parent) then { _parent = findDisplay 46 };
			_parent createDisplay "Rsc_ZEIC_ObjectFill";
		};
	};
};

true
