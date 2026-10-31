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

// Dialogs: sizes in units of the vanilla GUI grid (the same as defineCommonGrids.inc), like ZEN's dialogs.
// They follow the interface size setting.
#define UI_GRID_W (((safeZoneW / safeZoneH) min 1.2) / 40)
#define UI_GRID_H ((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25)
#define UI_W(N) ((N) * UI_GRID_W)
#define UI_H(N) ((N) * UI_GRID_H)

// Self test (functions\dev): the building most tests fill
#define DEV_HOUSE "Land_i_House_Small_03_V1_F"

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
