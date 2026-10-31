// Controls of the ZEIC dialogs, laid out like the dialogs of Zeus Enhanced (ZEN): a title bar in the
// profile colour, rows with a label on the left and a vanilla control on the right.
// The dialogs are placed by script (functions\ui), these classes only define the look.
class RscEdit;
class RscListBox {
    class ListScrollBar;
};
class RscButtonMenuOK;
class RscButtonMenuCancel;
class ctrlXSliderH;
class ctrlToolbox;

class PVAR(ctrlTitle): RscText {
    colorBackground[] = {
        "(profileNamespace getVariable ['GUI_BCG_RGB_R', 0.13])",
        "(profileNamespace getVariable ['GUI_BCG_RGB_G', 0.54])",
        "(profileNamespace getVariable ['GUI_BCG_RGB_B', 0.21])",
        "(profileNamespace getVariable ['GUI_BCG_RGB_A', 0.8])"
    };
};
class PVAR(ctrlBackground): RscText {
    colorBackground[] = {0, 0, 0, 0.7};
};
class PVAR(ctrlLabel): RscText {
    colorBackground[] = {0, 0, 0, 0.5};
};
class PVAR(ctrlHint): RscText {
    colorText[] = {1, 1, 1, 0.5};
    sizeEx = QUOTE(UI_H(0.8));
};

class PVAR(ctrlCombo): RscCombo {
    arrowFull = "\a3\3DEN\Data\Controls\ctrlCombo\arrowFull_ca.paa";
    arrowEmpty = "\a3\3DEN\Data\Controls\ctrlCombo\arrowEmpty_ca.paa";
    class ComboScrollBar: ComboScrollBar {
        thumb = "\a3\3DEN\Data\Controls\ctrlDefault\thumb_ca.paa";
        border = "\a3\3DEN\Data\Controls\ctrlDefault\border_ca.paa";
        arrowFull = "\a3\3DEN\Data\Controls\ctrlDefault\arrowFull_ca.paa";
        arrowEmpty = "\a3\3DEN\Data\Controls\ctrlDefault\arrowEmpty_ca.paa";
    };
};
class PVAR(ctrlList): RscListBox {
    colorBackground[] = {0, 0, 0, 0.3};
    class ListScrollBar: ListScrollBar {
        arrowEmpty = "\a3\3DEN\Data\Controls\ctrlDefault\arrowEmpty_ca.paa";
        arrowFull = "\a3\3DEN\Data\Controls\ctrlDefault\arrowFull_ca.paa";
        border = "\a3\3DEN\Data\Controls\ctrlDefault\border_ca.paa";
        thumb = "\a3\3DEN\Data\Controls\ctrlDefault\thumb_ca.paa";
    };
};
class PVAR(ctrlEdit): RscEdit {
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0.2};
};
class PVAR(ctrlCheckbox): RscCheckBox {};
class PVAR(ctrlSlider): ctrlXSliderH {};
class PVAR(ctrlToolbox): ctrlToolbox {
    // Rows and columns are set by script before the toolbox is created (see PFUNC(ui_dialogToolbox))
    rows = QPVAR(toolboxRows);
    columns = QPVAR(toolboxColumns);
};

class PVAR(ctrlButtonOK): RscButtonMenuOK {
    idc = -1;
};
class PVAR(ctrlButtonCancel): RscButtonMenuCancel {
    idc = -1;
};
