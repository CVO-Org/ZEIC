// Asks before a garrison creates many units. The content is built by PFUNC(ui_garrisonBuilding_confirmUnits_onLoad).
class Rsc_ZEIC_ConfirmUnits {
    idd = 1707;
    movingEnable = 0;
    onLoad = QUOTE(_this call PFUNC(ui_garrisonBuilding_confirmUnits_onLoad));
    controls[] = {};
};
