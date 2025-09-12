#include "../../script_component.hpp"


// Called from PFUNC(createTemplate). Finds a suitable '_templates' array according to the passed '_tempType'.
params ["_bld", ["_tempType", "mil"], ["_infoOnly", false]];

private _bldType = typeOf _bld;

[format ["Passed - B: %1 T: %2 I: %3", _bldType, _tempType, _infoOnly], "DEBUG"] call PFUNC(misc_logMsg);

// Fix Case
_tempType = toLower _tempType;

// Assign appropriate furnishing template for house			
private _templates = [];

// Find any user-created custom buildings.
private _customTemplate = missionNamespace getVariable [format["ZEIC_%1_customBuildings", _tempType], []];

if (_customTemplate isNotEqualTo []) then {
	private _path = [_customTemplate, _bldType] call BIS_fnc_findNestedElement;
	
	if (_path isNotEqualTo []) then {
		(_customTemplate # (_path # 0)) params ["", ["_values", [], [[]]]];
		_templates append _values;
	};
};

_templates append switch (_tempType) do {

	case "cbrn": {
		
		switch (_bldType) do {
			// CBRN Vanilla
			#include "..\..\templates\cbrn_vanilla.sqf"
			
			default {[]};
		};
	};

	case "civ": {
		
		switch (_bldType) do {
			// CDLCs		
			if (PVAR(isLoaded_gm)) then {
				#include "..\..\templates\civ_gm.sqf"
			};
			if (PVAR(isLoaded_ws)) then {
				#include "..\..\templates\civ_ws.sqf"
			};

			// Mods
			if (PVAR(isLoaded_cup)) then {
				#include "..\..\templates\civ_cup.sqf"
			};

			// Vanilla
			#include "..\..\templates\civ_vanilla.sqf"

			default {[]};
		};
	};

	case "mil": {
		
		switch (_bldType) do {

			// CDLCs
			if (PVAR(isLoaded_gm)) then {
				#include "..\..\templates\mil_gm.sqf"
			};

			if (PVAR(isLoaded_sog)) then {
				#include "..\..\templates\mil_sog.sqf"
			};

			if (PVAR(isLoaded_ws)) then {
				#include "..\..\templates\mil_ws.sqf"
			};

			// Mods		
			if (PVAR(isLoaded_cup)) then {
				#include "..\..\templates\mil_cup.sqf"
			};

			// Vanilla
			#include "..\..\templates\mil_vanilla.sqf"
			
			// OTHER
			#include "..\..\templates\mil_other.sqf"
			
			default {[]};
		}

	};

	case "optre_mil": {

		switch (_bldType) do {
			// OPTRE Military
			#include "..\..\templates\optre_military.sqf"
			
			default {[]};
		};
	};

	case "optre_civ": {
		
		switch (_bldType) do {
			// OPTRE Vanilla
			#include "..\..\templates\optre_civilian.sqf"
			
			default {[]};
		};
	};

	default {[]};
};


private _before = count _templates;

// Scan for spawnable templates for the current modset
_templates = _templates select {[_x] call PFUNC(templateCanSpawn)};

if (_before isNotEqualTo count _templates) then {
	// TODO: Really needed? PFUNC(randomiseObject) will replace any invalid objects in a template. 
	[format ["Template(s) removed due to invalid objects (%3): Before %1 | After: %2", _before, count _templates, toUpper _tempType], "WARNING"] call PFUNC(misc_logMsg);
};

// Don't spam messages if there is an area to fill
if (!_infoOnly && {_templates isEqualTo []} && sizeOf _bldType > 2) then {
	[format ["Building Not Found: %1 (%2) - We need your help to get a template/scheme for this building!", _bldType,  getText (configFile >> "CfgVehicles" >> _bldType >> "displayName")], "INFO"] call PFUNC(misc_logMsg);
}; 

_templates
