class CfgFunctions {
	class ZEIC {

        class common {
            file = PATH_TO_FUNC_SUB(common);
            
            class init { postInit = 1; };	// Zeus (Dedicated Fix)

            class mod_findBPos {};

            class addCustomHouse {};
            class addCustomTemplate {};

            class misc_Vector2Eden {};
            class misc_logMsg {};

            class zeus_addModules {};		// Zeus (Dedicated Fix)
        };

        class garrisonBuilding {
            file = PATH_TO_FUNC_SUB(garrisonBuilding);
            
            class garrisonUnit {};
            class mod_garrisonBuilding {};
            class ui_garrisonBuilding {};
            class ui_garrisonCombo {};
        };

        class InteriorFill {
            file = PATH_TO_FUNC_SUB(InteriorFill);
            
            class addInteriorFillCategories {};

            class checkDetailLevel {};
            class createTemplate {};
            class findTemplates {};	
            class mod_interiorFill {};
            class randomiseObject {};
            class templateCanSpawn {};
            class ui_interiorFill {};
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


	};
};
