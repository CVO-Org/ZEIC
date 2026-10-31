// Test mission in Kavala (dense town) for large-radius Interior Fill / Garrison tests.
// zeic_selftest.sqf and description.ext are copies of the ones in test.VR; the self test finds a
// dry, empty area of its own (logged in the start line of the RPT).

// mission.sqm can't know the terrain height: put the player on the ground on scenario start.
if (hasInterface) then {
    private _pos = [3560, 13050, 0] findEmptyPosition [0, 50, typeOf player];
    if (_pos isNotEqualTo []) then { player setPosATL _pos };
};

// Runs the ZEIC self test on every scenario start (preview / singleplayer).
// Results are written to the RPT, one line per check, prefixed with [ZEIC TEST].
if (isServer && hasInterface) then {
    [] execVM "zeic_selftest.sqf";
};
