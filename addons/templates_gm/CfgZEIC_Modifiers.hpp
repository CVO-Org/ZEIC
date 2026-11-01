// Global Mobilization objects for the core fill modifiers (see docs/config-schema.md, section 10).
// Only loaded with GM (skipWhenMissingDependencies). All classes are used in the GM templates.
class CfgZEIC_Modifiers {
    class defencesOnly {
        // Subclass: extends the keep[] list of the core modifier
        class gm {
            keep[] = {
                "land_gm_sandbags_01_window_01",
                "land_gm_sandbags_01_window_02",
                "land_gm_sandbags_01_door_01",
                "land_gm_sandbags_01_door_02",
                "land_gm_sandbags_01_wall_01",
                "land_gm_sandbags_01_short_01",
                "land_gm_sandbags_01_round_01",
                "land_gm_sandbags_01_single_02"
            };
        };
    };
    class coldWar {
        class replace {
            Land_CanisterFuel_F[] = {"gm_jerrycan"};
            Land_MetalBarrel_F[] = {"gm_barrel"};
        };
    };
};
