// Base classes of the older dialogs (Garrison, Object Fill, Object Switch, List Buildings).
// They used to be full copies of the vanilla controls; inheriting gives the same result.
class RscText;
class RscButton;
class RscCombo {
    class ComboScrollBar;
};
class RscSlider;
class RscFrame;
class IGUIBack;
class RscCheckBox;

class PVAR(RscText): RscText {};
class PVAR(RscButton): RscButton {};
class PVAR(RscCombo): RscCombo {};
class PVAR(RscSlider): RscSlider {};
class PVAR(RscFrame): RscFrame {};
class PVAR(IGUIBack): IGUIBack {};
class PVAR(RscCheckBox): RscCheckBox {};
