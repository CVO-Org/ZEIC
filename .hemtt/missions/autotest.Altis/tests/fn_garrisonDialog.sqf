#include "\zrn\ZEIC\addons\core\script_component.hpp"

/*
* Author: Zorn
* the Garrison Building dialog (faction filters, subcategory, recently used).
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["garrisonDialog"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["The Garrison Building dialog", {
        params ["_ctx"];

        // T15 Garrison dialog (#9)
        private _bld = [DEV_HOUSE, 41] call autotest_helper_fnc_spawn;
        PVAR(UiLastBuilding) = _bld;
        PVAR(UiGarrisonFaction) = nil;
        PVAR(UiGarrisonPositions) = 10;
        PVAR(UiGarrisonRadius) = 0;
        uiNamespace setVariable [QPVAR(garrisonRecent), nil];

        private _factions = call PFUNC(garrisonBuilding_factions);
        ["factions found, NATO among them", _factions findIf { (_x select 1) == "BLU_F" } != -1, count _factions] call autotest_fnc_check;

        createDialog "Rsc_ZEIC_GarrisonBuilding";
        private _dlg = findDisplay 1702;
        ["dialog opens", !isNull _dlg] call autotest_fnc_check;
        if (isNull _dlg) exitWith {};

        private _list = _dlg getVariable ["pairs_ctrl", controlNull];
        private _pairCount = 0;
        { _pairCount = _pairCount + count (_x select 4) } forEach _factions;
        ["one row per faction and subcategory, no recently used list", ((lnbSize _list) select 0) == _pairCount && {isNull (_dlg getVariable ["recent_ctrl", controlNull])}, [(lnbSize _list) select 0, _pairCount]] call autotest_fnc_check;
        ["side icons exist", SIDE_ICONS findIf { !fileExists _x } == -1, SIDE_ICONS select { !fileExists _x }] call autotest_fnc_check;
        private _nato = _factions select (_factions findIf { (_x select 1) == "BLU_F" });
        ["factions use their rectangular flag (NATO)", (_nato select 5) != (_nato select 3) && {fileExists (_nato select 5)}, _nato select 5] call autotest_fnc_check;
        ["a faction and subcategory are preselected", count (_dlg getVariable [QPVAR(selection), []]) == 2, _dlg getVariable [QPVAR(selection), []]] call autotest_fnc_check;

        // Estimate: radius 0, one building with 10% of its positions (#57)
        private _estimate = ctrlText (_dlg getVariable ["estimate_ctrl", controlNull]);
        private _estimateUnits = 1 max round ((count (_bld buildingPos -1)) / 10);
        ["estimate shows the one building", _estimate == format [LLSTRING(ModuleGarrisonBuilding_EstimateSingle), _estimateUnits], _estimate] call autotest_fnc_check;
        private _positionsSlider = _dlg getVariable ["positions_ctrl", controlNull];
        [_positionsSlider, 100] call (_positionsSlider getVariable QPVAR(store));
        _estimate = ctrlText (_dlg getVariable ["estimate_ctrl", controlNull]);
        ["estimate follows the Positions slider", _estimate == format [LLSTRING(ModuleGarrisonBuilding_EstimateSingle), count (_bld buildingPos -1)], _estimate] call autotest_fnc_check;
        [_positionsSlider, 10] call (_positionsSlider getVariable QPVAR(store));

        // Listed rows as [faction, subcategory], and the shown texts of a row
        private _fnc_listed = { private _out = []; for "_i" from 0 to (((lnbSize _list) select 0) - 1) do { _out pushBack ((_list lnbData [_i, 0]) splitString "#") }; _out };
        private _fnc_rowText = { params ["_row"]; toLowerANSI ((_list lnbText [_row, 2]) + " " + (_list lnbText [_row, 3])) };
        private _fnc_info = { params ["_class"]; _factions select (_factions findIf { (_x select 1) == _class }) };
        private _fnc_fill = { _dlg call (_dlg getVariable QPVAR(fillPairs)) };

        // Search matches the faction name or class, case-insensitive
        _dlg setVariable ["search", "blu_f"];
        call _fnc_fill;
        private _listed = call _fnc_listed;
        private _unmatched = _listed select { (toLowerANSI (_x select 0) find "blu_f") == -1 && {(toLowerANSI (([_x select 0] call _fnc_info) select 0) find "blu_f") == -1} };
        ["search filters by name or class", ["BLU_F", "EdSubcat_Personnel"] in _listed && {_unmatched isEqualTo []}, [count _listed, _unmatched]] call autotest_fnc_check;

        // Several words: every row matches all of them (faction and subcategory)
        _dlg setVariable ["search", "nato special"];
        call _fnc_fill;
        private _rows = (lnbSize _list) select 0;
        private _wrongRows = [];
        for "_i" from 0 to (_rows - 1) do { private _text = [_i] call _fnc_rowText; if ((_text find "nato") == -1 || {(_text find "special") == -1}) then { _wrongRows pushBack _text } };
        ["search with several words: faction and subcategory", _rows > 0 && {_wrongRows isEqualTo []}, [_rows, _wrongRows]] call autotest_fnc_check;

        // Side keyword in the search: only OPFOR
        _dlg setVariable ["search", "opfor"];
        call _fnc_fill;
        _listed = call _fnc_listed;
        private _wrongSide = _listed select { (([_x select 0] call _fnc_info) select 2) != 0 };
        ["search by side keyword", _listed isNotEqualTo [] && {_wrongSide isEqualTo []}, _wrongSide] call autotest_fnc_check;

        // Side filter: OPFOR (toolbox index 2) shows only side 0
        _dlg setVariable ["search", ""];
        _dlg setVariable ["side", 2];
        call _fnc_fill;
        _listed = call _fnc_listed;
        _wrongSide = _listed select { (([_x select 0] call _fnc_info) select 2) != 0 };
        ["side filter shows only OPFOR", _listed isNotEqualTo [] && {_wrongSide isEqualTo []} && {_listed findIf { (_x select 0) == "BLU_F" } == -1}, _wrongSide] call autotest_fnc_check;
        ["filtered-out pair is no longer picked", (_dlg getVariable [QPVAR(selection), []]) isEqualTo [] || {(_dlg getVariable QPVAR(selection)) in _listed}] call autotest_fnc_check;

        // Pick NATO Men: one click picks the pair
        _dlg setVariable ["side", 0];
        call _fnc_fill;
        _list lnbSetCurSelRow ((call _fnc_listed) find ["BLU_F", "EdSubcat_Personnel"]);
        ["one click picks NATO Men", (_dlg getVariable [QPVAR(selection), []]) isEqualTo ["BLU_F", "EdSubcat_Personnel"], _dlg getVariable [QPVAR(selection), []]] call autotest_fnc_check;

        // Nothing picked: confirm keeps the dialog open
        private _keep = _dlg getVariable QPVAR(selection);
        _dlg setVariable [QPVAR(selection), []];
        [_dlg] call PFUNC(ui_dialogConfirm);
        ["confirm without a faction keeps the dialog open", !isNull findDisplay 1702] call autotest_fnc_check;
        _dlg setVariable [QPVAR(selection), _keep];

        [_dlg] call PFUNC(ui_dialogConfirm);
        private _closeTimeout = diag_tickTime + 1;
        waitUntil { isNull findDisplay 1702 || {diag_tickTime > _closeTimeout} };
        ["confirm closes the dialog and starts the garrison", isNull findDisplay 1702 && {_bld getVariable [QPVAR(garrisoned), false]},
            [isNull findDisplay 1702, _bld getVariable [QPVAR(garrisoned), false], _dlg getVariable [QPVAR(confirmed), "-"], _dlg getVariable ["units", "-"]]] call autotest_fnc_check;
        if (!isNull findDisplay 1702) then { (findDisplay 1702) closeDisplay 2; sleep 0.1 };
        ["pair added to recently used", (uiNamespace getVariable [QPVAR(garrisonRecent), []]) isEqualTo [["BLU_F", "EdSubcat_Personnel"]]] call autotest_fnc_check;

        private _timeout = diag_tickTime + 30;
        waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _timeout} };

        // Reopened: the recently used pair is shown and preselected
        createDialog "Rsc_ZEIC_GarrisonBuilding";
        _dlg = findDisplay 1702;
        private _recentList = _dlg getVariable ["recent_ctrl", controlNull];
        ["recently used list preselects the last pair", ((lnbSize _recentList) select 0) == 1 && {lnbCurSelRow _recentList == 0} && {(_dlg getVariable [QPVAR(selection), []]) isEqualTo ["BLU_F", "EdSubcat_Personnel"]}, [lnbSize _recentList, lnbCurSelRow _recentList]] call autotest_fnc_check;
        ["recently used clears the pair list selection", lnbCurSelRow (_dlg getVariable "pairs_ctrl") == -1] call autotest_fnc_check;
        ["recently used row looks like the pair list (same columns)", (_recentList lnbData [0, 0]) == "BLU_F#EdSubcat_Personnel" && {(toLowerANSI (SIDE_ICONS select 1)) find (toLowerANSI (_recentList lnbPicture [0, 0])) != -1}, [_recentList lnbData [0, 0], _recentList lnbPicture [0, 0]]] call autotest_fnc_check;

        // Typing a search keeps the pair picked in the recently used list
        _dlg setVariable ["search", "csat"];
        _dlg call (_dlg getVariable QPVAR(fillPairs));
        ["search keeps the recently used pick", (_dlg getVariable [QPVAR(selection), []]) isEqualTo ["BLU_F", "EdSubcat_Personnel"] && {lnbCurSelRow _recentList == 0}] call autotest_fnc_check;
        _dlg closeDisplay 2;
    }, 180]
]
