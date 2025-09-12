class Rsc_ZEIC_ObjectFill
{
	idd=1704;

	controlsBackground[]=
	{
		QPVAR(OF_Background),
		QPVAR(OF_Frame),
		QPVAR(OF_Text_Title),
		QPVAR(OF_Text_Type),
		QPVAR(OF_Text_Items),
		QPVAR(OF_Text_EditObject)
	};
	
	controls[]={
		QPVAR(OF_Combo_Type),
		QPVAR(OF_Slider_Items),
		QPVAR(OF_CheckBox_EditObject),
		QPVAR(OF_Button_OK),
		QPVAR(OF_Button_Cancel)
	};

	class PVAR(OF_Background): PVAR(IGUIBack)
	{
		idc = -1;
		x = Q(0.335 * safezoneW + safezoneX);
		y = Q(0.324 * safezoneH + safezoneY);
		w = Q(0.2475 * safezoneW);
		h = Q(0.242 * safezoneH);
	};
	class PVAR(OF_Frame): PVAR(RscFrame)
	{
		idc = -1;
		x = Q(0.335 * safezoneW + safezoneX);
		y = Q(0.324 * safezoneH + safezoneY);
		w = Q(0.2475 * safezoneW);
		h = Q(0.242 * safezoneH);
	};
	class PVAR(OF_Text_Title): PVAR(RscText)
	{
		idc = 1;
		text = "Object Fill"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.324 * safezoneH + safezoneY);
		w = Q(0.19 * safezoneW);
		h = Q(0.033 * safezoneH);
		onLoad= "_this spawn { waitUntil { !isNull (_this select 0) }; (findDisplay 1704 displayCtrl 1) ctrlSetText format['Object Fill (%1)', getText(configFile >> 'CfgVehicles' >> typeOf (missionNamespace getVariable ['ZEIC_UiLastObject',objNull]) >> 'displayName')]; };";
	};
	class PVAR(OF_Combo_Type): PVAR(RscCombo)
	{
		idc = 10;
		x = Q(0.432969 * safezoneW + safezoneX);
		y = Q(0.368 * safezoneH + safezoneY);
		w = Q(0.139219 * safezoneW);
		h = Q(0.022 * safezoneH);
		onLoad= "_this spawn {\
			waitUntil { !isNull (_this select 0) };\
			{ (findDisplay 1704 displayCtrl 10) lbAdd _x } forEach ['Random', 'Food', 'Medical', 'Office', 'Tools', 'Electric', 'CBRN Cleaning'];\
			(findDisplay 1704 displayCtrl 10) lbSetCurSel 0;\
		}";
	};
	class PVAR(OF_Text_Type): PVAR(RscText)
	{
		idc = -1;
		text = "Object Type"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.368 * safezoneH + safezoneY);
		w = Q(0.0567187 * safezoneW);
		h = Q(0.022 * safezoneH);
	};
	class PVAR(OF_Text_Items): PVAR(RscText)
	{
		idc = 2;
		text = "Fill Percent (30)"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.412 * safezoneH + safezoneY);
		w = Q(0.0825 * safezoneW);
		h = Q(0.022 * safezoneH);
	};
	class PVAR(OF_Slider_Items): PVAR(RscSlider)
	{
		idc = 20;
		x = Q(0.427812 * safezoneW + safezoneX);
		y = Q(0.412 * safezoneH + safezoneY);
		w = Q(0.144375 * safezoneW);
		h = Q(0.033 * safezoneH);
		tooltip = "Chance to spawn an object";
		onSliderPosChanged = "(findDisplay 1704 displayCtrl 2) ctrlSetText format['Fill Percent (%1)', round (_this select 1) * 10];";
		onLoad= "_this spawn {\
			waitUntil { !isNull (_this select 0) };\
			(findDisplay 1704 displayCtrl 20) sliderSetRange [ 1, 10 ];\
			(findDisplay 1704 displayCtrl 20) sliderSetPosition 3;\
			};";
	};
	class PVAR(OF_Text_EditObject): PVAR(RscText)
	{
		idc = 3;
		text = "Edit Object"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.467 * safezoneH + safezoneY);
		w = Q(0.0845 * safezoneW);
		h = Q(0.022 * safezoneH);
		onLoad= "_this spawn { waitUntil { !isNull (_this select 0) };\
			if is3DEN then { (findDisplay 1704 displayCtrl 3) ctrlShow false; };\
		}";
	};
	class PVAR(OF_CheckBox_EditObject): PVAR(RscCheckBox)
	{
		idc = 30;
		x = Q(0.422656 * safezoneW + safezoneX);
		y = Q(0.467 * safezoneH + safezoneY);
		w = Q(0.020625 * safezoneW);
		h = Q(0.033 * safezoneH);
		tooltip = "Allow Zeus to Move/Edit Objects";
		checked = 1;
		onLoad= "_this spawn { waitUntil { !isNull (_this select 0) };\
			if is3DEN then { (findDisplay 1704 displayCtrl 30) ctrlShow false; };\
		}";
	};
	class PVAR(OF_Button_OK): PVAR(RscButton)
	{
		idc = -1;
		text = "OK"; //--- ToDo: Localize;
		x = Q(0.360781 * safezoneW + safezoneX);
		y = Q(0.522 * safezoneH + safezoneY);
		w = Q(0.04125 * safezoneW);
		h = Q(0.022 * safezoneH);
		onButtonClick  = "[ lbCurSel (findDisplay 1704 displayCtrl 10), round (sliderPosition (findDisplay 1704 displayCtrl 20)) * 10, cbChecked (findDisplay 1704 displayCtrl 30) ] spawn zeic_fnc_ui_objectFill; (findDisplay 1704) closeDisplay 1;";
	};
	class PVAR(OF_Button_Cancel): PVAR(RscButton)
	{
		idc = -1;
		text = "Cancel"; //--- ToDo: Localize;
		x = Q(0.494844 * safezoneW + safezoneX);
		y = Q(0.522 * safezoneH + safezoneY);
		w = Q(0.04125 * safezoneW);
		h = Q(0.022 * safezoneH);
		onButtonClick  = "(findDisplay 1704) closeDisplay 2;";
	};
};
