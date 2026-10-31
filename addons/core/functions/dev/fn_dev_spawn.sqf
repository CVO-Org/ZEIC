#include "..\..\script_component.hpp"

/*
* Self test: spawns a building on one of the spots of the test area (8 per row, 150 m apart).
*
* Arguments:
* 0: Class <STRING>
* 1: Spot <NUMBER>
*
* Return Value:
* Building <OBJECT>
*
* Public: No
*/

params ["_class", "_index"];

createVehicle [_class, PVAR(dev_origin) vectorAdd [150 * (_index mod 8), 150 * floor (_index / 8), 0], [], 0, "CAN_COLLIDE"]
