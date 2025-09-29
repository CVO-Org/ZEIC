#include "../../script_component.hpp"

params [["_obj", objNull, [objNull, ""]]];

if (_obj isEqualTo "" || {_obj isEqualTo objNull}) exitWith {false};
if (_obj isEqualType objNull) then {_obj = typeOf _obj};

1 == {
	(_x select [0, 3]) == "A3_"
}
count (configSourceAddonList (configFile >> "CfgVehicles" >> _obj));
