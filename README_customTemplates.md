## How to add custom Templates to your mission

### In `description.ext` (recommended)

Missions use the same config format as the template addons (see `docs/config-schema.md`). Templates are added to the built-in ones for that building, and a mission can also define categories of its own:

```cpp
class CfgZEIC {
    class mil {
        class Land_i_House_Small_03_V1_F {
            class mission_1 { objects[] = { {"Land_Pallets_F", {0, 0, 0.5}, 90} }; };
        };
    };
    class my_category {
        displayName = "My Category";
        class Land_i_House_Small_03_V1_F {
            class mission_1 { objects[] = { {"Land_Sack_F", {0, 0, 0.5}, 0} }; };
        };
    };
};
```

An object entry is `{"ObjectClass", {x, y, z}, direction}` or `{"ObjectClass", {x, y, z}, direction, {rotX, rotY, rotZ}}`, with positions relative to the building. Templates with an object class that doesn't exist are skipped (listed in the RPT).

### By script

```sqf
[_category, _data] call ZEIC_fnc_addCustomTemplate;
```

`_category` is the Interior Fill category the template belongs to, e.g. `"mil"`, `"civ"` or `"cbrn"`.

`_data` is one of:
- the full string the **Save Building Scheme** module puts in your clipboard (`case "Class": { [...] };`)
- the legacy format `"Class: [...]"`
- an array: `[buildingClass, template]` or `[buildingClass, [template, ...]]`

A template is a list of objects: `["ObjectClass", [x, y, z], direction]` or `["ObjectClass", [x, y, z], direction, [rotX, rotY, rotZ]]`, with positions relative to the building.

The function returns `true` on success. Errors (unknown building class, no template data) are shown in chat and written to the RPT.

Custom templates are added to the built-in ones for that building. Call the function on every machine that places interiors, e.g. in `init.sqf`.
