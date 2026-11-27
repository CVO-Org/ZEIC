# Your own templates

**For you if** you want ZEIC to furnish a building with your own layout, in your own missions, in Eden or in Zeus.

**You need:** the [mission maker basics](mission-makers.md), Eden with the VR map, and a text editor for `description.ext`.

## Summary

You furnish a building once by hand in Eden. The **Save Building Scheme** module copies that layout to your clipboard as a ready-made template. You paste it into your mission's `description.ext`, and from then on Interior Fill and Advanced Fill can use it for every building of that type in that mission, in Eden and in Zeus.

## Step by step

1. **Open the VR map in Eden** and place the building you want to furnish. Leave it **level and unrotated**.
   On a normal map, trees, fences and other map objects around the building end up in the copy, and a tilted building gives wrong positions. ZEIC warns you about both.
2. **Mark the building positions (optional).** Place **ZEIC - Interiors Development → Mark Positions** on the building. Arrows show where garrisoned units will stand. Keep those spots free, or the units end up inside your furniture. The arrows are not saved with the template.
3. **Furnish the building.** Place objects inside and around it, as you want them to appear. Mod objects work too, see [Mods](#mods).
4. **Save it.** Place **ZEIC - Interiors Development → Save Building Scheme** by clicking **on the building**. ZEIC copies everything within the building's size plus 5 m to the clipboard, and writes it to the RPT as a backup. The chat confirms how many objects were saved.
5. **Paste it into `description.ext`** of your mission, inside a category:

   ```cpp
   class CfgZEIC {
       class civ {                                   // mil, civ, cbrn or your own category
           // ---- pasted from the clipboard ----
           class Land_i_House_Small_03_V1_F {        // the building
               class saved_20261127_143012 {         // the template, named after the time you saved it
                   objects[] = {
                       {"Land_TableDesk_F", {1.250, -0.875, 0.112}, 90},
                       {"Land_ChairWood_F", {1.750, -1.500, 0.112}, 270}
                   };
               };
           };
           // ---- end of paste ----
       };
   };
   ```

6. **Reload the mission** (save, then reopen it, or start a preview). ZEIC reads `description.ext` once per mission.
7. **Use it:** place Interior Fill or Advanced Fill on that building type and tick the category.

## Things worth knowing

### Your templates join the built-in ones
In `mil`, `civ` or `cbrn`, your template is **added** to the templates ZEIC already has for that building. ZEIC takes them in turn, so neighbouring houses get different layouts.

**To get only your layouts, use your own category.** It shows up in the dialog next to the built-in ones and contains nothing but your templates:

```cpp
class CfgZEIC {
    class my_ops {
        displayName = "My Ops";
        tooltip = "Layouts for our campaign";   // optional
        order = 50;                             // optional: position in the list, built-in ones are 10-30
        // shortcut = "ctrl";                   // optional: Ctrl, Shift and Ctrl+Shift are taken by ZEIC
        class Land_i_House_Small_03_V1_F {
            class saved_20261127_143012 { objects[] = { /* ... */ }; };
        };
    };
};
```

### Several layouts for one building
Save the building again with a different layout and paste the new template class next to the first one, inside the same building class. Every save gets its own timestamp name, so they don't clash. Template names only need to be unique within their building.

### Buildings without building positions
Bunkers, towers and some ruins have no building positions, so Save Building Scheme doesn't accept them at first. **Hold Alt while placing the module** to save them anyway. Once a building has a template in a category, Interior Fill accepts it for that category.

### Mods
- If your layout uses objects from mods, the copied text starts with a note such as `// Uses objects from: CUP Terrains - Core`. It's only a note for you: ZEIC doesn't check it, and it doesn't cover the building itself.
- When the mission runs without one of those mods, ZEIC skips the whole template, writes the missing class to the RPT, and uses the other templates. It never places half a layout.

### The mission doesn't depend on ZEIC
Without ZEIC loaded, Arma ignores `class CfgZEIC`. Furniture already placed in Eden stays, as with any mission made with ZEIC.

### Multiplayer
In Zeus, the server furnishes the buildings and reads the templates from `description.ext`. Nothing extra is needed: the server has the mission file anyway.

## Reusing templates across missions

Keep your templates in one file, for example `zeic_templates.hpp`:

```cpp
// zeic_templates.hpp
class CfgZEIC {
    class my_ops {
        displayName = "My Ops";
        // ... your buildings and templates
    };
};
```

Copy it into each mission folder and include it from `description.ext`:

```cpp
#include "zeic_templates.hpp"
```

If you want your templates in every mission without copying, put them in a small addon of your own: [Mod author guide](mod-authors.md). Or share them with everyone, see [Sharing a template](#sharing-a-template).

## Adding templates by script

For templates that change while the mission runs, there is a script function. Call it on every machine that furnishes buildings (in multiplayer: the server and every Zeus), for example in `init.sqf`:

```sqf
// _data: the text from Save Building Scheme, or [buildingClass, template] / [buildingClass, [template, ...]]
["civ", _data] call ZEIC_fnc_addCustomTemplate;
```

A template in this form is a list of `["ObjectClass", [x, y, z], direction]` entries, optionally with `[rotX, rotY, rotZ]` at the end. The function returns `true` on success and reports errors in chat and the RPT. The old ZEI format `"Class: [...]"` still works.

For everything else, `description.ext` is simpler.

## When it doesn't work

| Message or problem | Meaning |
|---|---|
| *place the module over a building* | The module wasn't placed on an object. Click directly on the building. |
| *no valid building found* | The building has no positions. Hold Alt while placing to save it anyway. |
| *the building is not level* | Rotate the building back to flat and save again, or the positions will be off. |
| *not in the VR world* | Saving works, but map objects around the building may be in the copy. Check the text before you paste it. |
| Your template is never used | Reload the mission. Check the category name, and the RPT for a missing object class or a config error. A template only applies to its exact building class: a `_V2` colour variant of the same house needs its own entry. |

## Sharing a template

Templates for buildings ZEIC doesn't cover yet are the most welcome contribution. Post the copied text in the [Workshop discussions](https://steamcommunity.com/workshop/filedetails/discussions/3567067667/), or send a pull request, see [Contributing](../CONTRIBUTING.md#templates).

## Reference

All properties of `CfgZEIC`, and of the other classes ZEIC reads, are in the [config reference](config-schema.md).
