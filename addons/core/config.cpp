#include "script_component.hpp"

class CfgPatches {
    class ADDON {

        // Meta information for editor
        name = ADDON_NAME;
        author = ECSTRING(main,author);
        authors[] = {"LSD", "shukari", "OverlordZorn [CVO]"};
        
        url = ECSTRING(main,url);

        VERSION_CONFIG;

        // Addon Specific Information
        // Minimum compatible version. When the game's version is lower, pop-up warning will appear when launching the game.
        requiredVersion = REQUIRED_VERSION;

        // Required addons, used for setting load order.
        // When any of the addons is missing, pop-up warning will appear when launching the game.
        requiredAddons[] = { "A3_Modules_F", "A3_Modules_F_Curator", "A3_3DEN", "A3_Ui_F", QUOTE(DOUBLES(PREFIX,main)) };

        // Optional. If this is 1, if any of requiredAddons[] entry is missing in your game the entire config will be ignored and return no error (but in rpt) so useful to make a compat Mod (Since Arma 3 2.14)
        skipWhenMissingDependencies = 1;
        
        // List of objects (CfgVehicles classes) contained in the addon. Important also for Zeus content (units and groups)
        units[] = {
            QPVAR(ListBuildings),
            QPVAR(GarrisonBuilding),
            QPVAR(InteriorFill),
            QPVAR(AdvancedFill),
            QPVAR(ObjectSwitch),
            QPVAR(ObjectFill),
            QPVAR(FindBPos),
            QPVAR(SaveBuildingScheme)
        };

        // List of weapons (CfgWeapons classes) contained in the addon.
        weapons[] = {};

    };
};

#include "CfgFunctions.hpp"

#include "CfgVehicles.hpp"
#include "CfgFactionClasses.hpp"
#include "CfgZEIC.hpp"
#include "CfgZEIC_ObjectFill.hpp"
#include "CfgZEIC_ObjectSwitch.hpp"
#include "Cfg3DEN.hpp"

#include "ui\defines.hpp"
#include "ui\controls.hpp"
#include "ui\Rsc_ZEIC_AdvancedFill.hpp"
#include "ui\Rsc_ZEIC_GarrisonBuilding.hpp"
#include "ui\Rsc_ZEIC_InteriorFill.hpp"
#include "ui\Rsc_ZEIC_ListBuildings.hpp"
#include "ui\Rsc_ZEIC_ObjectFill.hpp"
#include "ui\Rsc_ZEIC_ObjectSwitch.hpp"
