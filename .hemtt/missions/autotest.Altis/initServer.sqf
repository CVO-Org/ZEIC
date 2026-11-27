// ZEIC only (init.sqf and init3DEN.sqf come from the template).
// ZEIC's autotest runs on Altis, not VR: real terrain, as the old self test did (some checks, e.g. the collision
// check with a unit on a box, behave differently on VR).

// mission.sqm (a copy of test.Altis's) can't know the terrain height: put the player on the ground in Kavala.
// Singleplayer preview, so the server has the player.
if ( hasInterface ) then {
    private _pos = [3560, 13050, 0] findEmptyPosition [0, 50, typeOf player];
    if ( _pos isNotEqualTo [] ) then { player setPosATL _pos };
};

// The test area the suites spawn their buildings in: 1.2 x 1 km from this corner (autotest_helper_fnc_spawn).
// The buildings are left in place for inspection.
ZEIC_dev_origin = switch ( toLowerANSI worldName ) do {
    case "altis": { [23500, 18200, 0] };    // Almyra, by the salt lake
    case "vr":    { [1000, 1000, 0] };
    default       { [] };
};

if ( ZEIC_dev_origin isEqualTo [] ) then {
    diag_log text format ["[ AUTOTEST ]     no test area on %1 - see initServer.sqf", worldName];
};
