#define COMPONENT core


// This is being used for the Addon's Name and can be "My Addon Template Framework"
#define COMPONENT_BEAUTIFIED Core


#include "\zrn\ZEIC\addons\main\script_mod.hpp"
#include "\zrn\ZEIC\addons\main\script_macros.hpp"


// Processing queue: default time budget per frame, in seconds
#define QUEUE_BUDGET_CLIENT 0.0015
#define QUEUE_BUDGET_SERVER 0.0005

// Interior Fill: how objects are created (index in the dialog's "Objects" list)
#define OBJECT_MODE_SIMPLE 0
#define OBJECT_MODE_NORMAL 1
#define OBJECT_MODE_EDITABLE 2

// Dialogs: one unit is 1 % of the screen height (UI_GH), UI_GW is the same length horizontally.
// Colours set by script; the config ones are in ui\controls.hpp, keep both in sync.
#define UI_GH (safeZoneH / 100)
#define UI_GW (safeZoneH / 100 * pixelW / pixelH)
#define UI_TEX(var1) QUOTE(\MAINPREFIX\PREFIX\addons\COMPONENT\ui\data\var1.paa)
#define UI_C_WINDOW [0.04, 0.045, 0.055, 0.88]
#define UI_C_FIELD [1, 1, 1, 0.06]
#define UI_C_FIELD_HOVER [1, 1, 1, 0.1]
#define UI_C_RAISED [1, 1, 1, 0.15]
#define UI_C_LINE [1, 1, 1, 0.07]
#define UI_C_TEXT [0.925, 0.933, 0.949, 1]
#define UI_C_TEXT2 [0.639, 0.675, 0.725, 1]
#define UI_C_MUTED [0.412, 0.443, 0.494, 1]
#define UI_C_ACCENT [0.961, 0.647, 0.141, 1]
#define UI_C_ACCENT_HOVER [1, 0.733, 0.29, 1]
#define UI_C_ACCENT_SOFT [0.961, 0.647, 0.141, 0.22]
#define UI_C_ACCENT_SOFT_HOVER [0.961, 0.647, 0.141, 0.32]
#define UI_C_ON_ACCENT [0.086, 0.094, 0.114, 1]

// Progress feedback states (index into FEEDBACK_COLORS / FEEDBACK_WIDTHS)
#define FEEDBACK_QUEUED 0
#define FEEDBACK_PROCESSING 1
#define FEEDBACK_DONE 2
#define FEEDBACK_NONE 3
#define FEEDBACK_COLORS [[1,1,0,1], [0,1,1,1], [0,1,0,1], [1,0,0,1]]
#define FEEDBACK_WIDTHS [8, 16, 8, 8]
// Above this many buildings, no wireframes are drawn (summary message only)
#define FEEDBACK_MAX 1000
// Seconds the green/red result stays visible after a fill has finished
#define FEEDBACK_LINGER 5
