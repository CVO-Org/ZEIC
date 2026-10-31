#define COMPONENT core


// This is being used for the Addon's Name and can be "My Addon Template Framework"
#define COMPONENT_BEAUTIFIED Core


#include "\zrn\ZEIC\addons\main\script_mod.hpp"
#include "\zrn\ZEIC\addons\main\script_macros.hpp"


// Processing queue: default time budget per frame, in seconds
#define QUEUE_BUDGET_CLIENT 0.003
#define QUEUE_BUDGET_SERVER 0.001

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
