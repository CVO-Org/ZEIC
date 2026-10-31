#include "..\..\script_component.hpp"

/*
* Self test: The script API for custom templates (addCustomTemplate, findTemplates) and randomiseObject.
* Part of PFUNC(dev_selfTest), needs its scheduled environment.
*
* Arguments:
* None
*
* Return Value:
* None
*
* Public: No
*/

// T2 templates with missing objects are skipped (#29, #24)
private _t2Valid = [["Land_Pallets_F", [0,0,0], 0], ["Land_Sack_F", [1,0,0], 0]];
private _t2Second = [["Land_Pallets_F", [0,0,0], 0], ["Does_Not_Exist_F", [1,0,0], 0]];
private _t2First = [["Does_Not_Exist_F", [0,0,0], 0], ["Land_Pallets_F", [1,0,0], 0]];
ZEIC_mil_customBuildings = [["Land_i_House_Small_03_V1_F", [_t2Valid, _t2Second, _t2First]]];
private _t2Found = ["Land_i_House_Small_03_V1_F", "mil", true] call PFUNC(findTemplates);
["T2.1 valid template kept", _t2Valid in _t2Found] call PFUNC(dev_check);
["T2.2 template with missing SECOND object skipped", !(_t2Second in _t2Found)] call PFUNC(dev_check);
["T2.3 template with missing FIRST object skipped", !(_t2First in _t2Found)] call PFUNC(dev_check);
ZEIC_mil_customBuildings = nil;

// T3 randomiseObject (#29)
private _rnd = ["Does_Not_Exist_F"] call PFUNC(randomiseObject);
["T3.1 invalid class returns empty string", _rnd isEqualTo "", _rnd] call PFUNC(dev_check);
_rnd = ["Land_Pallets_F", false] call PFUNC(randomiseObject);
["T3.2 no randomisation keeps the class", _rnd isEqualTo "Land_Pallets_F", _rnd] call PFUNC(dev_check);
_rnd = ["Land_GasTank_01_blue_F"] call PFUNC(randomiseObject);
["T3.3 variant stays in its group", _rnd in ["Land_GasTank_01_blue_F", "Land_GasTank_01_yellow_F", "Land_GasTank_01_khaki_F"], _rnd] call PFUNC(dev_check);

// T4 addCustomTemplate (#29)
ZEIC_mil_customBuildings = nil;
ZEIC_civ_customBuildings = nil;
ZEIC_cbrn_customBuildings = nil;

private _houseClass = DEV_HOUSE;
private _tPallet = [["Land_Pallets_F", [0,0,0.5], 90]];
private _tBucket = [["Land_Bucket_F", [0,0,0.5], 0]];
private _tSack = [["Land_Sack_F", [0,0,0.5], 0]];
private _tInvalid = [["Does_Not_Exist_F", [0,0,0.5], 0]];

private _countFor = {
	params ["_category"];
	private _list = missionNamespace getVariable [format ["ZEIC_%1_customBuildings", _category], []];
	private _index = _list findIf { (_x select 0) == _houseClass };
	if (_index == -1) exitWith { -1 };
	count (_list select _index select 1)
};

private _ret = ["mil", _houseClass + ": " + str _tPallet] call PFUNC(addCustomTemplate);
["T4.1 legacy string format returns true", _ret isEqualTo true, _ret] call PFUNC(dev_check);
["T4.2 legacy string stored under mil", (["mil"] call _countFor) == 1, ["mil"] call _countFor] call PFUNC(dev_check);

_ret = ["civ", _houseClass + ": " + str _tBucket] call PFUNC(addCustomTemplate);
["T4.3 civ stored under civ, not mil", _ret isEqualTo true && {(["civ"] call _countFor) == 1} && {(["mil"] call _countFor) == 1}, [_ret, ["civ"] call _countFor, ["mil"] call _countFor]] call PFUNC(dev_check);

// Same format as the Save Building Scheme module, including the [MOD] prefix and CRLF line breaks
private _br = toString [13, 10];
private _scheme = format ['case "%3%1": {%4        [%4            %2%4        ];%4    };', _houseClass, str _tSack, "[MOD] ", _br];
_ret = ["mil", _scheme] call PFUNC(addCustomTemplate);
["T4.4 Save Building Scheme clipboard format", _ret isEqualTo true && {(["mil"] call _countFor) == 2}, [_ret, ["mil"] call _countFor]] call PFUNC(dev_check);

_ret = ["cbrn", [toLower _houseClass, _tPallet]] call PFUNC(addCustomTemplate);
private _storedName = (missionNamespace getVariable ["ZEIC_cbrn_customBuildings", [[""]]]) select 0 select 0;
["T4.5 array format, any category, config spelling", _ret isEqualTo true && {_storedName isEqualTo _houseClass}, [_ret, _storedName]] call PFUNC(dev_check);

_ret = ["mil", [_houseClass, _tInvalid]] call PFUNC(addCustomTemplate);
["T4.6 template with invalid object is stored (filtered later)", _ret isEqualTo true, _ret] call PFUNC(dev_check);

_ret = ["mil", "Not_A_Building_F: " + str _tPallet] call PFUNC(addCustomTemplate);
["T4.7 unknown building returns false", _ret isEqualTo false, _ret] call PFUNC(dev_check);
_ret = ["", "x"] call PFUNC(addCustomTemplate);
["T4.8 empty category returns false", _ret isEqualTo false, _ret] call PFUNC(dev_check);

// T5 findTemplates uses custom templates (#29)
private _house = [_houseClass, 0] call PFUNC(dev_spawn);
private _mil = [_house, "mil", true] call PFUNC(findTemplates);
private _civ = [_house, "civ", true] call PFUNC(findTemplates);
private _hasInvalid = _mil findIf { (_x findIf { (_x select 0) == "Does_Not_Exist_F" }) != -1 } != -1;

["T5.1 mil includes custom pallet + sack", (_tPallet in _mil) && {_tSack in _mil}, count _mil] call PFUNC(dev_check);
["T5.2 mil excludes the civ bucket", !(_tBucket in _mil)] call PFUNC(dev_check);
["T5.3 civ includes the bucket, not the pallet", (_tBucket in _civ) && {!(_tPallet in _civ)}, count _civ] call PFUNC(dev_check);
["T5.4 template with invalid object filtered out", !_hasInvalid] call PFUNC(dev_check);
