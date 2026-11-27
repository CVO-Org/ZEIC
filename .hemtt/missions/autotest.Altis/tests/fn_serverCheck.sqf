#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* the server check (ZEIC_fnc_misc_serverCheck): the modules that do their work on the server are refused when the
* server doesn't run ZEIC. The preview is the server, so setting ZEIC_serverActive to false plays a server without
* ZEIC. A refusal opens a message box (outside Zeus), which the tests use to tell a refusal from doing nothing.
* A real dedicated server without ZEIC and Zeus's red feedback message still have to be tested by hand.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["serverCheck"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

// Runs the code like on a client of a server without ZEIC. Returns the displays the code opened (the refusal's
// message box), closed again. Compares which displays are open, not how many: others may close meanwhile.
autotest_serverCheck_withoutServer = {
    private _before = allDisplays;
    PVAR(serverActive) = false;
    call _this;
    PVAR(serverActive) = true;
    uiSleep 0.5;
    private _opened = allDisplays - _before;
    // The message box pauses singleplayer: uiSleep, not sleep
    uiNamespace setVariable ["BIS_fnc_guiMessage_status", false];
    uiSleep 0.5;
    _opened
};
autotest_serverCheck_waitQueue = { [{ (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] }, 60] call autotest_fnc_waitFor };
autotest_serverCheck_units = { params ["_bld"]; (_bld nearEntities ["CAManBase", 30]) select { !isPlayer _x } };

[
    ["The server announces ZEIC, the check passes", {
        params ["_ctx"];
        ["ZEIC_serverActive is set", missionNamespace getVariable [QPVAR(serverActive), false]] call autotest_fnc_check;
        ["passes when the server runs ZEIC", [LLSTRING(ModuleInteriorFill_DisplayName)] call PFUNC(misc_serverCheck)] call autotest_fnc_check;
    }],

    ["Without ZEIC on the server: fails, a message box opens and closes", {
        params ["_ctx"];
        private _result = true;
        private _box = { _result = [LLSTRING(ModuleInteriorFill_DisplayName)] call PFUNC(misc_serverCheck) } call autotest_serverCheck_withoutServer;
        ["fails", _result, false] call autotest_fnc_checkEqual;
        if (!isNull findDisplay 312) exitWith { ["Zeus is open, the feedback message is shown instead"] call autotest_fnc_skip };
        ["a message box opened and was closed", _box isNotEqualTo [] && {(_box findIf { !isNull _x }) == -1}, _box apply { isNull _x }] call autotest_fnc_check;
    }],

    ["Interior Fill is refused before its dialog", {
        params ["_ctx"];
        private _logic = "Module_F" createVehicleLocal ZEIC_dev_origin;
        private _box = { ["init", [_logic, true, false]] call PFUNC(mod_interiorFill) } call autotest_serverCheck_withoutServer;
        ["refused with a message box", _box isNotEqualTo [], count _box] call autotest_fnc_check;
        ["no dialog", isNull findDisplay 1705] call autotest_fnc_check;
        if (!isNull findDisplay 1705) then { (findDisplay 1705) closeDisplay 2 };
        if (!isNull _logic) then { deleteVehicle _logic };
    }],

    ["Garrison Building: only the Move AI trigger is refused", {
        params ["_ctx"];
        private _bld = [DEV_HOUSE, 90] call autotest_helper_fnc_spawn;
        PVAR(UiLastBuilding) = _bld;

        private _box = { ["BLU_F#EdSubcat_Personnel", 50, false, true, 0, 50] call PFUNC(ui_garrisonBuilding) } call autotest_serverCheck_withoutServer;
        call autotest_serverCheck_waitQueue;
        ["with the trigger: refused with a message box", _box isNotEqualTo [], count _box] call autotest_fnc_check;
        ["with the trigger: no units", count ([_bld] call autotest_serverCheck_units), 0] call autotest_fnc_checkEqual;

        _box = { ["BLU_F#EdSubcat_Personnel", 50, false, false, 0, 50] call PFUNC(ui_garrisonBuilding) } call autotest_serverCheck_withoutServer;
        call autotest_serverCheck_waitQueue;
        ["without the trigger: no message box", _box, []] call autotest_fnc_checkEqual;
        ["without the trigger: units placed", ([_bld] call autotest_serverCheck_units) isNotEqualTo [], count ([_bld] call autotest_serverCheck_units)] call autotest_fnc_check;

        { deleteVehicle _x } forEach ([_bld] call autotest_serverCheck_units);
    }, 60],

    ["Advanced Fill: the interior and the Move AI trigger are refused", {
        params ["_ctx"];
        private _bld = [DEV_HOUSE, 91] call autotest_helper_fnc_spawn;
        PVAR(UiLastBuilding) = _bld;

        private _settings = createHashMapFromArray [["interior", true], ["garrison", false], ["category", 0], ["radius", 0]];
        private _box = { [_settings] call PFUNC(ui_advancedFill) } call autotest_serverCheck_withoutServer;
        call autotest_serverCheck_waitQueue;
        ["with the interior: refused with a message box", _box isNotEqualTo [], count _box] call autotest_fnc_check;
        ["with the interior: not furnished", isNull (_bld getVariable [QPVAR(furnished), objNull])] call autotest_fnc_check;

        _settings = createHashMapFromArray [["interior", false], ["garrison", true], ["pair", ["BLU_F", "EdSubcat_Personnel"]], ["positions", 50], ["trigger", true], ["radius", 0]];
        _box = { [_settings] call PFUNC(ui_advancedFill) } call autotest_serverCheck_withoutServer;
        call autotest_serverCheck_waitQueue;
        ["garrison with the trigger: refused with a message box", _box isNotEqualTo [], count _box] call autotest_fnc_check;
        ["garrison with the trigger: no units", count ([_bld] call autotest_serverCheck_units), 0] call autotest_fnc_checkEqual;

        _settings set ["trigger", false];
        _box = { [_settings] call PFUNC(ui_advancedFill) } call autotest_serverCheck_withoutServer;
        call autotest_serverCheck_waitQueue;
        ["garrison without the trigger: no message box", _box, []] call autotest_fnc_checkEqual;
        ["garrison without the trigger: units placed", ([_bld] call autotest_serverCheck_units) isNotEqualTo [], count ([_bld] call autotest_serverCheck_units)] call autotest_fnc_check;

        { deleteVehicle _x } forEach ([_bld] call autotest_serverCheck_units);
    }, 90]
]
