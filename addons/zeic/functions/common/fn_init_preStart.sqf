#include "../../script_component.hpp"

// cDLCs
uiNamespace setVariable [ QPVAR(isLoaded_sog),   isClass (configFile >> "CfgPatches" >> "data_f_vietnam") ];
uiNamespace setVariable [ QPVAR(isLoaded_ws),    isClass (configFile >> "CfgPatches" >> "data_f_lxWS_Loadorder") ];
uiNamespace setVariable [ QPVAR(isLoaded_gm),    isClass (configFile >> "CfgPatches" >> "gm_core") ];
// Mods
uiNamespace setVariable [ QPVAR(isLoaded_cup),   isClass (configFile >> "CfgPatches" >> "CUP_Editor_Buildings_Config") ];
uiNamespace setVariable [ QPVAR(isLoaded_optre), isClass (configFile >> "CfgPatches" >> "OPTRE_Core") ];
