#include "..\..\script_component.hpp"

// Without ZEN, Zeus lists the ZEIC modules by itself whenever the curator allows the ZEIC_core addon
// (e.g. Game Master "Addons: All addons including unofficial ones").

// With ZEN, register the modules in ZEN's module list. Only on clients that aren't the server (to avoid duplicate modules in the curator list).
// This is to prevent a bug where all other ZEN modules that were added per script would be in the wrong categories and mixed up; Bug doesn't happen if the client is the server
if (hasInterface && {!isServer} && {isClass (configFile >> "CfgPatches" >> "zen_common")}) then {
    [LLSTRING(Category), LLSTRING(Module_GarrisonBuilding), {
        params ["_pos"];

        // Give a temp object, because objNull is not local (because of "ZEIC_fnc_mod_garrisonBuilding" requirement)
        private _temp = "Module_F" createVehicleLocal _pos;

        ["init", [_temp, true, true]] call PFUNC(mod_garrisonBuilding);

        deleteVehicle _temp;
    }, "\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa"] call zen_custom_modules_fnc_register;

    [LLSTRING(Category), LLSTRING(Module_ObjectFill), {
        params ["_pos"];

        // Give a temp object, because objNull is not local (because of "ZEIC_fnc_mod_objectFill" requirement)
        private _temp = "Module_F" createVehicleLocal _pos;

        ["init", [_temp, true, true]] call PFUNC(mod_objectFill);

        deleteVehicle _temp;
    }, "\A3\ui_f\data\igui\cfg\simpleTasks\types\box_ca.paa"] call zen_custom_modules_fnc_register;

    [LLSTRING(Category), LLSTRING(Module_ObjectSwitch), {
        params ["_pos"];

        // Give a temp object, because objNull is not local (because of "ZEIC_fnc_mod_objectSwitch" requirement)
        private _temp = "Module_F" createVehicleLocal _pos;

        ["init", [_temp, true, true]] call PFUNC(mod_objectSwitch);

        deleteVehicle _temp;
    }, "\A3\Modules_f\data\portraitRespawn_ca.paa"] call zen_custom_modules_fnc_register;

    [LLSTRING(Category), LLSTRING(Module_InteriorFill), {
        params ["_pos"];

        // Give a temp object, because objNull is not local (because of "ZEIC_fnc_mod_interiorFill" requirement)
        private _temp = "Module_F" createVehicleLocal _pos;

        ["init", [_temp, true, true]] call PFUNC(mod_interiorFill);

        deleteVehicle _temp;
    }, "\A3\modules_f\data\portraitModule_ca.paa"] call zen_custom_modules_fnc_register;
};

// Modifier keys for the module shortcuts: the Zeus display is created anew whenever Zeus opens
if (hasInterface) then {
    addMissionEventHandler ["EachFrame", {
        private _display = findDisplay 312;
        if (!isNull _display && {!(_display getVariable [QPVAR(modifiersTracked), false])}) then {
            [_display] call PFUNC(modifiers_install);
        };
    }];
};
