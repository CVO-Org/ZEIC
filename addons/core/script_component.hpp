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

// Dialogs: grid unit (scales with the UI size setting) and the colours set by script, see ui\controls.hpp
#define UI_GW (pixelW * pixelGrid * 0.5)
#define UI_GH (pixelH * pixelGrid * 0.5)
#define UI_COLOR_FIELD [0.137, 0.137, 0.129, 1]
#define UI_COLOR_FIELD_ON [0.227, 0.227, 0.22, 1]
#define UI_COLOR_TEXT [0.945, 0.937, 0.91, 1]
#define UI_COLOR_MUTED [0.706, 0.698, 0.663, 1]

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
