// Controls of the ZEIC dialogs: dark cards, one amber accent (style "A", see #25).
// They are placed by script (PFUNC(ui_dialogCreate) and friends), so they only define the look.
#define C_PANEL {0.078, 0.078, 0.086, 0.94}
#define C_FOOTER {0.106, 0.106, 0.102, 0.97}
#define C_LINE {0.227, 0.227, 0.22, 1}
#define C_FIELD {0.137, 0.137, 0.129, 1}
#define C_FIELD_ON {0.227, 0.227, 0.22, 1}
#define C_TEXT {0.945, 0.937, 0.91, 1}
#define C_MUTED {0.706, 0.698, 0.663, 1}
#define C_DIM {0.533, 0.529, 0.502, 1}
#define C_ACCENT {0.937, 0.624, 0.153, 1}
#define C_ACCENT_HOVER {0.973, 0.71, 0.33, 1}
#define C_ON_ACCENT {0.255, 0.141, 0.008, 1}
#define C_CLEAR {0, 0, 0, 0}

#define SIZE_TITLE "pixelH * pixelGrid * 1.3"
#define SIZE_TEXT "pixelH * pixelGrid * 1.05"
#define SIZE_SMALL "pixelH * pixelGrid * 0.9"

class RscXSliderH;

class PVAR(ctrlBackground): RscText {
    text = "";
    colorBackground[] = C_PANEL;
};
class PVAR(ctrlFooter): PVAR(ctrlBackground) {
    colorBackground[] = C_FOOTER;
};
class PVAR(ctrlLine): PVAR(ctrlBackground) {
    colorBackground[] = C_LINE;
};
class PVAR(ctrlAccentLine): PVAR(ctrlBackground) {
    colorBackground[] = C_ACCENT;
};

class PVAR(ctrlText): RscText {
    font = "RobotoCondensed";
    sizeEx = SIZE_TEXT;
    shadow = 0;
    colorText[] = C_TEXT;
    colorBackground[] = C_CLEAR;
};
class PVAR(ctrlTitle): PVAR(ctrlText) {
    font = "RobotoCondensedBold";
    sizeEx = SIZE_TITLE;
};
class PVAR(ctrlSubtitle): PVAR(ctrlText) {
    colorText[] = C_MUTED;
};
class PVAR(ctrlLabel): PVAR(ctrlText) {
    font = "RobotoCondensedBold";
    sizeEx = SIZE_SMALL;
    colorText[] = C_MUTED;
};
class PVAR(ctrlValue): PVAR(ctrlText) {
    style = 1; // right
};
class PVAR(ctrlHint): PVAR(ctrlText) {
    sizeEx = SIZE_SMALL;
    colorText[] = C_DIM;
};

class PVAR(ctrlSegment): RscButton {
    style = 2; // centered
    font = "RobotoCondensed";
    sizeEx = SIZE_TEXT;
    shadow = 0;
    borderSize = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    colorText[] = C_MUTED;
    colorDisabled[] = C_DIM;
    colorBackground[] = C_FIELD;
    colorBackgroundActive[] = C_FIELD_ON;
    colorBackgroundDisabled[] = C_FIELD;
    colorFocused[] = C_FIELD;
    colorShadow[] = C_CLEAR;
    colorBorder[] = C_CLEAR;
};
class PVAR(ctrlButton): PVAR(ctrlSegment) {
    colorText[] = C_TEXT;
    colorBackground[] = C_FIELD_ON;
    colorFocused[] = C_FIELD_ON;
    colorBackgroundActive[] = C_LINE;
};
class PVAR(ctrlButtonPrimary): PVAR(ctrlSegment) {
    font = "RobotoCondensedBold";
    colorText[] = C_ON_ACCENT;
    colorBackground[] = C_ACCENT;
    colorFocused[] = C_ACCENT;
    colorBackgroundActive[] = C_ACCENT_HOVER;
};

class PVAR(ctrlSlider): RscXSliderH {
    color[] = C_ACCENT;
    colorActive[] = C_ACCENT_HOVER;
    colorDisabled[] = C_DIM;
};
class PVAR(ctrlCheckbox): RscCheckBox {
    color[] = C_MUTED;
    colorFocused[] = C_TEXT;
    colorHover[] = C_TEXT;
    colorPressed[] = C_ACCENT;
    colorDisabled[] = C_DIM;
    colorBackground[] = C_CLEAR;
    colorBackgroundFocused[] = C_CLEAR;
    colorBackgroundHover[] = C_CLEAR;
    colorBackgroundPressed[] = C_CLEAR;
    colorBackgroundDisabled[] = C_CLEAR;
};
