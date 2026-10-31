/*
    ZEIC self test

    Runs automatically on scenario start via init.sqf (preview / singleplayer).
    To run it again manually, from the debug console (not in the Eden editor itself):
        [] execVM "zeic_selftest.sqf";

    Every check writes one line to the RPT, prefixed with [ZEIC TEST].
    Failed checks are also shown in chat. A summary is printed at the end.
    Test buildings are spawned around [1000, 1000] and left in place for inspection.
*/

ZEIC_test_results = [];
ZEIC_test_check = {
    params ["_name", "_ok", ["_info", ""]];
    private _line = format ["[ZEIC TEST] %1 %2", ["FAIL", "PASS"] select _ok, _name];
    if (_info isNotEqualTo "") then { _line = _line + " | " + str _info };
    diag_log text _line;
    if (!_ok) then { systemChat _line };
    ZEIC_test_results pushBack _ok;
};
ZEIC_test_spawn = {
    params ["_class", "_index"];
    createVehicle [_class, [1000 + 150 * _index, 1000, 0], [], 0, "CAN_COLLIDE"]
};

diag_log text format ["[ZEIC TEST] ===== start | is3DEN %1 | ZEN %2 | GM %3 | CUP %4 =====",
    is3DEN,
    isClass (configFile >> "CfgPatches" >> "zen_common"),
    isClass (configFile >> "CfgPatches" >> "gm_core"),
    isClass (configFile >> "CfgPatches" >> "CUP_Editor_Buildings_Config")
];

// ---------------------------------------------------------------- T0 CfgPatches (#29)
private _cfgCore = configFile >> "CfgPatches" >> "ZEIC_core";
["T0.1 CfgPatches ZEIC_core exists", isClass _cfgCore] call ZEIC_test_check;
["T0.2 CfgPatches ZEIC_main exists", isClass (configFile >> "CfgPatches" >> "ZEIC_main")] call ZEIC_test_check;
["T0.3 no CfgPatches named ADDON", !isClass (configFile >> "CfgPatches" >> "ADDON")] call ZEIC_test_check;
["T0.4 ZEIC_core requires ZEIC_main", (getArray (_cfgCore >> "requiredAddons") findIf { _x == "ZEIC_main" }) != -1, getArray (_cfgCore >> "requiredAddons")] call ZEIC_test_check;

private _curatorModules = getArray (_cfgCore >> "units") select { getNumber (configFile >> "CfgVehicles" >> _x >> "scopeCurator") == 2 };
["T0.5 ZEIC_core lists the 4 Zeus modules", count _curatorModules == 4, _curatorModules] call ZEIC_test_check;
["T0.6 Zeus module injection removed", isNil "ZEIC_fnc_zeus_addModules"] call ZEIC_test_check;

// ---------------------------------------------------------------- T1 all functions compiled (#29, #30)
private _functions = [];
{
    { _functions pushBack format ["ZEIC_fnc_%1", configName _x] } forEach ("true" configClasses _x);
} forEach ("true" configClasses (configFile >> "CfgFunctions" >> "ZEIC"));
private _broken = _functions select { !((missionNamespace getVariable [_x, 0]) isEqualType {}) };
["T1 all ZEIC functions compiled", _broken isEqualTo [], [count _functions, _broken]] call ZEIC_test_check;

// ---------------------------------------------------------------- T2 templateCanSpawn (#29)
["T2.1 valid template accepted",
    [[["Land_Pallets_F", [0,0,0], 0], ["Land_Sack_F", [1,0,0], 0]]] call ZEIC_fnc_templateCanSpawn] call ZEIC_test_check;
["T2.2 invalid SECOND object rejected",
    !([[["Land_Pallets_F", [0,0,0], 0], ["Does_Not_Exist_F", [1,0,0], 0]]] call ZEIC_fnc_templateCanSpawn)] call ZEIC_test_check;
["T2.3 invalid FIRST object rejected",
    !([[["Does_Not_Exist_F", [0,0,0], 0], ["Land_Pallets_F", [1,0,0], 0]]] call ZEIC_fnc_templateCanSpawn)] call ZEIC_test_check;

// ---------------------------------------------------------------- T3 randomiseObject (#29)
private _rnd = ["Does_Not_Exist_F"] call ZEIC_fnc_randomiseObject;
["T3.1 invalid class returns empty string", _rnd isEqualTo "", _rnd] call ZEIC_test_check;
_rnd = ["Land_Pallets_F", false] call ZEIC_fnc_randomiseObject;
["T3.2 no randomisation keeps the class", _rnd isEqualTo "Land_Pallets_F", _rnd] call ZEIC_test_check;
_rnd = ["Land_GasTank_01_blue_F"] call ZEIC_fnc_randomiseObject;
["T3.3 variant stays in its group", _rnd in ["Land_GasTank_01_blue_F", "Land_GasTank_01_yellow_F", "Land_GasTank_01_khaki_F"], _rnd] call ZEIC_test_check;

// ---------------------------------------------------------------- T4 addCustomTemplate (#29)
ZEIC_mil_customBuildings = nil;
ZEIC_civ_customBuildings = nil;
ZEIC_cbrn_customBuildings = nil;

private _houseClass = "Land_i_House_Small_03_V1_F";
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

private _ret = ["mil", _houseClass + ": " + str _tPallet] call ZEIC_fnc_addCustomTemplate;
["T4.1 legacy string format returns true", _ret isEqualTo true, _ret] call ZEIC_test_check;
["T4.2 legacy string stored under mil", (["mil"] call _countFor) == 1, ["mil"] call _countFor] call ZEIC_test_check;

_ret = ["civ", _houseClass + ": " + str _tBucket] call ZEIC_fnc_addCustomTemplate;
["T4.3 civ stored under civ, not mil", _ret isEqualTo true && {(["civ"] call _countFor) == 1} && {(["mil"] call _countFor) == 1}, [_ret, ["civ"] call _countFor, ["mil"] call _countFor]] call ZEIC_test_check;

// Same format as the Save Building Scheme module, including the [MOD] prefix and CRLF line breaks
private _br = toString [13, 10];
private _scheme = format ['case "%3%1": {%4        [%4            %2%4        ];%4    };', _houseClass, str _tSack, "[MOD] ", _br];
_ret = ["mil", _scheme] call ZEIC_fnc_addCustomTemplate;
["T4.4 Save Building Scheme clipboard format", _ret isEqualTo true && {(["mil"] call _countFor) == 2}, [_ret, ["mil"] call _countFor]] call ZEIC_test_check;

_ret = ["cbrn", [toLower _houseClass, _tPallet]] call ZEIC_fnc_addCustomTemplate;
private _storedName = (missionNamespace getVariable ["ZEIC_cbrn_customBuildings", [[""]]]) select 0 select 0;
["T4.5 array format, any category, config spelling", _ret isEqualTo true && {_storedName isEqualTo _houseClass}, [_ret, _storedName]] call ZEIC_test_check;

_ret = ["mil", [_houseClass, _tInvalid]] call ZEIC_fnc_addCustomTemplate;
["T4.6 template with invalid object is stored (filtered later)", _ret isEqualTo true, _ret] call ZEIC_test_check;

_ret = ["mil", "Not_A_Building_F: " + str _tPallet] call ZEIC_fnc_addCustomTemplate;
["T4.7 unknown building returns false", _ret isEqualTo false, _ret] call ZEIC_test_check;
_ret = ["", "x"] call ZEIC_fnc_addCustomTemplate;
["T4.8 empty category returns false", _ret isEqualTo false, _ret] call ZEIC_test_check;

// ---------------------------------------------------------------- T5 findTemplates uses custom templates (#29)
private _house = [_houseClass, 0] call ZEIC_test_spawn;
private _mil = [_house, "mil", true] call ZEIC_fnc_findTemplates;
private _civ = [_house, "civ", true] call ZEIC_fnc_findTemplates;
private _hasInvalid = _mil findIf { (_x findIf { (_x select 0) == "Does_Not_Exist_F" }) != -1 } != -1;

["T5.1 mil includes custom pallet + sack", (_tPallet in _mil) && {_tSack in _mil}, count _mil] call ZEIC_test_check;
["T5.2 mil excludes the civ bucket", !(_tBucket in _mil)] call ZEIC_test_check;
["T5.3 civ includes the bucket, not the pallet", (_tBucket in _civ) && {!(_tPallet in _civ)}, count _civ] call ZEIC_test_check;
["T5.4 template with invalid object filtered out", !_hasInvalid] call ZEIC_test_check;

// ---------------------------------------------------------------- T6 merged duplicate cases (#30)
{
    _x params ["_class", "_category", "_min"];
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _bld = [_class, _forEachIndex + 1] call ZEIC_test_spawn;
        private _count = count ([_bld, _category, true] call ZEIC_fnc_findTemplates);
        [format ["T6.%1 %2 (%3) has >= %4 templates", _forEachIndex + 1, _class, _category, _min], _count >= _min, _count] call ZEIC_test_check;
    } else {
        diag_log text format ["[ZEIC TEST] SKIP T6.%1 %2 not loaded", _forEachIndex + 1, _class];
    };
} forEach [
    ["Land_Mine_01_warehouse_F", "mil", 2],
    ["Land_dp_bigTank_old_F", "mil", 2],
    ["Land_Radar_01_antenna_base_F", "mil", 2],
    ["Land_Cargo_Tower_V1_No1_F", "mil", 1],
    ["Land_DeconTent_01_yellow_F", "cbrn", 2],
    ["Land_DeconTent_01_white_F", "cbrn", 2],
    ["Land_DeconTent_01_IDAP_F", "cbrn", 2]
];

// ---------------------------------------------------------------- T7 createTemplate actually spawns (#29, #30)
ZEIC_mil_customBuildings = nil;
ZEIC_civ_customBuildings = nil;
ZEIC_cbrn_customBuildings = nil;

private _house2 = [_houseClass, 10] call ZEIC_test_spawn;
private _simpleBefore = count allSimpleObjects [];
[_house2, "civ", false, false, false, 1] call ZEIC_fnc_createTemplate;
private _simpleSpawned = (count allSimpleObjects []) - _simpleBefore;
["T7.1 simple-object fill spawns objects", _simpleSpawned > 0, _simpleSpawned] call ZEIC_test_check;
["T7.2 building marked as furnished", !isNull (_house2 getVariable ["ZEIC_furnished", objNull])] call ZEIC_test_check;

private _house3 = [_houseClass, 11] call ZEIC_test_spawn;
private _nearBefore = count nearestObjects [_house3, [], 25];
[_house3, "mil", false, true, false, 1] call ZEIC_fnc_createTemplate;
sleep 1;
private _nearSpawned = (count nearestObjects [_house3, [], 25]) - _nearBefore;
["T7.3 editable-object fill spawns objects", _nearSpawned > 0, _nearSpawned] call ZEIC_test_check;

private _again = count allSimpleObjects [];
[_house2, "civ", false, false, false, 1] call ZEIC_fnc_createTemplate;
["T7.4 furnished building is not filled twice", (count allSimpleObjects []) == _again] call ZEIC_test_check;

// ---------------------------------------------------------------- T8 processing queue + feedback (#22)
private _queueHouses = [];
for "_i" from 0 to 4 do { _queueHouses pushBack ([_houseClass, 20 + _i] call ZEIC_test_spawn) };
private _noTemplate = ["Land_WoodenCrate_01_F", 25] call ZEIC_test_spawn;

// Budget 0 = exactly one step per frame, so the fill must take many frames
ZEIC_queueBudget = 0;

// Start unscheduled, so nothing can run in between
private _queuedRightAway = false;
private _frameStart = diag_frameNo;
isNil {
    [_queueHouses + [_noTemplate], "mil", [false, false, 1]] call ZEIC_fnc_interiorFill_start;
    _queuedRightAway = (missionNamespace getVariable ["ZEIC_queue", []]) isNotEqualTo []
        && {isNull ((_queueHouses select 0) getVariable ["ZEIC_furnished", objNull])};
};
["T8.1 fill is queued, not done in the same frame", _queuedRightAway] call ZEIC_test_check;

private _timeout = diag_tickTime + 30;
waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };
private _frames = diag_frameNo - _frameStart;
ZEIC_queueBudget = nil;

["T8.2 queue finished within 30 s", (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo []] call ZEIC_test_check;
private _furnishedCount = { !isNull (_x getVariable ["ZEIC_furnished", objNull]) } count _queueHouses;
["T8.3 all 5 houses furnished", _furnishedCount == 5, _furnishedCount] call ZEIC_test_check;
["T8.4 spread over many frames (one step each)", _frames > 20, _frames] call ZEIC_test_check;
["T8.5 queue event handler removed when empty", isNil "ZEIC_queueEH"] call ZEIC_test_check;

private _colorOf = {
    params ["_bld"];
    private _index = _bld getVariable ["ZEIC_feedbackIndex", -1];
    if (_index == -1) exitWith { [] };
    (missionNamespace getVariable ["ZEIC_feedback", []]) select _index select 2
};
private _houseColors = _queueHouses apply { [_x] call _colorOf };
["T8.6 furnished houses shown green", (_houseColors findIf { _x isNotEqualTo [0,1,0,1] }) == -1, _houseColors] call ZEIC_test_check;
["T8.7 building without template shown red", ([_noTemplate] call _colorOf) isEqualTo [1,0,0,1], [_noTemplate] call _colorOf] call ZEIC_test_check;
["T8.8 no-template building not marked as queued", !(_noTemplate getVariable ["ZEIC_queued", false])] call ZEIC_test_check;

sleep 6;
["T8.9 wireframes cleared after the fill", (missionNamespace getVariable ["ZEIC_feedback", []]) isEqualTo [] && {isNil "ZEIC_feedbackEH"}] call ZEIC_test_check;

private _simpleBeforeRefill = count allSimpleObjects [];
[_queueHouses, "mil", [false, false, 1]] call ZEIC_fnc_interiorFill_start;
sleep 1;
["T8.10 furnished houses are not filled again", (count allSimpleObjects []) == _simpleBeforeRefill] call ZEIC_test_check;

// ---------------------------------------------------------------- T9 object modes (#22)
{
    _x params ["_mode", "_name", "_expectSimple"];
    private _bld = [_houseClass, 30 + _mode] call ZEIC_test_spawn;
    isNil { [[_bld], "mil", [_mode, false, 1]] call ZEIC_fnc_interiorFill_start };

    private _timeout = diag_tickTime + 15;
    waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };

    private _obj = _bld getVariable ["ZEIC_furnished", objNull];
    [format ["T9.%1 mode %1 (%2) spawns %3", _mode, _name, ["normal objects", "simple objects"] select _expectSimple],
        !isNull _obj && {isSimpleObject _obj isEqualTo _expectSimple}, [_obj, isSimpleObject _obj]] call ZEIC_test_check;

    if (_mode == 2) then {
        if (allCurators isEqualTo []) then {
            diag_log text "[ZEIC TEST] SKIP T9.2b no curator in the mission";
        } else {
            ["T9.2b editable objects are added to the curator", _obj in curatorEditableObjects (allCurators select 0)] call ZEIC_test_check;
        };
    } else {
        if (allCurators isNotEqualTo []) then {
            [format ["T9.%1b objects are not added to the curator", _mode], !(_obj in curatorEditableObjects (allCurators select 0))] call ZEIC_test_check;
        };
    };
} forEach [
    [0, "simple", true],
    [1, "objects", false],
    [2, "editable in Zeus", false]
];

// ---------------------------------------------------------------- summary
private _passed = { _x } count ZEIC_test_results;
private _failed = (count ZEIC_test_results) - _passed;
private _summary = format ["[ZEIC TEST] ===== done | %1 passed | %2 failed =====", _passed, _failed];
diag_log text _summary;
systemChat _summary;
