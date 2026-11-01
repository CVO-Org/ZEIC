#include "..\..\script_component.hpp"

/*
* Furnishes and/or garrisons buildings in one go: per building the interior first, then the garrison.
* Both parts are the existing jobs of the processing queue: the interior is done by PFUNC(interiorFill_start)
* (on the server in multiplayer), the garrison by PFUNC(garrisonBuilding_start) (units stay local to this client).
* With both parts, they share a link id: the garrison of a building waits until the interior job reports it done
* (see PFUNC(advancedFill_interiorDone), PFUNC(advancedFill_waitForInterior)).
* In Eden both jobs put their entities into one layer tree, see PFUNC(advancedFill_layer).
*
* Arguments:
* 0: Buildings <ARRAY of OBJECTs>
* 1: Interior [category <STRING>, options <ARRAY>], [] for none - see PFUNC(interiorFill_start) <ARRAY>
* 2: Garrison [faction class <STRING>, subcategory class <STRING>, options <ARRAY>], [] for none
*    - see PFUNC(garrisonBuilding_start) <ARRAY>
*
* Return Value:
* None
*
* Example:
* [[cursorObject], ["mil", [0, false]], ["BLU_F", "EdSubcat_Personnel", [50, false, false]]] call ZEIC_fnc_advancedFill_start
*
* Public: Yes
*/

params [["_buildings", [], [[]]], ["_interior", [], [[]]], ["_garrison", [], [[]]]];

private _linkId = "";

// Eden: one layer for the whole fill, named after its parts ("CSAT + Military"), created with its first building
private _layers = createHashMap;
if (is3DEN) then {
	private _names = [];
	if (_garrison isNotEqualTo []) then { _names pushBack getText (configFile >> "CfgFactionClasses" >> (_garrison param [0, ""]) >> "displayName") };
	if (_interior isNotEqualTo []) then {
		private _category = _interior param [0, "mil"];
		_names pushBack (((call PFUNC(interiorFill_categories)) select { (_x select 1) == _category }) param [0, [toUpper _category]] select 0);
	};
	_layers set ["name", _names joinString " + "];
};

if (_garrison isNotEqualTo []) then {
	_garrison params [["_faction", "", [""]], ["_subcat", "", [""]], ["_options", [], [[]]]];
	_options params [["_percent", 50], ["_forceDS", false], ["_createTR", false]];

	// Only linked if the garrison job was queued (it isn't without units or buildings with positions)
	private _id = if (_interior isEqualTo []) then { "" } else { format ["%1:%2:%3", clientOwner, diag_frameNo, floor random 1e6] };
	private _jobs = count (missionNamespace getVariable [QPVAR(queue), []]);
	[_buildings, _faction, _subcat, [_percent, _forceDS, _createTR, _id, _layers]] call PFUNC(garrisonBuilding_start);
	if (count (missionNamespace getVariable [QPVAR(queue), []]) > _jobs) then { _linkId = _id };
};

if (_interior isNotEqualTo []) then {
	_interior params [["_category", "mil", [""]], ["_options", [], [[]]]];
	[_buildings, _category, _options, _linkId, _layers] call PFUNC(interiorFill_start);
};
