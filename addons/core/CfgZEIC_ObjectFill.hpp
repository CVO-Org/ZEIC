// Object Fill (see docs/config-schema.md, section 12): prop types, and the shelves of objects that can be filled.
// Any mod can add types or surfaces, or objects to a type in a subclass of it.

class CfgZEIC_ObjectFill {
    // Props per type. "Random" in the dialog uses the props of all types. The floor object goes under tables.
    class Types {
        class food {
            displayName = "$STR_ZEIC_core_ModuleObjectFill_Type_Food";
            order = 10;
            floor = "Land_Garbage_square3_F";
            objects[] = {
                "Land_Orange_01_F",
                "Land_WaterBottle_01_empty_F",
                "Land_WaterBottle_01_full_F",
                "Land_BottlePlastic_V1_F",
                "Land_Can_Rusty_F",
                "Land_Can_V1_F",
                "Land_Can_V2_F",
                "Land_Can_V3_F",
                "Land_TacticalBacon_F",
                "Land_Can_Dented_F",
                "Land_BottlePlastic_V2_F",
                "Land_BakedBeans_F",
                "Land_PowderedMilk_F",
                "Land_RiceBox_F",
                "Land_Tableware_01_stackOfNapkins_F",
                "Land_Tableware_01_cup_F",
                "Land_TinContainer_F"
            };
        };
        class medical {
            displayName = "$STR_ZEIC_core_ModuleObjectFill_Type_Medical";
            order = 20;
            floor = "BloodSplatter_01_Large_New_F";
            objects[] = {
                "Item_FirstAidKit",
                "Land_Bandage_F",
                "MedicalGarbage_01_Bandage_F",
                "MedicalGarbage_01_Packaging_F",
                "Land_Bandage_F",
                "MedicalGarbage_01_Injector_F",
                "MedicalGarbage_01_FirstAidKit_F",
                "Land_Antibiotic_F",
                "Land_Bandage_F",
                "Land_DisinfectantSpray_F",
                "Land_HeatPack_F",
                "Land_IntravenBag_01_full_F",
                "Land_Bandage_F",
                "Land_PainKillers_F",
                "Land_VitaminBottle_F",
                "Land_WaterPurificationTablets_F"
            };
        };
        class office {
            displayName = "$STR_ZEIC_core_ModuleObjectFill_Type_Office";
            order = 30;
            floor = "Land_Rug_01_F";
            objects[] = {
                "Land_FMradio_F",
                "Land_PortableLongRangeRadio_F",
                "Land_Camera_01_F",
                "Land_HandyCam_F",
                "Land_MobilePhone_old_F",
                "Land_MobilePhone_smart_F",
                "Land_Battery_F",
                "Land_File1_F",
                "Land_FilePhotos_F",
                "Land_Notepad_F",
                "Land_PenBlack_F",
                "Land_PenRed_F",
                "Land_PencilBlue_F",
                "Land_PencilGreen_F",
                "Land_PencilRed_F",
                "Land_PensAndPencils_F",
                "Land_Photos_V3_F",
                "Land_Photos_V4_F",
                "Land_Photos_V5_F",
                "Land_Photos_V6_F",
                "Land_Money_F"
            };
        };
        class tools {
            displayName = "$STR_ZEIC_core_ModuleObjectFill_Type_Tools";
            order = 40;
            floor = "Oil_Spill_F";
            objects[] = {
                "Land_Matches_F",
                "Land_ButaneCanister_F",
                "Land_ButaneTorch_F",
                "Land_CanOpener_F",
                "Land_DuctTape_F",
                "Land_DustMask_F",
                "Land_File_F",
                "Land_GasCanister_F",
                "Land_GasCooker_F",
                "Land_Gloves_F",
                "Land_MultiMeter_F",
                "Land_Pliers_F",
                "Land_Rope_01_F",
                "Land_Screwdriver_V2_F",
                "Land_Screwdriver_V1_F",
                "Land_Meter3m_F",
                "Land_Wrench_F"
            };
        };
        class electric {
            displayName = "$STR_ZEIC_core_ModuleObjectFill_Type_Electric";
            order = 50;
            floor = "Land_Garbage_square3_F";
            objects[] = {
                "Land_Tablet_02_black_F",
                "Land_Router_01_black_F",
                "Land_IPPhone_01_black_F",
                "Land_Computer_01_black_F",
                "Land_Camera_01_F",
                "Land_FMradio_F",
                "Land_HandyCam_F",
                "Land_MobilePhone_old_F",
                "Land_PortableLongRangeRadio_F",
                "Land_PortableSpeakers_01_F",
                "Land_BatteryPack_01_battery_black_F",
                "Land_Tablet_01_F"
            };
        };
        // Cold War and older. Nothing that the "Cold War era" fill modifier removes (CfgZEIC_Modifiers.hpp).
        // The template addons of other mods add their objects in subclasses (templates_gm, templates_sog, templates_cup).
        class electronicsOld {
            displayName = "$STR_ZEIC_core_ModuleObjectFill_Type_ElectronicsOld";
            order = 55;
            floor = "Land_Garbage_square3_F";
            objects[] = {
                "Land_FMradio_F",
                "Land_SurvivalRadio_F",
                "Land_Battery_F",
                "Land_CarBattery_01_F",
                "Land_CarBattery_02_F",
                "Land_ExtensionCord_F",
                "Land_MultiMeter_F"
            };
        };
        class cbrn {
            displayName = "$STR_ZEIC_core_ModuleObjectFill_Type_CBRN";
            order = 60;
            floor = "Tarp_01_Small_Yellow_F";
            objects[] = {
                "AntidoteKit_01_F",
                "Brush_01_yellow_F",
                "Brush_01_green_F",
                "DeconKit_01_F",
                "HazmatBag_01_roll_F",
                "SCBACylinder_01_F",
                "SCBACylinder_01_CUR_F",
                "Sponge_01_dry_F",
                "Sponge_01_Wet_F",
                "Land_Antibiotic_F",
                "Land_Bandage_F"
            };
        };
    };

    // Objects with shelves: edge[] = indent from the bounding box (x min, x max, y min, y max),
    // levels[] = height of each shelf below the top of the bounding box. One level = a table: something goes on the floor below it.
    // Objects not listed are filled on the top of their model.
    class Surfaces {
        class Land_CashDesk_F { edge[] = {0.2, 0.2, 0.3, 0.05}; levels[] = {-0.27, -0.76, -1.26}; };
        class Land_CratesWooden_F { edge[] = {1.88, 0.2, 0.3, 0.3}; levels[] = {-0.78}; };
        class Fridge_01_open_F { edge[] = {0.7, 0.7, 0.8, 0.7}; levels[] = {-0.78, -1.33, -1.51}; };
        class Fridge_01_closed_F { edge[] = {0.6, 0.6, 0.6, 0.6}; levels[] = {-0.78}; };
        class Land_Metal_rack_F { edge[] = {0.15, 0.1, 0.15, 0.1}; levels[] = {-0.35, -0.8, -1.25, -1.7}; };
        class Land_Metal_rack_Tall_F { edge[] = {0.1, 0.1, 0.15, 0.05}; levels[] = {-0.075, -0.46, -0.84, -1.22, -1.6}; };
        class Land_Metal_wooden_rack_F { levels[] = {0, -0.42, -0.92, -1.42, -1.92}; };
        class Land_MobileScafolding_01_F { levels[] = {-1.125}; };
        class Land_Rack_F { edge[] = {0.2, 0.2, 0.2, 0.2}; levels[] = {-0.15, -0.53, -0.84, -1.2, -1.52}; };
        class Land_ShelvesWooden_F { edge[] = {0.1, 0.1, 0.2, 0.2}; levels[] = {-0.05, -0.39, -0.71}; };
        class Land_ShelvesWooden_blue_F { edge[] = {0.1, 0.1, 0.2, 0.2}; levels[] = {-0.05, -0.39, -0.71}; };
        class Land_ShelvesWooden_khaki_F { edge[] = {0.1, 0.1, 0.2, 0.2}; levels[] = {-0.05, -0.39, -0.71}; };
        class Land_ShelvesMetal_F { edge[] = {0.24, 0.1, 0.1, 0.1}; levels[] = {-0.24, -0.595, -0.945, -1.3}; };
        class Land_TablePlastic_01_F { edge[] = {0.3, 0.3, 0.1, 0.1}; levels[] = {-0.005}; };
        class Land_ToolTrolley_01_F { edge[] = {0.15, 0.15, 0.25, 0.25}; levels[] = {-0.13, -0.48, -0.83}; };
        class Land_RattanTable_01_F { levels[] = {-0.01}; };
        class Land_WoodenTable_large_F { levels[] = {-0.01}; };
        class Land_WoodenTable_small_F { levels[] = {-0.01}; };
        class Land_Workbench_01_F { edge[] = {0.1, 0.1, 0.35, 0.1}; levels[] = {-0.175}; };
        class Land_OfficeCabinet_02_F { edge[] = {0.2, 0.2, 0.2, 0.2}; levels[] = {0, -0.39, -0.74}; };
        class OfficeTable_01_new_F { edge[] = {1.1, 1, 0.65, 0.6}; levels[] = {-0.65}; };
        class OfficeTable_01_old_F { edge[] = {1.1, 1, 0.65, 0.6}; levels[] = {-0.65}; };
        class Land_TableBig_01_F { edge[] = {0.25, 0.25, 0.25, 0.25}; levels[] = {-0.01}; };
        class Land_TableDesk_F { edge[] = {0.1, 0.1, 0.1, 0.1}; levels[] = {0}; };
        class Land_TableSmall_01_F { edge[] = {0.15, 0.1, 0.15, 0.1}; levels[] = {-0.01}; };
        class Land_CampingTable_F { levels[] = {-0.005}; };
        class Land_CampingTable_white_F { levels[] = {-0.005}; };
        class Land_CampingTable_small_F { levels[] = {0}; };
        class Land_CampingTable_small_white_F { levels[] = {0}; };
        class Land_PicnicTable_01_F { levels[] = {-0.01}; };
        class Land_WoodenCounter_01_F { edge[] = {0.2, 0.2, 0.2, 0.2}; levels[] = {-0.03, -0.77}; };
    };
};
