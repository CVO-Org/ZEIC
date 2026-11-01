#include "script_component.hpp"

// Interior templates for S.O.G. Prairie Fire buildings.
// Only loaded when its dependency is present (skipWhenMissingDependencies). See docs/config-schema.md.
class CfgPatches {
    class ADDON {
        name = ADDON_NAME;
        author = ECSTRING(main,author);
        authors[] = {"LSD", "shukari", "OverlordZorn [CVO]"};
        url = ECSTRING(main,url);

        VERSION_CONFIG;

        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = { "ZEIC_core", "data_f_vietnam" };
        skipWhenMissingDependencies = 1;

        units[] = {};
        weapons[] = {};
    };
};

#include "CfgZEIC.hpp"

#include "CfgZEIC_Variants.hpp"
#include "CfgZEIC_ObjectSwitch.hpp"
#include "CfgZEIC_ObjectFill.hpp"
