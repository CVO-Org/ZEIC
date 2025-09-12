class Rsc_ZEIC_ListBuildings
{
	idd=1703;

	controlsBackground[]=
	{
		QPVAR(LB_Background),
		QPVAR(LB_Frame),
		QPVAR(LB_Text_Title),
		QPVAR(LB_Text_Matching),
		QPVAR(LB_Text_MinTemplates),
		QPVAR(LB_Text_MinTemplatesCount),
		QPVAR(LB_Text_ShowPositions)
	};
	
	controls[]={
		QPVAR(LB_Combo_Matching),
		QPVAR(LB_Slider_MinTemplates),
		QPVAR(LB_CheckBox_ShowPositions),
		QPVAR(LB_Button_OK),
		QPVAR(LB_Button_Cancel)
	};

	class PVAR(LB_Background): PVAR(IGUIBack)
	{
		idc = -1;
		x = Q(0.335 * safezoneW + safezoneX);
		y = Q(0.324 * safezoneH + safezoneY);
		w = Q(0.2475 * safezoneW);
		h = Q(0.242 * safezoneH);
	};
	class PVAR(LB_Frame): PVAR(RscFrame)
	{
		idc = -1;
		x = Q(0.335 * safezoneW + safezoneX);
		y = Q(0.324 * safezoneH + safezoneY);
		w = Q(0.2475 * safezoneW);
		h = Q(0.242 * safezoneH);
	};
	class PVAR(LB_Text_Title): PVAR(RscText)
	{
		idc = -1;
		text = "List Template Buildings"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.324 * safezoneH + safezoneY);
		w = Q(0.19 * safezoneW);
		h = Q(0.033 * safezoneH);
	};
	class PVAR(LB_Combo_Matching): PVAR(RscCombo)
	{
		idc = 10;
		x = Q(0.432969 * safezoneW + safezoneX);
		y = Q(0.368 * safezoneH + safezoneY);
		w = Q(0.139219 * safezoneW);
		h = Q(0.022 * safezoneH);
		onLoad= "_this spawn {\
			waitUntil { !isNull (_this select 0) };\
			{ (findDisplay 1703 displayCtrl 10) lbAdd _x } forEach ['All','Military','Civilian','CBRN','OPTRE Civilian[CAN CRASH GAME]','OPTRE Military[CAN CRASH GAME]'];\
			(findDisplay 1703 displayCtrl 10) lbSetCurSel 0;\
		}";
	};
	class PVAR(LB_Text_Matching): PVAR(RscText)
	{
		idc = -1;
		text = "Template Filter"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.368 * safezoneH + safezoneY);
		w = Q(0.0567187 * safezoneW);
		h = Q(0.022 * safezoneH);
	};
	class PVAR(LB_Text_MinTemplates): PVAR(RscText)
	{
		idc = -1;
		text = "Number of Templates"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.412 * safezoneH + safezoneY);
		w = Q(0.0825 * safezoneW);
		h = Q(0.022 * safezoneH);
	};
	class PVAR(LB_Text_MinTemplatesCount): PVAR(RscText)
	{
		idc = 2;
		text = "(15 or less)"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.436 * safezoneH + safezoneY);
		w = Q(0.0825 * safezoneW);
		h = Q(0.022 * safezoneH);
	};
	class PVAR(LB_Slider_MinTemplates): PVAR(RscSlider)
	{
		idc = 20;
		x = Q(0.427812 * safezoneW + safezoneX);
		y = Q(0.412 * safezoneH + safezoneY);
		w = Q(0.144375 * safezoneW);
		h = Q(0.033 * safezoneH);
		onSliderPosChanged = "if (round (_this select 1) > 0) then { (findDisplay 1703 displayCtrl 2) ctrlSetText format['(%1 or less)', round (_this select 1)]; } else { (findDisplay 1703 displayCtrl 2) ctrlSetText '(No Template)'; };";
		onLoad= "_this spawn {\
			waitUntil { !isNull (_this select 0) };\
			(findDisplay 1703 displayCtrl 20) sliderSetRange [ 0, 15 ];\
			(findDisplay 1703 displayCtrl 20) sliderSetPosition 15;\
			};";
	};
	class PVAR(LB_Text_ShowPositions): PVAR(RscText)
	{
		idc = -1;
		text = "Mark Positions"; //--- ToDo: Localize;
		x = Q(0.340156 * safezoneW + safezoneX);
		y = Q(0.467 * safezoneH + safezoneY);
		w = Q(0.0825 * safezoneW);
		h = Q(0.022 * safezoneH);
	};
	class PVAR(LB_CheckBox_ShowPositions): PVAR(RscCheckBox)
	{
		idc = 30;
		x = Q(0.422656 * safezoneW + safezoneX);
		y = Q(0.467 * safezoneH + safezoneY);
		w = Q(0.020625 * safezoneW);
		h = Q(0.033 * safezoneH);
	};
	class PVAR(LB_Button_OK): PVAR(RscButton)
	{
		idc = -1;
		text = "OK"; //--- ToDo: Localize;
		x = Q(0.360781 * safezoneW + safezoneX);
		y = Q(0.522 * safezoneH + safezoneY);
		w = Q(0.04125 * safezoneW);
		h = Q(0.022 * safezoneH);
		onButtonClick  = "[ lbCurSel (findDisplay 1703 displayCtrl 10), round (sliderPosition (findDisplay 1703 displayCtrl 20)), cbChecked (findDisplay 1703 displayCtrl 30) ] spawn zeic_fnc_ui_listBuildings; (findDisplay 1703) closeDisplay 1;";
	};
	class PVAR(LB_Button_Cancel): PVAR(RscButton)
	{
		idc = -1;
		text = "Cancel"; //--- ToDo: Localize;
		x = Q(0.494844 * safezoneW + safezoneX);
		y = Q(0.522 * safezoneH + safezoneY);
		w = Q(0.04125 * safezoneW);
		h = Q(0.022 * safezoneH);
		onButtonClick  = "(findDisplay 1703) closeDisplay 2;";
	};
};
