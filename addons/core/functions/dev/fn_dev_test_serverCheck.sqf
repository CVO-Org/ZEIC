#include "..\..\script_component.hpp"

/*
* Self test: the server check (PFUNC(misc_serverCheck)). Singleplayer is always the server, so
* PVAR(dev_asClient) makes the check act like a client and PVAR(serverActive) is removed to play a
* server without ZEIC. A real dedicated server without ZEIC still has to be tested by hand.
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

// T30 server check
private _fnc_waitQueue = {
	private _timeout = diag_tickTime + 60;
	waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };
};
private _fnc_units = { params ["_bld"]; (_bld nearEntities ["CAManBase", 30]) select { !isPlayer _x } };
private _fnc_cleanUp = { params ["_bld"]; { deleteVehicle _x } forEach ([_bld] call _fnc_units) };
// Closes the message box of a refusal. It pauses singleplayer, so wait in real time (uiSleep), not with sleep.
private _fnc_closeBox = {
	uiSleep 0.5;
	uiNamespace setVariable ["BIS_fnc_guiMessage_status", false];
	uiSleep 0.5;
};
// Runs the code, returns the refused [module, part], or [] if nothing was refused
private _fnc_refused = {
	PVAR(dev_refused) = [];
	call _this;
	PVAR(dev_refused)
};

private _interiorFill = localize "STR_ZEIC_core_ModuleInteriorFill_DisplayName";
private _garrisonBuilding = localize "STR_ZEIC_core_ModuleGarrisonBuilding_DisplayName";
private _advancedFill = localize "STR_ZEIC_core_ModuleAdvancedFill_DisplayName";
private _trigger = localize "STR_ZEIC_core_ModuleGarrisonBuilding_Trigger";
private _interior = localize "STR_ZEIC_core_ModuleAdvancedFill_Interior";

["T30.1 the server announces ZEIC", missionNamespace getVariable [QPVAR(serverActive), false]] call PFUNC(dev_check);
["T30.2 passes on the server", [_interiorFill] call PFUNC(misc_serverCheck)] call PFUNC(dev_check);

// ---- a client whose server runs ZEIC
PVAR(dev_asClient) = true;
["T30.3 passes on a client when the server runs ZEIC", [_interiorFill] call PFUNC(misc_serverCheck)] call PFUNC(dev_check);

// ---- a client whose server doesn't run ZEIC
private _serverActive = missionNamespace getVariable [QPVAR(serverActive), true];
PVAR(serverActive) = nil;

// Compare which displays are open, not how many: other displays may close meanwhile
private _before = allDisplays;
private _result = [_interiorFill] call PFUNC(misc_serverCheck);
uiSleep 0.5;
private _box = allDisplays - _before;
call _fnc_closeBox;
["T30.4 fails on a client when the server doesn't run ZEIC", !_result] call PFUNC(dev_check);
if (isNull findDisplay 312) then {
	["T30.5 outside Zeus, a message box opens and can be closed", _box isNotEqualTo [] && {(_box findIf { !isNull _x }) == -1}, [_box apply { ctrlIDD _x }, _box apply { isNull _x }]] call PFUNC(dev_check);
} else {
	diag_log text "[ZEIC TEST] SKIP T30.5 Zeus is open, the feedback message is shown instead";
};

// Interior Fill module: refused before the dialog
private _logic = "Module_F" createVehicleLocal PVAR(dev_origin);
private _refused = { ["init", [_logic, true, false]] call PFUNC(mod_interiorFill) } call _fnc_refused;
call _fnc_closeBox;
["T30.6 Interior Fill module refused, no dialog", _refused isEqualTo [_interiorFill, ""] && {isNull findDisplay 1705}, _refused] call PFUNC(dev_check);
if (!isNull findDisplay 1705) then { (findDisplay 1705) closeDisplay 2 };
if (!isNull _logic) then { deleteVehicle _logic };

// Garrison Building: only the trigger needs the server
private _bld = [DEV_HOUSE, 90] call PFUNC(dev_spawn);
PVAR(UiLastBuilding) = _bld;
_refused = { ["BLU_F#EdSubcat_Personnel", 50, false, true, 0, 50] call PFUNC(ui_garrisonBuilding) } call _fnc_refused;
call _fnc_closeBox;
call _fnc_waitQueue;
["T30.7 Garrison Building with the trigger refused, no units", _refused isEqualTo [_garrisonBuilding, _trigger] && {([_bld] call _fnc_units) isEqualTo []}, [_refused, count ([_bld] call _fnc_units)]] call PFUNC(dev_check);

_refused = { ["BLU_F#EdSubcat_Personnel", 50, false, false, 0, 50] call PFUNC(ui_garrisonBuilding) } call _fnc_refused;
call _fnc_waitQueue;
["T30.8 Garrison Building without the trigger works", _refused isEqualTo [] && {([_bld] call _fnc_units) isNotEqualTo []}, [_refused, count ([_bld] call _fnc_units)]] call PFUNC(dev_check);
[_bld] call _fnc_cleanUp;

// Advanced Fill: the interior and the trigger need the server
_bld = [DEV_HOUSE, 91] call PFUNC(dev_spawn);
PVAR(UiLastBuilding) = _bld;
private _settings = createHashMapFromArray [["interior", true], ["garrison", false], ["category", 0], ["radius", 0]];
_refused = { [_settings] call PFUNC(ui_advancedFill) } call _fnc_refused;
call _fnc_closeBox;
call _fnc_waitQueue;
["T30.9 Advanced Fill with the interior refused, not furnished", _refused isEqualTo [_advancedFill, _interior] && {isNull (_bld getVariable [QPVAR(furnished), objNull])}, _refused] call PFUNC(dev_check);

_settings = createHashMapFromArray [["interior", false], ["garrison", true], ["pair", ["BLU_F", "EdSubcat_Personnel"]], ["positions", 50], ["trigger", true], ["radius", 0]];
_refused = { [_settings] call PFUNC(ui_advancedFill) } call _fnc_refused;
call _fnc_closeBox;
call _fnc_waitQueue;
["T30.10 Advanced Fill with the trigger refused, no units", _refused isEqualTo [_advancedFill, _trigger] && {([_bld] call _fnc_units) isEqualTo []}, [_refused, count ([_bld] call _fnc_units)]] call PFUNC(dev_check);

_settings set ["trigger", false];
_refused = { [_settings] call PFUNC(ui_advancedFill) } call _fnc_refused;
call _fnc_waitQueue;
["T30.11 Advanced Fill, garrison without the trigger works", _refused isEqualTo [] && {([_bld] call _fnc_units) isNotEqualTo []}, [_refused, count ([_bld] call _fnc_units)]] call PFUNC(dev_check);
[_bld] call _fnc_cleanUp;

// ---- back to normal
PVAR(serverActive) = _serverActive;
PVAR(dev_asClient) = nil;
PVAR(dev_refused) = nil;
sleep 0.5;
