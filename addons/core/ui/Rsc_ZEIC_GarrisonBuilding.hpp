class Rsc_ZEIC_GarrisonBuilding
{
    idd=1702;

    controlsBackground[]=
    {
        QPVAR(GB_Background),
        QPVAR(GB_Frame),
        QPVAR(GB_Text_Title),
        QPVAR(GB_Text_Type),
        QPVAR(GB_Text_Units),
        QPVAR(GB_Text_Radius),
        QPVAR(GB_Text_Percent),
        QPVAR(GB_Text_DSEnabled),
        QPVAR(GB_Text_TREnabled)
    };

    controls[]={
        QPVAR(GB_Combo_Type),
        QPVAR(GB_Slider_Units),
        QPVAR(GB_Slider_Radius),
        QPVAR(GB_Slider_Percent),
        QPVAR(GB_CheckBox_DSEnabled),
        QPVAR(GB_CheckBox_TREnabled),
        QPVAR(GB_Button_OK),
        QPVAR(GB_Button_Cancel)
    };

    class PVAR(GB_Background): PVAR(IGUIBack)
    {
        idc = -1;
        x = Q(0.335 * safezoneW + safezoneX);
        y = Q(0.324 * safezoneH + safezoneY);
        w = Q(0.2475 * safezoneW);
        h = Q(0.33 * safezoneH);
    };
    class PVAR(GB_Frame): PVAR(RscFrame)
    {
        idc = -1;
        x = Q(0.335 * safezoneW + safezoneX);
        y = Q(0.324 * safezoneH + safezoneY);
        w = Q(0.2475 * safezoneW);
        h = Q(0.33 * safezoneH);
    };
    class PVAR(GB_Text_Title): PVAR(RscText)
    {
        idc = 1;
        text = "Garrison Building"; //--- ToDo: Localize;
        x = Q(0.340156 * safezoneW + safezoneX);
        y = Q(0.324 * safezoneH + safezoneY);
        w = Q(0.19 * safezoneW);
        h = Q(0.033 * safezoneH);
        onLoad= "_this spawn { waitUntil { !isNull (_this select 0) }; (findDisplay 1702 displayCtrl 1) ctrlSetText format['Garrison Building - %1 (%2m)', getText(configFile >> 'CfgVehicles' >> typeOf (missionNamespace getVariable ['ZEIC_UiLastBuilding',objNull]) >> 'displayName'), round ((screenToWorld getMousePosition) distance2D (missionNamespace getVariable ['ZEIC_UiLastBuilding',objNull]))]; };";
    };
    class PVAR(GB_Combo_Type): PVAR(RscCombo)
    {
        idc = 10;
        x = Q(0.432969 * safezoneW + safezoneX);
        y = Q(0.368 * safezoneH + safezoneY);
        w = Q(0.139219 * safezoneW);
        h = Q(0.022 * safezoneH);
        tooltip = "Choose the faction you wish to spawn.";
        onLoad= "_this spawn zeic_fnc_ui_garrisonCombo;";
    };
    class PVAR(GB_Text_Type): PVAR(RscText)
    {
        idc = -1;
        text = "Faction"; //--- ToDo: Localize;
        x = Q(0.340156 * safezoneW + safezoneX);
        y = Q(0.368 * safezoneH + safezoneY);
        w = Q(0.0567187 * safezoneW);
        h = Q(0.022 * safezoneH);
    };
    class PVAR(GB_Text_Units): PVAR(RscText)
    {
        idc = 2;
        text = "Units per building"; //--- ToDo: Localize;
        x = Q(0.340156 * safezoneW + safezoneX);
        y = Q(0.412 * safezoneH + safezoneY);
        w = Q(0.0825 * safezoneW);
        h = Q(0.022 * safezoneH);
    };
    class PVAR(GB_Slider_Units): PVAR(RscSlider)
    {
        idc = 20;
        x = Q(0.427812 * safezoneW + safezoneX);
        y = Q(0.412 * safezoneH + safezoneY);
        w = Q(0.144375 * safezoneW);
        h = Q(0.033 * safezoneH);
        tooltip = "Units per building, limited by the building's positions.";
        onSliderPosChanged = "(findDisplay 1702 displayCtrl 2) ctrlSetText format['Units per building (%1)', round (_this select 1)];";
        onLoad= "_this spawn {\
            waitUntil { !isNull (_this select 0) };\
            private _positions = count ((missionNamespace getVariable ['ZEIC_UiLastBuilding',objNull]) buildingPos -1);\
            private _units = missionNamespace getVariable ['ZEIC_UiGarrisonUnits', 1 max round (_positions / 3)];\
            (findDisplay 1702 displayCtrl 20) sliderSetRange [ 1, 12 max _positions ];\
            (findDisplay 1702 displayCtrl 20) sliderSetSpeed [ 1, 1 ];\
            (findDisplay 1702 displayCtrl 20) sliderSetPosition _units;\
            (findDisplay 1702 displayCtrl 2) ctrlSetText format['Units per building (%1)', round _units];\
        };";
    };
    class PVAR(GB_Text_Radius): PVAR(RscText)
    {
        idc = 5;
        text = "Radius: This building"; //--- ToDo: Localize;
        x = Q(0.340156 * safezoneW + safezoneX);
        y = Q(0.456 * safezoneH + safezoneY);
        w = Q(0.0825 * safezoneW);
        h = Q(0.022 * safezoneH);
    };
    class PVAR(GB_Slider_Radius): PVAR(RscSlider)
    {
        idc = 50;
        x = Q(0.427812 * safezoneW + safezoneX);
        y = Q(0.456 * safezoneH + safezoneY);
        w = Q(0.144375 * safezoneW);
        h = Q(0.033 * safezoneH);
        tooltip = "0: only this building.\nAbove 0: garrison a share of the buildings within this radius.";
        onSliderPosChanged = "\
            private _radius = round (_this select 1);\
            (findDisplay 1702 displayCtrl 5) ctrlSetText (['Radius: This building', format['Radius: %1 m', _radius]] select (_radius > 0));\
            (findDisplay 1702 displayCtrl 60) ctrlEnable (_radius > 0);\
        ";
        onLoad= "_this spawn {\
            waitUntil { !isNull (_this select 0) };\
            private _radius = missionNamespace getVariable ['ZEIC_UiGarrisonRadius', 0];\
            (findDisplay 1702 displayCtrl 50) sliderSetRange [ 0, 250 ];\
            (findDisplay 1702 displayCtrl 50) sliderSetSpeed [ 10, 10 ];\
            (findDisplay 1702 displayCtrl 50) sliderSetPosition _radius;\
            (findDisplay 1702 displayCtrl 5) ctrlSetText (['Radius: This building', format['Radius: %1 m', _radius]] select (_radius > 0));\
            (findDisplay 1702 displayCtrl 60) ctrlEnable (_radius > 0);\
        };";
    };
    class PVAR(GB_Text_Percent): PVAR(RscText)
    {
        idc = 6;
        text = "Occupied: 50%"; //--- ToDo: Localize;
        x = Q(0.340156 * safezoneW + safezoneX);
        y = Q(0.5 * safezoneH + safezoneY);
        w = Q(0.0825 * safezoneW);
        h = Q(0.022 * safezoneH);
    };
    class PVAR(GB_Slider_Percent): PVAR(RscSlider)
    {
        idc = 60;
        x = Q(0.427812 * safezoneW + safezoneX);
        y = Q(0.5 * safezoneH + safezoneY);
        w = Q(0.144375 * safezoneW);
        h = Q(0.033 * safezoneH);
        tooltip = "Share of the buildings within the radius that get a garrison, picked at random.";
        onSliderPosChanged = "(findDisplay 1702 displayCtrl 6) ctrlSetText format['Occupied: %1%2', round (_this select 1), '%'];";
        onLoad= "_this spawn {\
            waitUntil { !isNull (_this select 0) };\
            private _percent = missionNamespace getVariable ['ZEIC_UiGarrisonPercent', 50];\
            (findDisplay 1702 displayCtrl 60) sliderSetRange [ 10, 100 ];\
            (findDisplay 1702 displayCtrl 60) sliderSetSpeed [ 10, 10 ];\
            (findDisplay 1702 displayCtrl 60) sliderSetPosition _percent;\
            (findDisplay 1702 displayCtrl 6) ctrlSetText format['Occupied: %1%2', round _percent, '%'];\
        };";
    };
    class PVAR(GB_Text_DSEnabled): PVAR(RscText)
    {
        idc = -1;
        text = "Dynamic Simulation"; //--- ToDo: Localize;
        x = Q(0.340156 * safezoneW + safezoneX);
        y = Q(0.544 * safezoneH + safezoneY);
        w = Q(0.0825 * safezoneW);
        h = Q(0.022 * safezoneH);
    };
    class PVAR(GB_CheckBox_DSEnabled): PVAR(RscCheckBox)
    {
        idc = 30;
        x = Q(0.422656 * safezoneW + safezoneX);
        y = Q(0.544 * safezoneH + safezoneY);
        w = Q(0.020625 * safezoneW);
        h = Q(0.033 * safezoneH);
        tooltip = "Enables Dynamic Simulation for units\nDO NOT use when AI can easily be seen (e.g. outside or top of buildings).";
        onLoad= "_this spawn {\
            waitUntil { !isNull (_this select 0) };\
            (findDisplay 1702 displayCtrl 30) cbSetChecked (missionNamespace getVariable ['ZEIC_UiGarrisonDynamic', false]);\
        };";
    };
    class PVAR(GB_Text_TREnabled): PVAR(RscText)
    {
        idc = -1;
        text = "Move AI Trigger"; //--- ToDo: Localize;
        x = Q(0.340156 * safezoneW + safezoneX);
        y = Q(0.574 * safezoneH + safezoneY);
        w = Q(0.0825 * safezoneW);
        h = Q(0.022 * safezoneH);
    };
    class PVAR(GB_CheckBox_TREnabled): PVAR(RscCheckBox)
    {
        idc = 40;
        x = Q(0.422656 * safezoneW + safezoneX);
        y = Q(0.574 * safezoneH + safezoneY);
        w = Q(0.020625 * safezoneW);
        h = Q(0.033 * safezoneH);
        tooltip = "Creates a Trigger to allow AI movement when a player is near.";
        onLoad= "_this spawn {\
            waitUntil { !isNull (_this select 0) };\
            (findDisplay 1702 displayCtrl 40) cbSetChecked (missionNamespace getVariable ['ZEIC_UiCreateTrigger', false]);\
        };";
    };
    class PVAR(GB_Button_OK): PVAR(RscButton)
    {
        idc = -1;
        text = "OK"; //--- ToDo: Localize;
        x = Q(0.360781 * safezoneW + safezoneX);
        y = Q(0.61 * safezoneH + safezoneY);
        w = Q(0.04125 * safezoneW);
        h = Q(0.022 * safezoneH);
        onButtonClick  = "[\
            (findDisplay 1702 displayCtrl 10) lbData (lbCurSel (findDisplay 1702 displayCtrl 10)),\
            round (sliderPosition (findDisplay 1702 displayCtrl 20)),\
            cbChecked (findDisplay 1702 displayCtrl 30),\
            cbChecked (findDisplay 1702 displayCtrl 40),\
            round (sliderPosition (findDisplay 1702 displayCtrl 50)),\
            round (sliderPosition (findDisplay 1702 displayCtrl 60))\
            ] spawn zeic_fnc_ui_garrisonBuilding; (findDisplay 1702) closeDisplay 1;";
    };
    class PVAR(GB_Button_Cancel): PVAR(RscButton)
    {
        idc = -1;
        text = "Cancel"; //--- ToDo: Localize;
        x = Q(0.494844 * safezoneW + safezoneX);
        y = Q(0.61 * safezoneH + safezoneY);
        w = Q(0.04125 * safezoneW);
        h = Q(0.022 * safezoneH);
        onButtonClick  = "(findDisplay 1702) closeDisplay 2;";
    };
};
