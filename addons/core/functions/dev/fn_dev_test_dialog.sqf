#include "..\..\script_component.hpp"

/*
* Self test: The Interior Fill dialog.
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

private _houseClass = DEV_HOUSE;

// T14 Interior Fill dialog (#6, #25)
private _dlgHouse = [_houseClass, 40] call PFUNC(dev_spawn);
ZEIC_UiLastBuilding = _dlgHouse;
ZEIC_UiLastPosition = getPos _dlgHouse;
ZEIC_UiInteriorType = 1;
ZEIC_UiInteriorRadius = 0;
createDialog "Rsc_ZEIC_InteriorFill";
private _dlg = findDisplay 1705;
["T14.1 dialog opens", !isNull _dlg] call PFUNC(dev_check);
if (!isNull _dlg) then {
	private _combo = _dlg getVariable ["category_ctrl", controlNull];
	["T14.2 one dropdown entry per category", lbSize _combo == count (call PFUNC(interiorFill_categories)), lbSize _combo] call PFUNC(dev_check);
	["T14.3 last used category preselected", (_dlg getVariable ["category", -1]) == 1 && {lbCurSel _combo == 1}, [_dlg getVariable ["category", -1], lbCurSel _combo]] call PFUNC(dev_check);
	["T14.4 object modes and damage shown outside Eden", !isNull (_dlg getVariable ["objects_ctrl", controlNull]) && {!isNull (_dlg getVariable ["damage_ctrl", controlNull])}] call PFUNC(dev_check);

	_combo lbSetCurSel 0;
	["T14.5 picking a category stores it", (_dlg getVariable ["category", -1]) == 0] call PFUNC(dev_check);

	private _slider = _dlg getVariable ["radius_ctrl", controlNull];
	["T14.10 radius preview drawn around the module position", (_slider getVariable [QPVAR(previewEH), -1]) >= 0] call PFUNC(dev_check);
	["T14.9 radius slider with its number field", !isNull _slider && {sliderPosition _slider == 0}, sliderRange _slider] call PFUNC(dev_check);

	[_dlg] call PFUNC(ui_dialogConfirm);
	// The display may only be gone a frame later
	private _closeTimeout = diag_tickTime + 1;
	waitUntil { isNull findDisplay 1705 || {diag_tickTime > _closeTimeout} };
	["T14.6 confirm closes the dialog", isNull findDisplay 1705, diag_tickTime - _closeTimeout + 1] call PFUNC(dev_check);
	["T14.7 confirm starts the fill", _dlgHouse getVariable ["ZEIC_queued", false] || {!isNull (_dlgHouse getVariable ["ZEIC_furnished", objNull])}] call PFUNC(dev_check);
	["T14.8 choice remembered", ZEIC_UiInteriorType == 0] call PFUNC(dev_check);

	private _dlgTimeout = diag_tickTime + 30;
	waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _dlgTimeout} };
};

// Chance: a share of the buildings within the radius
private _chanceCenter = PVAR(dev_origin) vectorAdd [300, 1100, 0];
private _chanceHouses = [];
for "_i" from 0 to 3 do { _chanceHouses pushBack (createVehicle [DEV_HOUSE, _chanceCenter vectorAdd [_i * 25, 0, 0], [], 0, "CAN_COLLIDE"]) };
PVAR(UiLastBuilding) = _chanceHouses select 0;
PVAR(UiLastPosition) = _chanceCenter vectorAdd [37.5, 0, 0];
isNil { [0, 60, OBJECT_MODE_SIMPLE, false, 50] call PFUNC(ui_interiorFill) };
private _chanceQueued = { _x getVariable ["ZEIC_queued", false] || {!isNull (_x getVariable ["ZEIC_furnished", objNull])} } count _chanceHouses;
["T14.11 chance 50% fills 2 of 4 buildings", _chanceQueued == 2, _chanceQueued] call PFUNC(dev_check);
["T14.12 chance remembered for Alt and shortcuts", PVAR(UiInteriorChance) == 50] call PFUNC(dev_check);
PVAR(UiInteriorChance) = 100;
private _chanceTimeout = diag_tickTime + 30;
waitUntil { sleep 0.05; (missionNamespace getVariable ["ZEIC_queue", []]) isEqualTo [] || {diag_tickTime > _chanceTimeout} };
