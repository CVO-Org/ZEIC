// S.O.G. Prairie Fire objects for Object Fill (see docs/config-schema.md, section 12).
// Only loaded with S.O.G. Prairie Fire (skipWhenMissingDependencies). All classes are used in the SOG templates.
class CfgZEIC_ObjectFill {
    class Types {
        class electronicsOld {
            // Subclass: adds to the objects of the core type
            class sog {
                objects[] = {
                    "vn_b_prop_prc77_01",
                    "vn_o_prop_r311_01",
                    "vn_o_prop_radio_m252b_01",
                    "vn_o_prop_t102e_01",
                    "vn_o_prop_t884_01",
                    "Land_vn_mutt_vysilacka"
                };
            };
        };
    };
};
