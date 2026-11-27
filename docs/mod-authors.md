# ZEIC for mod authors

**For you if** you make a terrain, a building pack or an object mod, and want ZEIC to furnish your buildings, or to use your objects, whenever both mods are loaded.

**You need:** the [template basics](custom-templates.md), and a mod built with HEMTT, Addon Builder or similar.

## Summary

ZEIC reads all its templates and object lists from config. Your mod can add to them from a small extra addon, built the same way as ZEIC's own packs for CUP, GM, S.O.G., Western Sahara and OPTRE. With `skipWhenMissingDependencies`, that addon only loads when ZEIC is loaded too. So **your mod doesn't depend on ZEIC**, and ZEIC doesn't need to know about your mod.

## Step by step

1. **Make the templates** for your buildings with Save Building Scheme, as in [Your own templates](custom-templates.md#step-by-step).
2. **Add an addon** to your mod, for example `addons/zeic/`, with this `config.cpp`:

   ```cpp
   class CfgPatches {
       class abc_zeic {
           name = "ABC - ZEIC templates";
           author = "You";
           requiredVersion = 2.02;
           requiredAddons[] = {
               "ZEIC_core",     // ZEIC
               "abc_buildings"  // the addon of yours that defines the buildings
           };
           skipWhenMissingDependencies = 1;  // without ZEIC (or your buildings), Arma skips this addon
           units[] = {};
           weapons[] = {};
       };
   };

   class CfgZEIC {
       class mil {                        // adds to ZEIC's Military category
           class abc_house_01 {           // your building class
               class abc_1 { objects[] = { /* pasted from Save Building Scheme */ }; };
               class abc_2 { objects[] = { /* ... */ }; };
           };
       };
       class civ {
           class abc_house_01 {
               class abc_1 { objects[] = { /* ... */ }; };
           };
       };
   };
   ```

3. **Prefix your template classes with your tag** (`abc_1`, `abc_storage`). Two addons that use the same template name under the same building merge silently, and the one loaded later replaces the other.
4. **Build and test** with ZEIC loaded, then once without it. Without ZEIC, the RPT should only say the addon was skipped.
5. **Check the coverage** on the VR map with **ZEIC - Interiors Development → List Buildings**. It lines up the buildings with few or no templates, and coloured arrows show the template count per category.

## Things worth knowing

### Building variants
Colour variants or `_V1` / `_V2` versions of a building with the same layout don't need copies. Inherit instead:

```cpp
class abc_house_01_V1 { class abc_1 { objects[] = { /* ... */ }; }; };
class abc_house_01_V2: abc_house_01_V1 {};   // same templates, can still add its own
```

### Buildings without building positions
Bunkers, towers or ruins without building positions are accepted by Interior Fill as soon as they have a template in the category. Nothing else is needed. Garrison Building still needs building positions.

### Your own category
A mod can add a category, for example for a specific era or faction:

```cpp
class CfgZEIC {
    class abc_wwii {
        displayName = "WWII";
        order = 40;          // Military, Civilian and CBRN are 10, 20 and 30
    };
};
```

Give it a `displayName` that makes clear where it comes from, the dialog shows only that name. Leave `shortcut` empty unless you are sure: Ctrl, Shift and Ctrl+Shift are taken by ZEIC, and on a clash the category with the lower `order` wins.

### Objects from other mods
A template's real dependencies are the building **and every object in it**. If your templates use objects from a third mod, put that mod's addon in `requiredAddons` too, or move those templates into an extra addon that requires it. Templates with missing objects are skipped at runtime anyway, with a line in the RPT, but the RPT stays cleaner when they never load.

### More than templates
The same addon can extend ZEIC's other lists with your objects:

| Class | Adds |
|---|---|
| `CfgZEIC_Variants` | groups of interchangeable objects: any object of a group may be replaced by a random member, so rooms don't all look the same |
| `CfgZEIC_ObjectSwitch` | a camouflage set for Object Switch, or your objects in the existing sets |
| `CfgZEIC_ObjectFill` | objects for a Fill Table / Shelf type, and shelf heights for your furniture |
| `CfgZEIC_Modifiers` | your objects in a fill modifier (for example your sandbags in *Military defences only*), or a modifier of your own |

ZEIC's packs show each of them in use: `addons/templates_gm/` has variants, object fill and modifiers, `addons/templates_cup/` has an Object Switch set. The formats are in the [config reference](config-schema.md).

## When it doesn't work

| Problem | Check |
|---|---|
| Your templates are never used | Is your addon loaded? Look for its `CfgPatches` class in the config viewer. Is the building class spelled exactly like in `CfgVehicles`? |
| ZEIC says *no template for X* | The category name is wrong (`mil`, not `military`), or the building class doesn't match. |
| Some templates are skipped | The RPT lists each skipped template with the object class that doesn't exist. |
| Your addon loads without ZEIC | `skipWhenMissingDependencies = 1` is missing, or `ZEIC_core` isn't in `requiredAddons`. |

## Contributing instead

Would you rather have your templates in ZEIC itself? For terrains that many people use, that's welcome: send them as a pull request, see [Contributing](../CONTRIBUTING.md#templates).
