// Random object variants: any object of a group may be replaced by a random member of the same group.
// An empty string ("") means "sometimes nothing". Moved from fn_randomiseObject.sqf. See docs/config-schema.md.
// GM groups have priority 1: they win over vanilla groups for the same object (GM used to replace the vanilla lists).
class CfgZEIC_Variants {
    class gm_land_gm_sandbags_01_window_01 { priority = 1; objects[] = {"", "land_gm_sandbags_01_window_01", "land_gm_sandbags_01_window_02"}; };
    class gm_land_gm_euro_misc_awning_01 { priority = 1; objects[] = {"", "land_gm_euro_misc_awning_01", "land_gm_euro_misc_awning_02", "land_gm_euro_misc_awning_03", "land_gm_euro_misc_awning_04", "land_gm_euro_misc_awning_05"}; };
    class gm_Land_Basket_F { priority = 1; objects[] = {"Land_Basket_F", "Land_CratesShabby_F", "Land_Sacks_heap_F"}; };
    class gm_Land_PaperBox_01_small_open_brown_F { priority = 1; objects[] = {"Land_PaperBox_01_small_open_brown_F", "Land_PaperBox_01_small_ransacked_brown_F"}; };
    class gm_Land_Orange_01_F { priority = 1; objects[] = {"Land_Orange_01_F", "Land_WaterBottle_01_empty_F", "Land_WaterBottle_01_full_F", "Land_BottlePlastic_V1_F", "Land_Can_Rusty_F", "Land_Can_V1_F", "Land_Can_V2_F", "Land_Can_V3_F", "Land_TacticalBacon_F", "Land_Can_Dented_F", "Land_BottlePlastic_V2_F", "Land_BakedBeans_F", "Land_PowderedMilk_F", "Land_RiceBox_F", "Land_Tableware_01_stackOfNapkins_F", "Land_Tableware_01_cup_F", "Land_TinContainer_F"}; };
    class gm_Land_Cargo10_blue_F { priority = 1; objects[] = {"Land_Cargo10_blue_F", "Land_Cargo10_brick_red_F", "Land_Cargo10_grey_F", "Land_Cargo10_light_blue_F", "Land_Cargo10_light_green_F", "Land_Cargo10_military_green_F", "Land_Cargo10_orange_F", "Land_Cargo10_red_F", "Land_Cargo10_sand_F", "Land_Cargo10_yellow_F", "Land_Cargo10_white_F"}; };
    class gm_Land_Cargo20_blue_F { priority = 1; objects[] = {"Land_Cargo20_blue_F", "Land_Cargo20_brick_red_F", "Land_Cargo20_grey_F", "Land_Cargo20_light_blue_F", "Land_Cargo20_light_green_F", "Land_Cargo20_military_green_F", "Land_Cargo20_orange_F", "Land_Cargo20_red_F", "Land_Cargo20_sand_F", "Land_Cargo20_yellow_F", "Land_Cargo20_white_F"}; };
    class gm_Land_Cargo40_blue_F { priority = 1; objects[] = {"Land_Cargo40_blue_F", "Land_Cargo40_brick_red_F", "Land_Cargo40_grey_F", "Land_Cargo40_light_blue_F", "Land_Cargo40_light_green_F", "Land_Cargo40_military_green_F", "Land_Cargo40_orange_F", "Land_Cargo40_red_F", "Land_Cargo40_sand_F", "Land_Cargo40_yellow_F", "Land_Cargo40_white_F"}; };
};
