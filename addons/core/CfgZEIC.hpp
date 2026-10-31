// Interior Fill categories. Every subclass of CfgZEIC is a category; template addons add buildings to them,
// and other mods or missions can add categories of their own. See docs/config-schema.md.
class CfgZEIC {
    class mil {
        displayName = "Military";
        order = 10;
    };
    class civ {
        displayName = "Civilian";
        order = 20;
    };
    class cbrn {
        displayName = "CBRN";
        order = 30;
    };
};
