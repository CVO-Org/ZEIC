// Test mission in Kavala (dense town) for large-radius Interior Fill / Garrison tests.
// The automated tests run in autotest.Altis (hemtt launch default autotest); description.ext is a copy of test.VR's.

// mission.sqm can't know the terrain height: put the player on the ground on scenario start.
if (hasInterface) then {
    private _pos = [3560, 13050, 0] findEmptyPosition [0, 50, typeOf player];
    if (_pos isNotEqualTo []) then { player setPosATL _pos };
};
