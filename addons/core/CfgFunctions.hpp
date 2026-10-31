class CfgFunctions {
    class ZEIC {

        class common {
            file = PATH_TO_FUNC_SUB(common);
            
            class init { postInit = 1; };   // ZEN module registration

            class mod_findBPos {};

            class addCustomHouse {};
            class addCustomTemplate {};

            class misc_Vector2Eden {};
            class misc_logMsg {};
        };

        class dev {
            file = PATH_TO_FUNC_SUB(dev);

            class dev_check {};
            class dev_selfTest {
                #if _ZEIC_DEV_
                postInit = 1;
                #endif
            };
            class dev_spawn {};
            class dev_test_addon {};
            class dev_test_configTemplates {};
            class dev_test_createTemplate {};
            class dev_test_dialog {};
            class dev_test_garrison {};
            class dev_test_garrisonDialog {};
            class dev_test_mergedCases {};
            class dev_test_missionTemplates {};
            class dev_test_objectModes {};
            class dev_test_queue {};
            class dev_test_rowOrder {};
            class dev_test_scriptApi {};
        };

        class feedback {
            file = PATH_TO_FUNC_SUB(feedback);

            class feedback_draw {};
            class feedback_finish {};
            class feedback_flush {};
            class feedback_report {};
            class feedback_send {};
            class feedback_update {};
        };

        class garrisonBuilding {
            file = PATH_TO_FUNC_SUB(garrisonBuilding);
            
            class garrisonBuilding_factions {};
            class garrisonBuilding_finishBuilding {};
            class garrisonBuilding_finishJob {};
            class garrisonBuilding_selectBuildings {};
            class garrisonBuilding_start {};
            class garrisonBuilding_step {};
            class garrisonBuilding_unitTypes {};
            class garrisonUnit {};
            class mod_garrisonBuilding {};
            class ui_garrisonBuilding {};
            class ui_garrisonBuilding_onLoad {};
        };

        class InteriorFill {
            file = PATH_TO_FUNC_SUB(InteriorFill);
            
            class createTemplate {};
            class findTemplates {};
            class interiorFill_categories {};
            class interiorFill_enqueue {};
            class interiorFill_finishBuilding {};
            class interiorFill_finishJob {};
            class interiorFill_notify {};
            class interiorFill_prepareBuilding {};
            class interiorFill_selectTemplate {};
            class interiorFill_spawnObject {};
            class interiorFill_start {};
            class interiorFill_step {};
            class mod_interiorFill {};
            class randomiseObject {};
            class ui_interiorFill {};
            class ui_interiorFill_onLoad {};
        };

        class listBuildings {
            file = PATH_TO_FUNC_SUB(listBuildings);
            
            class mod_listBuildings {};
            class ui_listBuildings {};
        };

        class objectFill {
            file = PATH_TO_FUNC_SUB(objectFill);
            
            class mod_objectFill {};
            class ui_objectFill {};
        };

        class objectSwitch {
            file = PATH_TO_FUNC_SUB(objectSwitch);
            
            class mod_objectSwitch {};
            class ui_objectSwitch {};
        };

        class queue {
            file = PATH_TO_FUNC_SUB(queue);

            class queue_add {};
            class queue_onFrame {};
            class queue_sortBuildings {};
        };

        class rotation {
            file = PATH_TO_FUNC_SUB(rotation);
            
            class misc_rotateAroundOwnAxisX {};
            class misc_rotateAroundOwnAxisY {};
            class misc_rotateAroundOwnAxisZ {};
        };

        class saveBuildingScheme {
            file = PATH_TO_FUNC_SUB(saveBuildingScheme);

            class isVanillaObject {};
            class mod_saveBuildingScheme {};
        };

        class ui {
            file = PATH_TO_FUNC_SUB(ui);

            class ui_dialogAdd {};
            class ui_dialogCheckbox {};
            class ui_dialogCombo {};
            class ui_dialogConfirm {};
            class ui_dialogCreate {};
            class ui_dialogEdit {};
            class ui_dialogFinish {};
            class ui_dialogList {};
            class ui_dialogRow {};
            class ui_dialogSlider {};
            class ui_dialogToolbox {};
        };


    };
};
