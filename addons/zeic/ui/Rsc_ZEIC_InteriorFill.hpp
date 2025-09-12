class Rsc_ZEIC_InteriorFill
{
	idd=1705;
	// Fill Type Mil/Civ
	// Fill Area (nearest = 0 or meters)

	controlsBackground[]=
	{
		QPVAR(IF_Background),
		QPVAR(IF_Frame),
		QPVAR(IF_Text_Title),
		QPVAR(IF_Text_Type),
		QPVAR(IF_Text_Items),
		QPVAR(IF_Text_Detail),
		QPVAR(IF_Text_EditObject),
		QPVAR(IF_Text_AllowDamage)
	};
	
	controls[]={
		QPVAR(IF_Combo_Type),
		QPVAR(IF_Slider_Items),
		QPVAR(IF_Combo_Detail),
		QPVAR(IF_CheckBox_EditObject),
		QPVAR(IF_CheckBox_AllowDamage),
		QPVAR(IF_Button_OK),
		QPVAR(IF_Button_Cancel)
	};

	class PVAR(IF_Background): PVAR(IGUIBack)
	{
		idc = -1;
		x = Q(0.335 * safezoneW + safezoneX);
		y = Q(0.324 * safezoneH + safezoneY);
		w = Q(0.2475 * safezoneW);
		h = Q(0.252 * safezoneH);
	};
	class PVAR(IF_Frame): PVAR(RscFrame)
	{
		idc = -1;
		x = Q(0.335 * safezoneW + safezoneX);
		y = Q(0.324 * safezoneH + safezoneY);
		w = Q(0.2475 * safezoneW);
		h = Q(0.252 * safezoneH);
	};
	class PVAR(IF_Text_Title): PVAR(RscText)
	{
		idc = 1;
		text = "Interior Fill"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.324 * safezoneH + safezoneY);
		w = Q(0.19 * safezoneW);
		h = Q(0.033 * safezoneH);
		onLoad= "_this spawn { waitUntil { !isNull (_this select 0) }; (findDisplay 1705 displayCtrl 1) ctrlSetText format['Interior Fill - %1 (%2m)', getText(configFile >> 'CfgVehicles' >> typeOf (missionNamespace getVariable ['ZEIC_UiLastBuilding',objNull]) >> 'displayName'), round ((screenToWorld getMousePosition) distance2D (missionNamespace getVariable ['ZEIC_UiLastBuilding',objNull]))]; };";
	};
	class PVAR(IF_Combo_Type): PVAR(RscCombo)
	{
		idc = 10;
		x = Q(0.432969 * safezoneW + safezoneX);
		y = Q(0.368 * safezoneH + safezoneY);
		w = Q(0.139219 * safezoneW);
		h = Q(0.022 * safezoneH);
		tooltip = "Type of interior to fill";
		onLoad= "_this spawn {\
			waitUntil { !isNull (_this select 0) };\
			call ZEIC_fnc_addInteriorFillCategories;\
			(findDisplay 1705 displayCtrl 10) lbSetCurSel (missionNamespace getVariable ['ZEIC_UiInteriorType', 0]);\
		}";
	};
	class PVAR(IF_Text_Type): PVAR(RscText)
	{
		idc = -1;
		text = "Object Type"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.368 * safezoneH + safezoneY);
		w = Q(0.0567187 * safezoneW);
		h = Q(0.022 * safezoneH);
	};
	class PVAR(IF_Text_Items): PVAR(RscText)
	{
		idc = 2;
		text = "Radius: Nearest"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.412 * safezoneH + safezoneY);
		w = Q(0.0825 * safezoneW);
		h = Q(0.022 * safezoneH);
	};
	class PVAR(IF_Slider_Items): PVAR(RscSlider)
	{
		idc = 20;
		x = Q(0.427812 * safezoneW + safezoneX);
		y = Q(0.412 * safezoneH + safezoneY);
		w = Q(0.144375 * safezoneW);
		h = Q(0.033 * safezoneH);
		tooltip = "Radius of buildings to fill";
		onSliderPosChanged = "if (round (_this select 1) > 0) then { (findDisplay 1705 displayCtrl 2) ctrlSetText format['Radius: %1 Meters', round (_this select 1)]; } else { (findDisplay 1705 displayCtrl 2) ctrlSetText 'Radius: Nearest'; };";
		onLoad= "_this spawn {\
			waitUntil { !isNull (_this select 0) };\
			(findDisplay 1705 displayCtrl 20) sliderSetRange [ 0, 250 ];\
			(findDisplay 1705 displayCtrl 20) sliderSetPosition 0;\
		};";
	};
	class PVAR(IF_Text_Detail): PVAR(RscText)
	{
		idc = 5;
		text = "Level of Detail";
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.457 * safezoneH + safezoneY);
		w = Q(0.0567187 * safezoneW);
		h = Q(0.022 * safezoneH);
	};
	class PVAR(IF_Combo_Detail): PVAR(RscCombo)
	{
		idc = 50;
		x = Q(0.432969 * safezoneW + safezoneX);
		y = Q(0.457 * safezoneH + safezoneY);
		w = Q(0.139219 * safezoneW);
		h = Q(0.022 * safezoneH);
		tooltip = "Level of complexity for interiors";
		onLoad= "_this spawn {\
			waitUntil { !isNull (_this select 0) };\
			{ (findDisplay 1705 displayCtrl 50) lbAdd _x } forEach ['Defences Only', 'Full'];\
			(findDisplay 1705 displayCtrl 50) lbSetCurSel (missionNamespace getVariable ['ZEIC_UiInteriorDetail', 1]);\
		}";
	};
	class PVAR(IF_Text_EditObject): PVAR(RscText)
	{
		idc = 3;
		text = "Edit Objects"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.501 * safezoneH + safezoneY);
		w = Q(0.0845 * safezoneW);
		h = Q(0.022 * safezoneH);
		onLoad= "_this spawn { waitUntil { !isNull (_this select 0) };\
			if is3DEN then { (findDisplay 1705 displayCtrl 3) ctrlShow false; };\
		}";
	};
	class PVAR(IF_CheckBox_EditObject): PVAR(RscCheckBox)
	{
		idc = 30;
		x = Q(0.422656 * safezoneW + safezoneX);
		y = Q(0.501 * safezoneH + safezoneY);
		w = Q(0.020625 * safezoneW);
		h = Q(0.033 * safezoneH);
		tooltip = "Add the spawned objects to Curator\nIf disabled, they cannot be moved or edited by Zeus.";
		checked = 1;
		onLoad= "_this spawn { waitUntil { !isNull (_this select 0) };\
			(findDisplay 1705 displayCtrl 30) cbSetChecked (missionNamespace getVariable ['ZEIC_UiInteriorEdit', true]);\
			if is3DEN then { (findDisplay 1705 displayCtrl 30) ctrlShow false; };\
		}";
	};
	class PVAR(IF_Text_AllowDamage): PVAR(RscText)
	{
		idc = 4;
		text = "Allow Damage"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.545 * safezoneH + safezoneY);
		w = Q(0.0845 * safezoneW);
		h = Q(0.022 * safezoneH);
		onLoad= "_this spawn { waitUntil { !isNull (_this select 0) };\
			if is3DEN then { (findDisplay 1705 displayCtrl 4) ctrlShow false; };\
		}";
	};
	class PVAR(IF_CheckBox_AllowDamage): PVAR(RscCheckBox)
	{
		idc = 40;
		x = Q(0.422656 * safezoneW + safezoneX);
		y = Q(0.545 * safezoneH + safezoneY);
		w = Q(0.020625 * safezoneW);
		h = Q(0.033 * safezoneH);
		tooltip = "Allow the building to be damaged.\nIf enabled, all objects inside the building may be left 'floating' when damaged/destroyed.";
		onLoad= "_this spawn { waitUntil { !isNull (_this select 0) };\
			(findDisplay 1705 displayCtrl 40) cbSetChecked (missionNamespace getVariable ['ZEIC_UiInteriorDamage', false]);\
			if is3DEN then { (findDisplay 1705 displayCtrl 40) ctrlShow false; };\
		}";
	};
	class PVAR(IF_Button_OK): PVAR(RscButton)
	{
		idc = -1;
		text = "OK"; //--- ToDo: Localize;
		x = Q(0.360781 * safezoneW + safezoneX);
		y = Q(0.599 * safezoneH + safezoneY);
		w = Q(0.04125 * safezoneW);
		h = Q(0.022 * safezoneH);
		onButtonClick  = "[ lbCurSel (findDisplay 1705 displayCtrl 10), round (sliderPosition (findDisplay 1705 displayCtrl 20)), cbChecked (findDisplay 1705 displayCtrl 30), cbChecked (findDisplay 1705 displayCtrl 40), lbCurSel (findDisplay 1705 displayCtrl 50) ] spawn ZEIC_fnc_ui_interiorFill; (findDisplay 1705) closeDisplay 1;";
	};
	class PVAR(IF_Button_Cancel): PVAR(RscButton)
	{
		idc = -1;
		text = "Cancel"; //--- ToDo: Localize;
		x = Q(0.494844 * safezoneW + safezoneX);
		y = Q(0.599 * safezoneH + safezoneY);
		w = Q(0.04125 * safezoneW);
		h = Q(0.022 * safezoneH);
		onButtonClick  = "(findDisplay 1705) closeDisplay 2;";
	};
};
