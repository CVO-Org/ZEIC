#include "..\..\script_component.hpp"

/*
* Adds the preset rows to the top of the Advanced Fill dialog (see PFUNC(advancedFill_presets)):
* - Preset: picking one applies it to the dialog. Delete removes the picked profile preset (a second click confirms);
*   read-only presets from config can't be deleted.
* - Save as: a name and Save, which saves the dialog's settings under it (Overwrite: a profile preset of that name exists).
* Entries from mods that aren't loaded are left out with a note (see PFUNC(advancedFill_presetCheck)).
*
* Code on the display (also used by the tests):
* QPVAR(applyPreset) [display, name, settings], QPVAR(savePreset) [display, name] -> saved <BOOL>,
* QPVAR(deletePreset) [display] -> deleted <BOOL>, QPVAR(fillPresets) [display, name to pick ("" none)].
*
* Arguments:
* 0: Dialog context <HASHMAP>
*
* Return Value:
* None
*
* Public: No
*/

params ["_ctx"];

private _display = _ctx get "display";
#define BUTTON_W UI_W(3)

// ---- Preset: dropdown and Delete
private _combo = [_ctx, "preset", LLSTRING(ModuleAdvancedFill_Preset), [], 0, LLSTRING(ModuleAdvancedFill_Preset_Tooltip), {
	params ["_display", "_index"];
	_display setVariable [QPVAR(deleteArmed), false];
	private _preset = (_display getVariable [QPVAR(presets), []]) param [_index - 1, []];
	private _delete = _display getVariable "presetDelete_ctrl";
	_delete ctrlSetText LLSTRING(ModuleAdvancedFill_Preset_Delete);
	if (_preset isEqualTo []) exitWith { _delete ctrlEnable false };
	_preset params ["_name", "_settings", "_readOnly"];
	_delete ctrlEnable !_readOnly;
	if (_display getVariable [QPVAR(busy), false]) exitWith {};
	[_display, _name, _settings] call (_display getVariable QPVAR(applyPreset));
	if (!_readOnly) then { [_display, "presetName", _name] call PFUNC(ui_dialogSetValue) };
	_display call (_display getVariable QPVAR(updateSaveButton));
}] call PFUNC(ui_dialogCombo);
(_combo getVariable QPVAR(relPos)) params ["_cx", "_cy", "_cw", "_ch"];
_combo setVariable [QPVAR(relPos), [_cx, _cy, _cw - BUTTON_W - UI_W(0.1), _ch]];

private _delete = [_ctx, QPVAR(ctrlTab), [_cx + _cw - BUTTON_W, _cy, BUTTON_W, _ch]] call PFUNC(ui_dialogAdd);
_delete ctrlSetText LLSTRING(ModuleAdvancedFill_Preset_Delete);
_delete ctrlSetTooltip LLSTRING(ModuleAdvancedFill_Preset_Delete_Tooltip);
_delete ctrlEnable false;
_delete ctrlAddEventHandler ["ButtonClick", {
	params ["_button"];
	private _display = ctrlParent _button;
	// The first click asks, the second deletes
	if !(_display getVariable [QPVAR(deleteArmed), false]) exitWith {
		_display setVariable [QPVAR(deleteArmed), true];
		_button ctrlSetText LLSTRING(ModuleAdvancedFill_Preset_DeleteConfirm);
	};
	[_display] call (_display getVariable QPVAR(deletePreset));
}];
_display setVariable ["presetDelete_ctrl", _delete];

// ---- Save as: name and Save
private _edit = [_ctx, "presetName", LLSTRING(ModuleAdvancedFill_Preset_Name), "", LLSTRING(ModuleAdvancedFill_Preset_Name_Tooltip), {
	params ["_display"];
	_display call (_display getVariable QPVAR(updateSaveButton));
}] call PFUNC(ui_dialogEdit);
// Enter in the name field saves, it doesn't start the fill
_edit setVariable [QPVAR(onEnter), {
	params ["_display"];
	[_display, ctrlText (_display getVariable "presetName_ctrl")] call (_display getVariable QPVAR(savePreset));
}];
(_edit getVariable QPVAR(relPos)) params ["_ex", "_ey", "_ew", "_eh"];
_edit setVariable [QPVAR(relPos), [_ex, _ey, _ew - BUTTON_W - UI_W(0.1), _eh]];

private _save = [_ctx, QPVAR(ctrlTab), [_cx + _cw - BUTTON_W, _ey - pixelH, BUTTON_W, _eh + pixelH]] call PFUNC(ui_dialogAdd);
_save ctrlSetText LLSTRING(ModuleAdvancedFill_Preset_Save);
_save ctrlSetTooltip LLSTRING(ModuleAdvancedFill_Preset_Save_Tooltip);
_save ctrlAddEventHandler ["ButtonClick", {
	params ["_button"];
	private _display = ctrlParent _button;
	[_display, _display getVariable ["presetName", ""]] call (_display getVariable QPVAR(savePreset));
}];
_display setVariable ["presetSave_ctrl", _save];

// "Overwrite" while the name is a profile preset's, disabled while it is empty or a read-only preset's
_display setVariable [QPVAR(updateSaveButton), {
	params ["_display"];
	private _name = trim (_display getVariable ["presetName", ""]);
	private _preset = (_display getVariable [QPVAR(presets), []]) select { (_x select 0) == _name } param [0, []];
	private _save = _display getVariable "presetSave_ctrl";
	_save ctrlSetText ([LLSTRING(ModuleAdvancedFill_Preset_Save), LLSTRING(ModuleAdvancedFill_Preset_Overwrite)] select (_preset isNotEqualTo []));
	_save ctrlEnable (_name != "" && {!(_preset param [2, false])});
}];

// Fills the dropdown, picks a preset by name without applying it
_display setVariable [QPVAR(fillPresets), {
	params ["_display", ["_pick", ""]];
	private _presets = call PFUNC(advancedFill_presets);
	_display setVariable [QPVAR(presets), _presets];
	private _combo = _display getVariable "preset_ctrl";
	_display setVariable [QPVAR(busy), true];
	lbClear _combo;
	_combo lbAdd LLSTRING(ModuleAdvancedFill_Preset_None);
	{
		_x params ["_name", "", "_readOnly"];
		private _index = _combo lbAdd ([_name, format [LLSTRING(ModuleAdvancedFill_Preset_ReadOnlyName), _name]] select _readOnly);
		_combo lbSetTooltip [_index, [_name, LLSTRING(ModuleAdvancedFill_Preset_ReadOnly_Tooltip)] select _readOnly];
	} forEach _presets;
	[_display, "preset", 1 + (_presets findIf { !(_x select 2) && {(_x select 0) == _pick} })] call PFUNC(ui_dialogSetValue);
	_display setVariable [QPVAR(busy), false];
	_display call (_display getVariable QPVAR(updateSaveButton));
}];

// Applies a preset's settings, the ones it doesn't have stay as they are
_display setVariable [QPVAR(applyPreset), {
	params ["_display", "_name", "_settings"];
	_settings = [_name, _settings] call PFUNC(advancedFill_presetCheck);

	{
		if (_x in _settings && {(_settings get _x) isEqualType true}) then { _display setVariable [_x, _settings get _x] };
	} forEach ["interior", "garrison"];
	if (!(_display getVariable "interior") && {!(_display getVariable "garrison")}) then { _display setVariable ["interior", true] };

	// A preset whose categories all are missing keeps the ticked ones
	if ((_settings getOrDefault ["categories", []]) isNotEqualTo []) then {
		[_display, "categories", _settings get "categories"] call PFUNC(ui_dialogSetValue);
	};
	if ("modifiers" in _settings) then {
		private _modifiers = _settings get "modifiers";
		{
			[_display, format ["modifier_%1", _x select 1], (_x select 1) in _modifiers] call PFUNC(ui_dialogSetValue);
		} forEach (call PFUNC(fillModifiers_list));
	};
	{
		if (_x in _settings) then { [_display, _x, _settings get _x] call PFUNC(ui_dialogSetValue) };
	} forEach ["objects", "damage", "positions", "dynamic", "trigger", "radius", "percent", "collision", "blocked"];

	// The pair: shown in the full list (no search, all sides) and picked there
	if ("pair" in _settings) then {
		private _pair = (_settings get "pair") joinString "#";
		[_display, "search", ""] call PFUNC(ui_dialogSetValue);
		[_display, "side", 0] call PFUNC(ui_dialogSetValue);
		_display call (_display getVariable QPVAR(fillPairs));
		private _list = _display getVariable "pairs_ctrl";
		for "_row" from 0 to ((lnbSize _list) select 0) - 1 do {
			if ((_list lnbData [_row, 0]) == _pair) exitWith { _list lnbSetCurSelRow _row };
		};
	};

	_display call (_display getVariable QPVAR(updateTabs));
}];

_display setVariable [QPVAR(savePreset), {
	params ["_display", "_name"];
	_name = trim _name;
	private _saved = [_name, [_display] call PFUNC(ui_advancedFill_settings)] call PFUNC(advancedFill_presetSave);
	if (_saved) then {
		[format [LLSTRING(ModuleAdvancedFill_Preset_Saved), _name], "INFO"] call PFUNC(misc_logMsg);
		[_display, _name] call (_display getVariable QPVAR(fillPresets));
		[_display, "presetName", _name] call PFUNC(ui_dialogSetValue);
		_display call (_display getVariable QPVAR(updateSaveButton));
	};
	_saved
}];

_display setVariable [QPVAR(deletePreset), {
	params ["_display"];
	_display setVariable [QPVAR(deleteArmed), false];
	private _preset = (_display getVariable [QPVAR(presets), []]) param [(_display getVariable ["preset", 0]) - 1, []];
	if (_preset isEqualTo []) exitWith { false };
	private _deleted = [_preset select 0] call PFUNC(advancedFill_presetDelete);
	if (_deleted) then {
		[format [LLSTRING(ModuleAdvancedFill_Preset_Deleted), _preset select 0], "INFO"] call PFUNC(misc_logMsg);
	};
	[_display] call (_display getVariable QPVAR(fillPresets));
	_deleted
}];

[_display] call (_display getVariable QPVAR(fillPresets));
