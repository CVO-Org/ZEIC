// Global Mobilization objects for Object Fill (see docs/config-schema.md, section 12).
// Only loaded with GM (skipWhenMissingDependencies). All classes are used in the GM templates.
class CfgZEIC_ObjectFill {
    class Types {
        class electronicsOld {
            // Subclass: adds to the objects of the core type
            class gm {
                objects[] = {
                    "land_gm_euro_furniture_radio_01",
                    "land_gm_euro_furniture_telephone_01",
                    "land_gm_euro_furniture_typewriter_01"
                };
            };
        };
    };
};
