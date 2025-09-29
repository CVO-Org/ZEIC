#include "../../script_component.hpp"

params [
		["_gType", ""],
		["_units", 4],
		["_forceDS", true],
		["_createTR", false]
	];

[format["Passed - F: %1 U: %2 DS: %3 TR: %4", _gType, _units, _forceDS, _createTR], "DEBUG"] call PFUNC(misc_logMsg);
	
private _bld = missionNamespace getVariable [QPVAR(UiLastBuilding), objNull];

// Split out the faction and category classes
(_gType splitString "#") params [["_factClass", ""], ["_catClass", ""]];

// Get all units with a weapon and non-parachute backpack.
private _tempList = "getText (_x >> 'faction') == _factClass && getText (_x >> 'editorSubcategory') == _catClass && (configName _x) isKindoF 'CAManBase' && getNumber(_x >> 'scope') == 2" configClasses (configFile >> "CfgVehicles");

// Filter out and invalid unit types matching strings.
_fnc_notInString = {
	params ["_type"];
	
	private _notInString = true;
	{
		if (toLower _type find _x >= 0) exitWith { _notInString = false };
	} forEach [ "_story", "_vr", "competitor", "ghillie", "miller", "survivor", "crew", "diver", "pilot", "rangemaster", "uav", "unarmed", "officer" ];
	
	_notInString
};

// Attempt to clear up the units list - Include units with at least one weapon and a non-parachute backpack.
private _menList = _tempList select { ((configName _x) call _fnc_notInString) && (count getArray(_x >> "weapons") > 2) && (toLower getText (_x >> "backpack") find "para" < 0) };

// If no units remain, use the original list.
if (count _menList == 0) then { _menList = _tempList };

// No units exist at all!
if (count _menList == 0) exitWith {
	[format["No units found for faction: %1", _factClass], "ERROR"] call PFUNC(misc_logMsg);
};

// Save UI Settings for next time
PVAR(UiGarrisonFaction) = _factClass;
PVAR(UiGarrisonCategory) = _catClass;
PVAR(UiGarrisonDynamic) = _forceDS;
PVAR(UiCreateTrigger) = _createTR;

private _bldPos = _bld buildingPos -1;

if (is3DEN) then {
	collect3DENHistory {

		private _counter = uiNamespace getVariable [QPVAR(layer_counter), 0];
		private _ZEIC_Layer = -1 add3DENLayer "ZEIC Garrison " + str _counter;
		uiNamespace setVariable [QPVAR(layer_counter), _counter + 1];


		// TODO: Find a neater way to create a group (create3DENComposition)?
		private _tempUnit = switch (getNumber (configFile >> "CfgFactionClasses" >> _factClass >> "side")) do { 
				case 0: { create3DENEntity ["Object", "O_Soldier_F", [0, 0, 0]]; };
				case 1: { create3DENEntity ["Object", "B_Soldier_F", [0, 0, 0]]; };
				default { create3DENEntity ["Object", "I_Soldier_F", [0, 0, 0]]; };
			};
				
		for "_i" from 1 to _units do {
			if (count _bldPos == 0) exitWith {};
			private _rndPos = selectRandom _bldPos;
			_bldPos = _bldPos - [_rndPos];
			[
				group _tempUnit,
				configName (selectRandom _menList),
				_rndPos,
				_bld,
				_ZEIC_Layer
			] call PFUNC(garrisonUnit);
		};
		
		// Set group to be deleted when empty.
		(group _tempUnit) set3DENAttribute ["garbageCollectGroup", true];
		
		// Set dynamicSimulation if forced or all units are inside a building.
		if (({(count (lineIntersectsWith [eyePos _x, ((eyePos _x) vectorAdd [0, 0, 10])] select {_x isKindOf 'Building'}) < 1)} count (units _tempUnit)) == 0 || {_forceDS}) then { 
				(group _tempUnit) set3DENAttribute ["dynamicSimulation", true];
		};
		delete3DENEntities [_tempUnit];
		
		if (_createTR) then {
			private _rad = (round (sizeOf typeOf _bld)) max 40;
			private _trg = create3DENEntity ["Trigger", "EmptyDetector", getPos _bld];
			_trg set3DENLayer _ZEIC_Layer;
			_trg set3DENAttribute ["Size2", [_rad, _rad]];
			_trg set3DENAttribute ["Size3", [_rad, _rad, 15]];
			_trg set3DENAttribute ["IsRectangle", false];
			_trg set3DENAttribute ["ActivationBy", "AnyPlayer"];
			_trg set3DENAttribute ["activationType", "Present"];
			_trg set3DENAttribute ["triggerInterval", 5];
			_trg set3DENAttribute ["onActivation", "{ if (local _x) then { if (!(_x checkAIFeature 'PATH') && random 1 < 0.2) then { doStop _x; _x enableAI 'PATH' }; }; } forEach (allUnits inAreaArray thisTrigger);"];
			_trg set3DENAttribute ["onDeactivation", "{ if (local _x) then { if !(_x checkAIFeature 'PATH') then { _x doFollow leader _x; _x enableAI 'PATH' }; }; } forEach (allUnits inAreaArray thisTrigger);"];
		};
	};
} else {
	// NOT 3DEN
	private _grp = switch (getNumber (configFile >> "CfgFactionClasses" >> _factClass >> "side")) do { 
		case 0: { createGroup [east, true] };
		case 1: { createGroup [west, true] };
		default { createGroup [independent, true] };
	};

	for "_i" from 1 to _units do {
		if (count _bldPos == 0) exitWith {};
		private _rndPos = selectRandom _bldPos;
		_bldPos = _bldPos - [_rndPos];
		[_grp, configName (selectRandom _menList), _rndPos, _bld] call PFUNC(garrisonUnit);
	};
	
	if (_forceDS) then { _grp spawn { sleep 5; _this enableDynamicSimulation true; }; };
	
	if (_createTR) then {
		private _rad = (round (sizeOf typeOf _bld)) max 40;
		private _trg = createTrigger ["EmptyDetector", getPos _bld];
		_trg setTriggerArea [_rad, _rad, 0, false, 15];
		_trg setTriggerActivation ["ANYPLAYER", "PRESENT", false];
		_trg setTriggerInterval 5;
		_trg setTriggerStatements [
			"this", 
			"{ if (local _x) then { if (!(_x checkAIFeature 'PATH') && random 1 < 0.2) then { doStop _x; _x enableAI 'PATH' }; }; } forEach (allUnits inAreaArray thisTrigger);",
			"{ if (local _x) then { if !(_x checkAIFeature 'PATH') then { _x doFollow leader _x; _x enableAI 'PATH' }; }; } forEach (allUnits inAreaArray thisTrigger);"
		];
	};
};
