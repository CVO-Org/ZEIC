#include "..\..\script_component.hpp"

/*
* Asks before a garrison creates more than GARRISON_CONFIRM_UNITS units (Garrison Building, Advanced Fill).
* Counts the units of the picked buildings like the garrison will (see PFUNC(garrisonBuilding_unitCounts));
* above the limit it opens a prompt instead (next frame, the dialog that asked is still closing):
* "Yes" runs the code with the same buildings, "Back" (or Escape) reopens the module's dialog with the last settings.
*
* Arguments:
* 0: Buildings <ARRAY of OBJECTs>
* 1: Share of each building's positions to fill in percent <NUMBER>
* 2: Module name, the prompt's title <STRING>
* 3: Code run on "Yes", gets the arguments as _this <CODE>
* 4: Arguments for the code <ANY>
* 5: Dialog reopened on "Back" <STRING>
*
* Return Value:
* Prompt opened, the caller stops here <BOOL>
*
* Public: No
*/

params [["_buildings", [], [[]]], ["_percent", 50, [0]], ["_title", "", [""]], ["_onYes", {}, [{}]], ["_args", []], ["_dialog", "", [""]]];

private _withPositions = _buildings select { !isNull _x && {(_x buildingPos -1) isNotEqualTo []} };
private _units = 0;
{ _units = _units + _x } forEach ([_withPositions apply { count (_x buildingPos -1) }, _percent] call PFUNC(garrisonBuilding_unitCounts));
if (_units <= GARRISON_CONFIRM_UNITS) exitWith { false };

uiNamespace setVariable [QPVAR(confirmUnits), [_title, _units, count _withPositions, _onYes, _args, _dialog]];
[] spawn { ["Rsc_ZEIC_ConfirmUnits"] call PFUNC(ui_openDialog) };
true
