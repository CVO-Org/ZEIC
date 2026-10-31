// Runs the ZEIC self test on every scenario start (preview / singleplayer).
// Results are written to the RPT, one line per check, prefixed with [ZEIC TEST].
if (isServer && hasInterface) then {
    [] execVM "zeic_selftest.sqf";
};
