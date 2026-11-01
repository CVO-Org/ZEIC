class CfgVehicles {
    class Logic;
    class Module_F: Logic {};
    
    class PVAR(ListBuildings): Module_F {
        scope = 2;
        scopeCurator = 1; 
        displayName = CSTRING(ModuleListBuildings_DisplayName);
        category = QPVAR(interiors_dev);
        function = QPFUNC(mod_listBuildings);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 1;
        isTriggerActivated = 0;
        is3DEN = 1;
    };
    
    class PVAR(GarrisonBuilding): Module_F {
        scope = 2;
        scopeCurator = 2; 
        displayName = CSTRING(ModuleGarrisonBuilding_DisplayName);
        category = QPVAR(interiors);
        function = QPFUNC(mod_garrisonBuilding);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa";
        isGlobal = 1;
        isTriggerActivated = 0;
        is3DEN = 1;
    };
    
    class PVAR(ObjectFill): Module_F {
        scope = 2;
        scopeCurator = 2; 
        displayName = CSTRING(ModuleObjectFill_DisplayName);
        category = QPVAR(interiors);
        function = QPFUNC(mod_objectFill);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\box_ca.paa";
        isGlobal = 1;
        isTriggerActivated = 0;
        is3DEN = 1;
    };
    
    class PVAR(ObjectSwitch): Module_F {
        scope = 2;
        scopeCurator = 2;
        displayName = CSTRING(ModuleObjectSwitch_DisplayName);
        category = QPVAR(interiors);
        function = QPFUNC(mod_objectSwitch);
        functionPriority = 1;
        icon = "\A3\Modules_f\data\portraitRespawn_ca.paa";
        isGlobal = 1;
        isTriggerActivated = 0;
        is3DEN = 1;
    };
    
    class PVAR(InteriorFill): Module_F {
        scope = 2;
        scopeCurator = 2; 
        displayName = CSTRING(ModuleInteriorFill_DisplayName);
        category = QPVAR(interiors);
        function = QPFUNC(mod_interiorFill);
        functionPriority = 1;
        icon = "\A3\modules_f\data\portraitModule_ca.paa";
        isGlobal = 1;
        isTriggerActivated = 0;
        is3DEN = 1;
    };
    
    class PVAR(FindBPos): Module_F {
        scope = 2; 
        displayName = CSTRING(ModuleMarkPositions_DisplayName);
        category = QPVAR(interiors_dev);
        function = QPFUNC(mod_findBPos);
        functionPriority = 1;
        icon = "\A3\modules_f\data\portraitStrategicMapMission_ca.paa";
        isGlobal = 1;
        isTriggerActivated = 0;
        is3DEN = 1;
    };
    
    class PVAR(SaveBuildingScheme): Module_F {
        scope = 2;
        displayName = CSTRING(ModuleSaveBuildingScheme_DisplayName);
        category = QPVAR(interiors_dev);
        function = QPFUNC(mod_saveBuildingScheme);
        functionPriority = 1;
        icon = "\a3\Modules_F\Data\iconSavegame_ca.paa";
        isGlobal = 1;
        isTriggerActivated = 0;
        is3DEN = 1;
    };
};
