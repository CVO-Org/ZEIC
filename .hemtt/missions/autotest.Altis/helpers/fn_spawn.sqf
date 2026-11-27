/*
* Author: Zorn
* Spawns a building on one of the spots of the test area: 8 per row, 150 m apart, from ZEIC_dev_origin (initServer.sqf).
*
* Arguments:
* 0: Class <STRING>
* 1: Spot <NUMBER>
*
* Return Value:
* Building <OBJECT>
*
* Example:
* ["Land_i_House_Small_03_V1_F", 20] call autotest_helper_fnc_spawn;
*
* Public: No
*/

params [ ["_class", "", [""]], ["_index", 0, [0]] ];

createVehicle [
    _class,
    ZEIC_dev_origin vectorAdd [150 * (_index mod 8), 150 * floor (_index / 8), 0],
    [],
    0,
    "CAN_COLLIDE"
]
