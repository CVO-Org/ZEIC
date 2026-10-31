// Eden: track the modifier keys for the module shortcuts (see PFUNC(modifiers_install)).
// The Eden display stays open, the handlers are added once (any of these events is the first).
class Cfg3DEN {
    class EventHandlers {
        class ADDON {
            onMissionNew = QUOTE([findDisplay 313] call PFUNC(modifiers_install));
            onMissionLoad = QUOTE([findDisplay 313] call PFUNC(modifiers_install));
            onTerrainNew = QUOTE([findDisplay 313] call PFUNC(modifiers_install));
            onMissionPreviewEnd = QUOTE([findDisplay 313] call PFUNC(modifiers_install));
        };
    };
};
