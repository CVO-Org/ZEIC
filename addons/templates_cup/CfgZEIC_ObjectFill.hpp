// CUP Terrains objects for Object Fill (see docs/config-schema.md, section 12).
// Only loaded with CUP Terrains (skipWhenMissingDependencies).
class CfgZEIC_ObjectFill {
    class Types {
        class electronicsOld {
            // Subclass: adds to the objects of the core type
            class cup {
                objects[] = {
                    "Radio",
                    "CUP_A2_radio_b",
                    "SmallTV",
                    "Microphone1_ep1"
                };
            };
        };
    };
};
