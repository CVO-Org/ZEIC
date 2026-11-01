// Random object variants: any object of a group may be replaced by a random member of the same group.
// An empty string ("") means "sometimes nothing". Moved from fn_randomiseObject.sqf. See docs/config-schema.md.
// GM used to replace the vanilla lists (priority 1); the Cold War era fill modifier does that now (CfgZEIC_Modifiers.hpp).
class CfgZEIC_Variants {
    class gm_land_gm_sandbags_01_window_01 { objects[] = {"", "land_gm_sandbags_01_window_01", "land_gm_sandbags_01_window_02"}; };
    class gm_land_gm_euro_misc_awning_01 { objects[] = {"", "land_gm_euro_misc_awning_01", "land_gm_euro_misc_awning_02", "land_gm_euro_misc_awning_03", "land_gm_euro_misc_awning_04", "land_gm_euro_misc_awning_05"}; };
    class gm_Land_PaperBox_01_small_open_brown_F { objects[] = {"Land_PaperBox_01_small_open_brown_F", "Land_PaperBox_01_small_ransacked_brown_F"}; };
};
