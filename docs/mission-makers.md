# ZEIC for mission makers

**For you if** you build missions in Eden and want furnished, garrisoned buildings without placing every chair by hand.

**You need:** ZEIC loaded while you edit. Your players, and the server, don't need it to play the mission.

## Summary

The ZEIC modules work in Eden the same way they do in Zeus: place one on a building or a town, choose a few options, and ZEIC furnishes or garrisons the buildings. In Eden, the result is ordinary Eden objects, units and triggers, sorted into layers. They are saved into your mission like anything you placed yourself, so the finished mission has **no dependency on ZEIC**.

## Step by step

1. In Eden, open **Systems → Modules** (F5) and find the category **ZEIC - Interiors**.
2. Pick the module. They are the same as in Zeus:

   | Module | Does |
   |---|---|
   | **Interior Fill** | furnishes buildings from the templates of the ticked categories (Military, Civilian, CBRN, ...) |
   | **Garrison Building** | puts infantry of a faction on the building positions |
   | **Advanced Fill** | both in one go: per building the furniture first, then the units |
   | **Fill Table / Shelf** | puts small objects on one table, shelf or rack |
   | **Object Switch** | swaps sandbags, H-barriers, camo nets and the like for another camouflage set |

3. Place it on a building. The module itself is deleted again right away: it only opens the dialog.
4. In the dialog, set **Radius [m]** (`0` = only this building) and **Percentage** (the share of the buildings in the radius), then the module's own options. Hover over a field for its tooltip.
5. Confirm. ZEIC works through the buildings a few per frame, so Eden stays responsive on large areas.
6. Check the result, and adjust by hand where you want: everything ZEIC placed can be moved, edited or deleted like your own objects.
7. Save the mission.

The [shortcuts](zeus.md#shortcuts) work in Eden too: hold Alt while placing to reuse the last settings, Ctrl / Shift / Ctrl+Shift for a Military / Civilian / CBRN fill.

## Things worth knowing

### Layers
Everything ZEIC places goes into its own Eden layers, numbered in the order of your fills:

```
ZEIC Interiors          Interior Fill
  001 - Military        one layer per fill
    001 - House (Large) one layer per building
ZEIC Garrisons          Garrison Building, one layer per faction
ZEIC Advanced Fill      Advanced Fill
```

Don't like a fill? Delete its layer and run the module again. Hide a layer to see the empty building.

### Mission size and performance
- Every furnished building adds dozens of objects to the mission. A whole town adds thousands. Use **Percentage** to furnish only some of the buildings, and the **Simple** object mode where nobody needs to interact with the furniture.
- Garrisons are real Eden units. A big garrison makes the mission slower to load and to play. The dialog shows an estimate, and ZEIC asks before it creates more than 400 units.

### Garrisons and the Move AI trigger
- With **Move AI** on, each garrisoned building gets a trigger. The units hold their positions until an enemy player comes close, then about a fifth of them may move, and after 30 to 120 seconds all of them. The trigger deletes itself afterwards.
- The trigger code is plain vanilla script, so it works without ZEIC too.

### Buildings without a template
Not every building has an interior yet. The chat message after a fill tells you how many buildings were skipped, and the RPT lists them. For those, you can:
- try another category,
- furnish them by hand,
- or make your own template: [Your own templates](custom-templates.md).

### Mods
Buildings of CUP Terrains, Global Mobilization, S.O.G. Prairie Fire, Western Sahara and OPTRE have their own templates, which only load with that mod. A template that uses a mod object is only used when that mod is loaded, so ZEIC never places something that doesn't exist. Objects ZEIC placed from a mod do make your mission depend on that mod, the same as any mod object you place yourself.

### Advanced Fill presets
Your own Advanced Fill presets are saved in your profile and work in every mission. To give your Zeus players presets for your mission, add them to your `description.ext` as `class CfgZEIC_Presets`: they show up in the preset list as *(read-only)*. Every setting is optional, see [the config reference](config-schema.md#13-advanced-fill-presets-cfgzeic_presets):

```cpp
class CfgZEIC_Presets {
    class fortifiedFarmhouse {
        displayName = "Fortified farmhouse";
        categories[] = {"mil"};
        modifiers[] = {"defencesOnly"};
        faction = "OPF_F";
        subcategory = "EdSubcat_Personnel";
        radius = 50;
    };
};
```

## When it doesn't work

The messages are the same as in Zeus, see [the Zeus guide](zeus.md#when-it-doesnt-work). In Eden in particular:

- **A change to your `description.ext` doesn't show up:** ZEIC reads the mission's categories and templates once per mission. Save, then reopen the mission (or start a preview), and check the RPT for config errors.
- **Furniture floating after the building was destroyed:** leave **Allow damage** off (the default), then ZEIC makes the furnished building indestructible.

## Going further

- Every field of every module: [Module reference](modules.md)
- Use your own layouts for a building: [Your own templates](custom-templates.md)
- Running the mission live as Zeus: [Zeus guide](zeus.md)
