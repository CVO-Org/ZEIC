#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* Advanced Fill presets (#73): a round trip through save, apply and the dialog, a profile saved by another format version,
* entries of mods that aren't loaded, and a read-only preset from the mission config (description.ext >> CfgZEIC_Presets).
* Uses its own profile variable (ZEIC_presetsVariable), which it removes again: the real presets aren't touched.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["advancedFillPresets"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

#define TEST_VARIABLE "ZEIC_autotest_presets"
#define CONFIG_PRESET "ZEIC Test preset (mission)"

// Helpers for the tests (each test runs in its own script, so they are global)
// Opens the dialog on a test house with no last settings, returns it
autotest_presets_fnc_open = {
    PVAR(presetsVariable) = TEST_VARIABLE;
    PVAR(UiAdvancedFill) = nil;
    if (isNull (missionNamespace getVariable [QPVAR(UiLastBuilding), objNull])) then { PVAR(UiLastBuilding) = [DEV_HOUSE, 94] call autotest_helper_fnc_spawn };
    createDialog "Rsc_ZEIC_AdvancedFill";
    findDisplay 1706
};
autotest_presets_fnc_cleanup = {
    if (!isNull findDisplay 1706) then { (findDisplay 1706) closeDisplay 2 };
    profileNamespace setVariable [TEST_VARIABLE, nil];
    saveProfileNamespace;
    PVAR(presetsVariable) = nil;
    PVAR(UiAdvancedFill) = nil;
};
// Keys whose values differ: [key, wanted, got]. The order of the ticked categories and modifiers doesn't matter.
autotest_presets_fnc_diff = {
    params ["_want", "_got"];
    private _fnc_norm = { params ["_key", "_value"]; if (_key in ["categories", "modifiers"] && {_value isEqualType []}) then { _value = +_value; _value sort true }; _value };
    (keys _want) select { ([_x, _got get _x] call _fnc_norm) isNotEqualTo ([_x, _want get _x] call _fnc_norm) } apply { [_x, _want get _x, _got get _x] }
};

[
    ["Round trip: save, apply, dialog state", {
        params ["_ctx"];
        call autotest_presets_fnc_cleanup;
        private _dlg = call autotest_presets_fnc_open;
        ["dialog open with the preset rows", !isNull _dlg && {!isNull (_dlg getVariable ["preset_ctrl", controlNull])}] call autotest_fnc_check;
        if (isNull _dlg) exitWith { call autotest_presets_fnc_cleanup };

        private _want = createHashMapFromArray [
            ["interior", true], ["categories", ["civ", "mil"]], ["objects", OBJECT_MODE_NORMAL], ["damage", true],
            ["modifiers", ["noelectronics"]],
            ["garrison", true], ["pair", ["BLU_F", "EdSubcat_Personnel"]], ["positions", 30], ["dynamic", true], ["trigger", true],
            ["radius", 20], ["percent", 70], ["collision", false], ["blocked", COLLISION_FURNITURE_GIVES_WAY]
        ];
        [_dlg, "", _want] call (_dlg getVariable QPVAR(applyPreset));
        private _got = [_dlg] call PFUNC(ui_advancedFill_settings);
        ["applying settings sets every row", [_want, _got] call autotest_presets_fnc_diff, []] call autotest_fnc_checkEqual;

        private _saved = [_dlg, "ZEIC Test round trip"] call (_dlg getVariable QPVAR(savePreset));
        private _data = profileNamespace getVariable [TEST_VARIABLE, []];
        ["saved to the test variable, with the version", _saved && {(_data param [0, -1]) isEqualTo PRESETS_VERSION} && {count (_data param [1, []]) == 1}, _data] call autotest_fnc_check;
        private _stored = createHashMapFromArray (((_data param [1, []]) param [0, ["", []]]) select 1);
        ["stored by class name, not by list index", [_want, _stored] call autotest_presets_fnc_diff, []] call autotest_fnc_checkEqual;
        ["the saved preset is picked, Save says Overwrite",
            (_dlg getVariable ["preset", 0]) > 0 && {ctrlText (_dlg getVariable "presetSave_ctrl") == localize "STR_ZEIC_core_ModuleAdvancedFill_Preset_Overwrite"},
            [_dlg getVariable ["preset", 0], ctrlText (_dlg getVariable "presetSave_ctrl")]] call autotest_fnc_check;

        // Change everything, then pick the preset in the dropdown
        [_dlg, "", createHashMapFromArray [
            ["interior", true], ["categories", ["mil"]], ["objects", OBJECT_MODE_SIMPLE], ["damage", false], ["modifiers", []],
            ["garrison", false], ["pair", ["OPF_F", "EdSubcat_Personnel"]], ["positions", 90], ["dynamic", false], ["trigger", false],
            ["radius", 0], ["percent", 10], ["collision", true], ["blocked", COLLISION_UNITS_GIVE_WAY]
        ]] call (_dlg getVariable QPVAR(applyPreset));
        [_dlg, "preset", 0] call PFUNC(ui_dialogSetValue);
        private _index = 1 + ((_dlg getVariable [QPVAR(presets), []]) findIf { (_x select 0) == "ZEIC Test round trip" });
        [_dlg, "preset", _index] call PFUNC(ui_dialogSetValue);
        _got = [_dlg] call PFUNC(ui_advancedFill_settings);
        ["picking the preset restores the dialog", [_want, _got] call autotest_presets_fnc_diff, []] call autotest_fnc_checkEqual;
        ["the pair is picked in the list, the name field has the preset's name",
            (_dlg getVariable ["pairs", -1]) > -1 && {(_dlg getVariable ["presetName", ""]) == "ZEIC Test round trip"}
            && {ctrlEnabled (_dlg getVariable "presetDelete_ctrl")}, [_dlg getVariable ["pairs", -1], _dlg getVariable ["presetName", ""]]] call autotest_fnc_check;

        // Overwrite (the name doesn't depend on case), then delete
        [_dlg, "radius", 40] call PFUNC(ui_dialogSetValue);
        [_dlg, "zeic test ROUND trip"] call (_dlg getVariable QPVAR(savePreset));
        private _presets = (profileNamespace getVariable [TEST_VARIABLE, []]) param [1, []];
        ["overwriting keeps one preset, with the new value",
            count _presets == 1 && {(createHashMapFromArray ((_presets select 0) select 1)) getOrDefault ["radius", -1] == 40}, _presets] call autotest_fnc_check;
        private _deleted = [_dlg] call (_dlg getVariable QPVAR(deletePreset));
        ["deleted", _deleted && {((profileNamespace getVariable [TEST_VARIABLE, []]) param [1, [0]]) isEqualTo []}
            && {(_dlg getVariable ["preset", -1]) == 0}, profileNamespace getVariable [TEST_VARIABLE, []]] call autotest_fnc_check;

        // A name of only spaces isn't saved
        ["no preset name: not saved", !([_dlg, "  "] call (_dlg getVariable QPVAR(savePreset)))] call autotest_fnc_check;
        call autotest_presets_fnc_cleanup;
    }, 60],

    ["Version mismatch: not shown, not overwritten", {
        params ["_ctx"];
        call autotest_presets_fnc_cleanup;
        PVAR(presetsVariable) = TEST_VARIABLE;
        private _future = [PRESETS_VERSION + 98, [["ZEIC Test future", [["radius", 10]]]]];
        profileNamespace setVariable [TEST_VARIABLE, +_future];

        private _names = ([] call PFUNC(advancedFill_presets)) apply { _x select 0 };
        ["presets of another version aren't listed", !("ZEIC Test future" in _names) && {CONFIG_PRESET in _names}, _names] call autotest_fnc_check;
        ["saving refuses", ["ZEIC Test new", createHashMapFromArray [["radius", 5]]] call PFUNC(advancedFill_presetSave), false] call autotest_fnc_checkEqual;
        ["deleting refuses", ["ZEIC Test future"] call PFUNC(advancedFill_presetDelete), false] call autotest_fnc_checkEqual;
        ["the stored data is untouched", profileNamespace getVariable [TEST_VARIABLE, []], _future] call autotest_fnc_checkEqual;

        profileNamespace setVariable [TEST_VARIABLE, "garbage"];
        ["malformed data reads as no presets, saving replaces it",
            (["ZEIC Test new", createHashMapFromArray [["radius", 5]]] call PFUNC(advancedFill_presetSave))
            && {((profileNamespace getVariable [TEST_VARIABLE, []]) param [0, -1]) isEqualTo PRESETS_VERSION}] call autotest_fnc_check;
        call autotest_presets_fnc_cleanup;
    }],

    ["Missing faction, category or modifier: skipped, the rest loads", {
        params ["_ctx"];
        call autotest_presets_fnc_cleanup;
        private _preset = ([] call PFUNC(advancedFill_presets)) select { (_x select 0) == CONFIG_PRESET } param [0, []];
        ["the mission's config preset is listed, read-only", _preset isNotEqualTo [] && {_preset select 2}, _preset] call autotest_fnc_check;
        if (_preset isEqualTo []) exitWith { call autotest_presets_fnc_cleanup };

        private _checked = [CONFIG_PRESET, _preset select 1] call PFUNC(advancedFill_presetCheck);
        ["missing category and modifier left out, the others kept",
            (_checked get "categories") isEqualTo ["mil"] && {(_checked get "modifiers") isEqualTo ["noelectronics"]}, [_checked get "categories", _checked get "modifiers"]] call autotest_fnc_check;
        ["missing faction left out", !("pair" in _checked)] call autotest_fnc_check;
        ["the preset itself is unchanged", ((_preset select 1) get "categories") isEqualTo ["mil", "zeic_doesnotexist"]] call autotest_fnc_check;

        private _dlg = call autotest_presets_fnc_open;
        if (isNull _dlg) exitWith { call autotest_presets_fnc_cleanup };
        [_dlg, "", createHashMapFromArray [["interior", true], ["garrison", true], ["categories", ["civ"]], ["radius", 0], ["collision", true], ["positions", 70]]] call (_dlg getVariable QPVAR(applyPreset));
        private _selection = _dlg getVariable [QPVAR(selection), []];
        [_dlg, "preset", 1 + ((_dlg getVariable [QPVAR(presets), []]) findIf { (_x select 0) == CONFIG_PRESET })] call PFUNC(ui_dialogSetValue);
        ["the rest of the preset is applied",
            (_dlg getVariable "categories") isEqualTo ["mil"] && {_dlg getVariable "modifier_noelectronics"} && {(_dlg getVariable "radius") == 35}
            && {!(_dlg getVariable "collision")} && {!(_dlg getVariable "garrison")} && {_dlg getVariable "interior"},
            [_dlg getVariable "categories", _dlg getVariable "radius", _dlg getVariable "collision", _dlg getVariable "garrison"]] call autotest_fnc_check;
        ["settings the preset doesn't have stay as they were",
            (_dlg getVariable "positions") == 70 && {(_dlg getVariable [QPVAR(selection), []]) isEqualTo _selection}, [_dlg getVariable "positions", _dlg getVariable [QPVAR(selection), []]]] call autotest_fnc_check;
        call autotest_presets_fnc_cleanup;
    }, 60],

    ["A config preset can't be deleted or overwritten", {
        params ["_ctx"];
        call autotest_presets_fnc_cleanup;
        PVAR(presetsVariable) = TEST_VARIABLE;
        ["delete refuses", [CONFIG_PRESET] call PFUNC(advancedFill_presetDelete), false] call autotest_fnc_checkEqual;
        ["saving under its name refuses", [CONFIG_PRESET, createHashMapFromArray [["radius", 5]]] call PFUNC(advancedFill_presetSave), false] call autotest_fnc_checkEqual;
        ["still listed, nothing saved to the profile",
            (([] call PFUNC(advancedFill_presets)) findIf { (_x select 0) == CONFIG_PRESET }) != -1 && {isNil { profileNamespace getVariable TEST_VARIABLE }}] call autotest_fnc_check;

        private _dlg = call autotest_presets_fnc_open;
        if (isNull _dlg) exitWith { call autotest_presets_fnc_cleanup };
        [_dlg, "preset", 1 + ((_dlg getVariable [QPVAR(presets), []]) findIf { (_x select 0) == CONFIG_PRESET })] call PFUNC(ui_dialogSetValue);
        ["Delete is off for it", !ctrlEnabled (_dlg getVariable "presetDelete_ctrl")] call autotest_fnc_check;
        ["the dialog's delete does nothing", [_dlg] call (_dlg getVariable QPVAR(deletePreset)), false] call autotest_fnc_checkEqual;
        [_dlg, "presetName", CONFIG_PRESET] call PFUNC(ui_dialogSetValue);
        _dlg call (_dlg getVariable QPVAR(updateSaveButton));
        ["Save is off for its name", !ctrlEnabled (_dlg getVariable "presetSave_ctrl")] call autotest_fnc_check;
        call autotest_presets_fnc_cleanup;
    }]
]
