// Controls of the ZEIC dialogs: dark glass with light films on it, one amber accent, rounded corners
// (style "A", design inspired by Enhanced First Aid Kits by MissHeda, with permission).
// The dialogs are placed and coloured by script (functions\ui), these classes only define the look.
// Colours set by script are in script_component.hpp (UI_C_*), keep both in sync.
#define C_CLEAR {0, 0, 0, 0}
#define C_FIELD {1, 1, 1, 0.06}
#define C_TEXT {0.925, 0.933, 0.949, 1}
#define C_TEXT2 {0.639, 0.675, 0.725, 1}
#define C_MUTED {0.412, 0.443, 0.494, 1}
#define C_ACCENT {0.961, 0.647, 0.141, 1}

// Text sizes, relative to the screen height like the rest of the dialog
#define SIZE_TITLE "safeZoneH * 0.027"
#define SIZE_TEXT "safeZoneH * 0.021"
#define SIZE_SMALL "safeZoneH * 0.017"

class RscPicture;

// Pieces of rounded panels (see PFUNC(ui_dialogPanel))
class PVAR(ctrlRect): RscText {
    text = "";
    shadow = 0;
    colorBackground[] = C_FIELD;
};
class PVAR(ctrlCorner): RscPicture {
    text = "";
    shadow = 0;
    colorText[] = C_FIELD;
    colorBackground[] = C_CLEAR;
};

class PVAR(ctrlText): RscText {
    font = "RobotoCondensed";
    sizeEx = SIZE_TEXT;
    shadow = 0;
    colorText[] = C_TEXT;
    colorBackground[] = C_CLEAR;
};
class PVAR(ctrlTextCenter): PVAR(ctrlText) {
    style = 2;
};
class PVAR(ctrlTitle): PVAR(ctrlText) {
    font = "RobotoCondensedBold";
    sizeEx = SIZE_TITLE;
};
class PVAR(ctrlSubtitle): PVAR(ctrlText) {
    colorText[] = C_TEXT2;
};
class PVAR(ctrlLabel): PVAR(ctrlText) {
    font = "RobotoCondensedBold";
    sizeEx = SIZE_SMALL;
    colorText[] = C_MUTED;
};
class PVAR(ctrlValue): PVAR(ctrlText) {
    style = 1; // right
    colorText[] = C_ACCENT;
    font = "RobotoCondensedBold";
};
class PVAR(ctrlHint): PVAR(ctrlText) {
    sizeEx = SIZE_SMALL;
    colorText[] = C_MUTED;
};

// Invisible click area over a panel; the panel shows the state (see PFUNC(ui_dialogPaint))
class PVAR(ctrlHit): RscButton {
    text = "";
    borderSize = 0;
    shadow = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    colorText[] = C_CLEAR;
    colorDisabled[] = C_CLEAR;
    colorBackground[] = C_CLEAR;
    colorBackgroundActive[] = C_CLEAR;
    colorBackgroundDisabled[] = C_CLEAR;
    colorFocused[] = C_CLEAR;
    colorShadow[] = C_CLEAR;
    colorBorder[] = C_CLEAR;
};

// Invisible slider over the drawn track (see PFUNC(ui_dialogSlider))
class PVAR(ctrlSliderInput): RscSlider {
    color[] = C_CLEAR;
    colorActive[] = C_CLEAR;
    colorDisabled[] = C_CLEAR;
};
