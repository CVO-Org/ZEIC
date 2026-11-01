#define COMPONENT core


// This is being used for the Addon's Name and can be "My Addon Template Framework"
#define COMPONENT_BEAUTIFIED Core


#include "\zrn\ZEIC\addons\main\script_mod.hpp"
#include "\zrn\ZEIC\addons\main\script_macros.hpp"


// Processing queue: default time budget per frame, in seconds
#define QUEUE_BUDGET_CLIENT 0.0015
#define QUEUE_BUDGET_SERVER 0.0005
// Buildings are processed in rows of this height (meters), north to south, east to west within a row
#define QUEUE_ROW_SIZE 25

// Advanced Fill: seconds a building's garrison waits for its interior before it goes on without it
#define ADVANCED_FILL_WAIT 120

// Advanced Fill collision check: what happens to building positions blocked by a fill object (index in the dialog's list)
#define COLLISION_OFF -1
#define COLLISION_UNITS_GIVE_WAY 0
#define COLLISION_FURNITURE_GIVES_WAY 1
// A position is blocked by an object whose bounding box is closer than this horizontally (meters, about a unit's half width)
#define COLLISION_RADIUS 0.35
// ...and reaches into this height band above the position's floor (meters): rugs below, lamps above don't count
#define COLLISION_HEIGHT [0.15, 1.7]

// Garrison Building and Advanced Fill ask before creating more units than this
#define GARRISON_CONFIRM_UNITS 400

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
// Side icons by config side number (0 OPFOR, 1 BLUFOR, 2 Independent, 3 Civilian), as in Eden's asset browser
#define SIDE_ICONS [\
    "\a3\3DEN\Data\Displays\Display3DEN\PanelRight\side_east_ca.paa",\
    "\a3\3DEN\Data\Displays\Display3DEN\PanelRight\side_west_ca.paa",\
    "\a3\3DEN\Data\Displays\Display3DEN\PanelRight\side_guer_ca.paa",\
    "\a3\3DEN\Data\Displays\Display3DEN\PanelRight\side_civ_ca.paa"\
]
// Gap between rows and between the dialog's bars: a tenth of a row, in whole screen pixels. PFUNC(ui_dialogFinish)
// snaps all edges to pixels, so every gap ends up exactly this wide.
#define UI_GAP (((round (UI_H(0.1) / pixelH)) max 1) * pixelH)

// Radius preview of the dialogs' radius sliders (see PFUNC(ui_radiusPreview))
// Alternating blue and white dashes on a wider dark line, so it shows on any ground
#define RADIUS_PREVIEW_COLORS [[0.15, 0.5, 1, 1], [1, 1, 1, 1]]
#define RADIUS_PREVIEW_WIDTH 10
#define RADIUS_PREVIEW_OUTLINE_COLOR [0, 0, 0, 0.7]
#define RADIUS_PREVIEW_OUTLINE_WIDTH 20

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
