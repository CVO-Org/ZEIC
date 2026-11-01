// Fill modifiers of Advanced Fill (see docs/config-schema.md, section 10): change the template objects while furnishing.
// Classes match by isKindOf, so a parent class covers all its children (incl. mod variants that inherit from them).
// Applied in the order replace -> remove -> keep. Mods and missions can add modifiers or extend these.

// Modern electronics, removed by "No modern electronics" and "Cold War era"
#define MODERN_ELECTRONICS \
    "Land_Laptop_F", "Land_Laptop_unfolded_F", "Land_Laptop_02_F", "Land_Laptop_03_base_F", \
    "Item_Laptop_Unfolded", "Item_Laptop_closed", \
    "Land_Tablet_01_F", "Land_Tablet_02_F", \
    "Land_MobilePhone_smart_F", "Land_MobilePhone_old_F", "Land_SatellitePhone_F", "Land_IPPhone_01_base_F", \
    "Land_PCSet_01_screen_F", "Land_PCSet_01_case_F", "Land_PCSet_01_keyboard_F", "Land_PCSet_01_mouse_F", "Land_PCSet_01_mousepad_base_F", \
    "Land_FlatTV_01_F", "Land_Computer_01_base_F", "Land_MultiScreenComputer_01_base_F", "Land_MultiScreenComputer_01_closed_base_F", \
    "Land_TripodScreen_01_dual_v1_F", "Land_TripodScreen_01_dual_v2_F", "Land_TripodScreen_01_large_F", \
    "Land_DataTerminal_01_F", "RuggedTerminal_Base_F", "Land_PortableServer_01_base_F", "Land_PortableServer_01_cover_base_F", \
    "Land_Router_01_base_F", "Land_SatelliteAntenna_01_F", "Land_SatelliteAntenna_01_small_mounted_base_F", "OmniDirectionalAntenna_01_base_F", \
    "Land_Projector_01_F", "Land_Printer_01_F", "Land_VRGoggles_01_F", "Land_HandyCam_F", "Land_PortableSpeakers_01_F", \
    "Land_GamingSet_01_camera_F", "Land_GamingSet_01_console_F", "Land_GamingSet_01_controller_F", "Land_GamingSet_01_powerSupply_F", \
    "Land_PortableWeatherStation_01_base_F", "Land_BatteryPack_01_base_F", \
    "UAV_01_base_F", "UAV_06_base_F", "Box_C_UAV_06_Swifd_F", "Box_C_IDAP_UAV_06_medical_F", "Box_I_UAV_06_medical_F"

class CfgZEIC_Modifiers {
    class defencesOnly {
        displayName = "$STR_ZEIC_core_Modifier_DefencesOnly_DisplayName";
        tooltip = "$STR_ZEIC_core_Modifier_DefencesOnly_Tooltip";
        order = 10;
        keep[] = {
            "BagFence_base_F",              // sandbag walls
            "BagBunker_base_F",             // sandbag bunkers, pillboxes
            "HBarrier_base_F",              // H-barriers, H-barrier walls and towers
            "Land_SandbagBarricade_01_F",
            "Land_SandbagBarricade_01_half_F",
            "Land_SandbagBarricade_01_hole_F",
            "Land_BarrelSand_F",
            "Land_BarrelSand_grey_F",
            "Shelter_base_F",               // camo nets
            "Land_Razorwire_F",
            "Land_CzechHedgehog_01_F",
            "Land_CzechHedgehog_01_new_F",
            "Land_CzechHedgehog_01_old_F",
            "Land_TrenchFrame_01_F",
            "Land_Barricade_01_4m_F",
            "Land_Barricade_01_10m_F"
        };
    };
    class noElectronics {
        displayName = "$STR_ZEIC_core_Modifier_NoElectronics_DisplayName";
        tooltip = "$STR_ZEIC_core_Modifier_NoElectronics_Tooltip";
        order = 20;
        remove[] = { MODERN_ELECTRONICS };
    };
    // Replaces what the GM template addon used to do (all vanilla variant lists off): no plastic cases, no IDAP objects
    class coldWar {
        displayName = "$STR_ZEIC_core_Modifier_ColdWar_DisplayName";
        tooltip = "$STR_ZEIC_core_Modifier_ColdWar_Tooltip";
        order = 30;
        remove[] = {
            MODERN_ELECTRONICS,
            "Land_SolarPanel_1_F", "Land_SolarPanel_2_F", "Land_SolarPanel_3_F", "Land_SolarPanel_04_base_F", "Land_PortableSolarPanel_01_base_F",
            "Land_PortableLight_02_base_F",
            "Land_PortableCabinet_01_base_F", "Land_PortableDesk_01_animated_base_F",
            "Banner_01_IDAP_F", "Box_IDAP_Uniforms_F"
        };
        // The template addons of other mods put their candidates first (templates_gm)
        class replace {
            Land_PlasticCase_01_small_F[] = {"Land_MetalCase_01_small_F"};
            Land_PlasticCase_01_medium_F[] = {"Land_MetalCase_01_medium_F"};
            Land_PlasticCase_01_large_F[] = {"Land_MetalCase_01_large_F"};
            Land_PaperBox_01_small_closed_brown_IDAP_F[] = {"Land_PaperBox_01_small_closed_brown_F"};
            Land_PaperBox_01_small_closed_white_IDAP_F[] = {"Land_PaperBox_01_small_closed_brown_F"};
            Land_PaperBox_01_small_open_brown_IDAP_F[] = {"Land_PaperBox_01_small_open_brown_F"};
            Land_PaperBox_01_small_open_white_IDAP_F[] = {"Land_PaperBox_01_small_open_brown_F"};
            Land_PaperBox_01_small_destroyed_brown_IDAP_F[] = {"Land_PaperBox_01_small_destroyed_brown_F"};
            Land_PaperBox_01_small_destroyed_white_IDAP_F[] = {"Land_PaperBox_01_small_destroyed_brown_F"};
            Land_PaperBox_01_small_ransacked_white_IDAP_F[] = {"Land_PaperBox_01_small_ransacked_brown_F"};
            Land_FoodSacks_01_large_brown_idap_F[] = {"Land_FoodSacks_01_large_brown_F"};
            Land_FoodSacks_01_large_white_idap_F[] = {"Land_FoodSacks_01_large_brown_F"};
            Land_FoodSacks_01_small_brown_idap_F[] = {"Land_FoodSacks_01_small_brown_F"};
            Land_FoodSacks_01_small_white_idap_F[] = {"Land_FoodSacks_01_small_brown_F"};
            Land_FoodSacks_01_cargo_brown_idap_F[] = {"Land_FoodSacks_01_cargo_brown_F"};
            Land_FoodSack_01_full_brown_idap_F[] = {"Land_FoodSack_01_full_brown_F"};
            Land_FoodSack_01_full_white_idap_F[] = {"Land_FoodSack_01_full_brown_F"};
            Land_FoodSack_01_empty_brown_idap_F[] = {"Land_FoodSack_01_empty_brown_F"};
            Land_FoodSack_01_empty_white_idap_F[] = {"Land_FoodSack_01_empty_brown_F"};
            Land_FoodSack_01_dmg_brown_idap_F[] = {"Land_FoodSack_01_dmg_brown_F"};
            Land_FoodSack_01_dmg_white_idap_F[] = {"Land_FoodSack_01_dmg_brown_F"};
            Land_Cargo10_IDAP_F[] = {"Land_Cargo10_military_green_F"};
            Land_Cargo20_IDAP_F[] = {"Land_Cargo20_military_green_F"};
            Land_Cargo40_IDAP_F[] = {"Land_Cargo40_military_green_F"};
        };
    };
};

#undef MODERN_ELECTRONICS
