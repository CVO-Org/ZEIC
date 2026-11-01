#include "..\..\script_component.hpp"

/*
* The Object Switch sets (CfgZEIC_ObjectSwitch >> Sets) of the loaded addons, sorted by their "order".
*
* Arguments:
* None
*
* Return Value:
* Sets [[display name, class], ...] <ARRAY>
*
* Public: No
*/

private _sets = ("true" configClasses (configFile >> "CfgZEIC_ObjectSwitch" >> "Sets")) apply {
	[getNumber (_x >> "order"), getText (_x >> "displayName"), configName _x]
};
_sets sort true;
_sets apply { [_x select 1, _x select 2] }
