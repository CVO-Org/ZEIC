# ZEIC Interior Templates – Config Schema (Draft)

Status: **draft for discussion**. Nothing here is implemented yet.

This document describes how interior templates move from the hardcoded `switch` in
`fn_findTemplates.sqf` (+ `addons/core/templates/*.sqf`) into config, and how ZEIC
looks them up at runtime.

## Goals

- Templates are **data, not code**: any addon or mission can add categories and templates.
- Template data is **split into addons per dependency** (vanilla, CUP, GM, SOG, WS, OPTRE, …),
  each loading only when its dependency is present. No more `isLoaded_*` checks.
- **No boot-time cost**: templates are looked up and validated lazily, per building, on first use.
- Only templates that can actually spawn are ever used.

## Non-goals (for this round)

- Template display names or picking a specific template. ZEIC is a quick-fill tool.
- Detail levels (the detail slider and `checkDetailLevel` are removed).
- Era swap tables. Cold War support comes later as dedicated `mil_cw` / `civ_cw` categories.

---

## 1. Root class and categories

Everything lives under one root class, `CfgZEIC`. Each **category** is a direct subclass
with its info as plain properties.

```cpp
class CfgZEIC {
    class mil {
        displayName = "Military";
        tooltip     = "Military furnishing: ammo crates, bunks, sandbags, ...";
        shortcut    = "ctrl";   // "ctrl", "shift", "ctrl+shift" or "" (none); Alt is taken
        order       = 10;       // sort order in the UI, lower first
    };
    class civ {
        displayName = "Civilian";
        shortcut    = "shift";
        order       = 20;
    };
    class cbrn {
        displayName = "CBRN";
        order       = 30;
    };
};
```

| Property | Type | Required | Notes |
|---|---|---|---|
| `displayName` | string | no | Shown in the Interior Fill dialog. Stringtable key (`$STR_...`) allowed. Falls back to the class name. |
| `tooltip` | string | no | |
| `shortcut` | string | no | Modifiers held while placing the module → skip the dialog and fill this category with the last-used settings: `"ctrl"`, `"shift"` or `"ctrl+shift"`. Alt is reserved for "repeat the last fill". ZEIC uses Ctrl for Military, Shift for Civilian, Ctrl+Shift for CBRN. |
| `order` | number | no | Default `100`. Ties sorted by `displayName`. |

**Adding a category** from another addon or mod: declare a new subclass of `CfgZEIC`.
Nothing else is needed. The dialog shows the source mod next to categories that don't come
from ZEIC itself (via `configSourceMod`), e.g. "Military (Cold War) – Some Mod".

No naming convention is required for categories. Two addons using the same category class
simply merge, which is intended: that is how template addons add buildings to `mil`.

**Shortcut conflicts:** if two categories claim the same modifier, the one with the lower `order`
wins, and a warning goes to the RPT.

## 2. Buildings and templates

Inside a category, every **building** is a subclass named exactly like its `CfgVehicles` class.
Inside a building, every **template** is a subclass with an `objects[]` array.

```cpp
class CfgZEIC {
    class mil {
        class Land_cargo_house_slum_F {
            class vanilla_1 {
                objects[] = {
                    {"Newspaper_01_F",       {-1.89697, -1.16846, 0.426499}, 82},
                    {"Land_Slums02_pole",    {-4.64978, -2.75366, 1.028},    360, {180, 0, 180}}
                };
            };
            class vanilla_2 { objects[] = { /* ... */ }; };
        };
    };
};
```

### Object entry

`{className, offset, direction, rotation}`, which is the same order as the current SQF arrays,
so conversion is 1:1.

| Index | Type | Required | Meaning |
|---|---|---|---|
| 0 | string | yes | `CfgVehicles` class of the object |
| 1 | array `{x, y, z}` | yes | Offset in the building's model space (`modelToWorld`) |
| 2 | number | no | Direction relative to the building, default `0` |
| 3 | array `{x, y, z}` | no | Full Eden rotation; if set, used **instead of** `direction` |

### Template class names

- Only need to be **unique within the building class**.
- No display names. The name has no meaning to ZEIC.
- **Convention for third-party addons:** prefix with your tag (`abc_storage`). Two addons
  declaring the same template class under the same building **merge silently**, and the
  later-loaded `objects[]` replaces the other.

### Buildings that share a layout

The current SQF uses fall-through cases (`case "A"; case "B": {...}`) for building variants
with identical interiors (colour variants, `_V1`/`_V2`, …). In config this becomes
**inheritance**:

```cpp
class Land_i_House_Big_02_V1_F { class vanilla_1 { objects[] = { /* ... */ }; }; };
class Land_i_House_Big_02_V2_F: Land_i_House_Big_02_V1_F {};
class Land_i_House_Big_02_V3_F: Land_i_House_Big_02_V1_F {};
```

The child gets all parent templates and can still add its own.

## 3. Template addons (one per dependency)

```
addons/
  main/                 shared: macros, stringtable
  core/                 functions, modules, UI, CfgZEIC category definitions
  templates_vanilla/    requiredAddons: core
  templates_cup/        requiredAddons: core, CUP_Editor_Buildings_Config
  templates_gm/         requiredAddons: core, gm_core
  templates_sog/        requiredAddons: core, data_f_vietnam
  templates_ws/         requiredAddons: core, data_f_lxWS_Loadorder
  templates_optre/      requiredAddons: core, OPTRE_Core
```

Each template addon:

```cpp
class CfgPatches {
    class ZEIC_templates_cup {
        requiredAddons[] = {"ZEIC_core", "CUP_Editor_Buildings_Config"};
        skipWhenMissingDependencies = 1;
        units[] = {};
        weapons[] = {};
    };
};

class CfgZEIC {
    class mil {             // merges into the category defined in addons/core
        class Land_Some_CUP_House { /* ... */ };
    };
};
```

Because the core addon is in `requiredAddons`, the category properties always come from the
core and the template addons only add buildings.

### Which addon does a template go in?

A template's real dependencies are **the building plus every object in it**. It goes in the
addon matching its heaviest dependency:

| Building | Objects | Addon |
|---|---|---|
| vanilla | vanilla | `templates_vanilla` |
| vanilla | some CUP | `templates_cup` |
| CUP | vanilla | `templates_cup` |
| GM | some CUP | needs both → combined addon (`templates_gm_cup`) or drop |

The converter script works this out automatically (see section 7).

## 4. Random object variants

Today `fn_randomiseObject.sqf` rebuilds ~30 hardcoded arrays **for every spawned object**.
In config, every list becomes a **variant group**: any object from a group may be replaced by a
random member of the same group.

Variants live in their **own root class**, `CfgZEIC_Variants`, so that every subclass of
`CfgZEIC` is a category, with no exceptions and no marker property.

```cpp
class CfgZEIC_Variants {
    class gasTanks  { objects[] = {"Land_GasTank_01_blue_F", "Land_GasTank_01_yellow_F", "Land_GasTank_01_khaki_F"}; };
    class sleepBags { objects[] = {"Land_Sleeping_bag_brown_F", "Land_Sleeping_bag_F", "Land_Sleeping_bag_blue_F"}; };
};
```

- Template addons add their own groups (e.g. the SOG addon adds `vn_cots`).
- At first use, all groups are read once into an `object → [members]` HashMap in
  `uiNamespace`. This list is small, so building it in one go is fine. Invalid members are
  dropped, so a group never produces an object that doesn't exist.
- An object in several groups uses the group with the highest `priority` (default 0), otherwise
  the first group found.

## 5. Mission-specific templates

Missions declare the **same schema** in `description.ext`:

```cpp
class CfgZEIC {
    class mil {
        class Land_House_Small_03_F {
            class mission_1 { objects[] = { /* ... */ }; };
        };
    };
};
```

- Mission templates are **added to** the addon templates for that building, not a replacement.
- A mission may also define its own categories.
- Mission data has its own cache in `missionNamespace`, because it differs per mission.
- The Save Building Scheme module outputs **this config syntax** to the clipboard, so a
  saved scheme can be pasted straight into `description.ext` or a template addon.

## 6. Runtime lookup and caching

### Caches

| Cache | Namespace | Key → Value | Built |
|---|---|---|---|
| Class validity | `uiNamespace` | `className` → `bool` (`isClass` in CfgVehicles) | per class, on first check |
| Addon templates | `uiNamespace` | `"category|buildingClass"` → `[validTemplates]` | per building, on first lookup |
| Mission templates | `missionNamespace` | same as above, from `missionConfigFile` | per building, on first lookup |
| Variants | `uiNamespace` | `className` → `[members]` | once, on first use |
| Categories | `uiNamespace` (+ mission) | sorted list of `[class, displayName, shortcut]` | once, on first dialog open |

`uiNamespace` is safe for config-derived data because config cannot change during a game
session. It also survives Eden previews and mission changes.

### Lookup (pseudo-code)

```
getTemplates(category, buildingClass):
    key = category + "|" + buildingClass
    if key in addonCache: addonTemplates = addonCache[key]
    else:
        cfg = configFile >> "CfgZEIC" >> category >> buildingClass
        addonTemplates = configClasses(cfg) → getArray "objects" → keep only templates whose
                         objects all pass the class-validity cache
        log each dropped template once (RPT, with the missing class)
        addonCache[key] = addonTemplates
    same for missionConfigFile → missionCache
    return addonTemplates + missionTemplates
```

- A building is a **candidate** for filling if it has building positions **or** has an entry in
  the selected category. That replaces the `ZEIC_additionalBuildings` list and
  `fn_addCustomHouse`.
- All validation runs **inside the processing queue**, within its per-frame time budget, so a
  first use never causes a hitch.
- **Template selection:** round-robin **per building class** (identical neighbouring houses get
  different layouts), not the current global counter shared by all buildings.

## 7. Migration

1. **Converter script** (`tools/convert_templates.py`) ✅: reads `addons/core/templates/*.sqf`, turns
   each `case` into a building class and each template array into a `class <tag>_<n>`, and maps
   fall-through cases to inheritance. It keeps the SQF `switch` semantics: a building listed twice
   only gets its first entry, template groups that could never match become extra variants.
   For now each source file maps to one addon (`mil_other.sqf` goes into `templates_vanilla`),
   the same split the `isLoaded_*` checks made.
2. **Dependency sorting** (later, optional): run a one-off in-game dump of `className → source addon`
   (`configSourceAddonList`) for every class used in the templates, and move templates whose
   objects need another mod into that mod's addon.
3. **Variants** ✅: the lists from `fn_randomiseObject.sqf` are in `CfgZEIC_Variants` of the vanilla,
   CUP, GM and SOG template addons. GM used to replace the vanilla lists (first with an overwrite,
   then with `priority = 1` groups); the **Cold War era** fill modifier does that now (section 10).
4. **Remove** ✅: `fn_findTemplates` rewritten (config lookup with caches), `fn_templateCanSpawn`, the
   `isLoaded_*` flags and `fn_init_preStart`, the hardcoded category list (now
   `fn_interiorFill_categories`), and `addons/core/templates/`. `fn_checkDetailLevel` and the detail
   level option are removed too. `fn_addCustomHouse` stays as legacy API.
5. **Legacy script API stays** (see section 8).

## 8. Legacy compatibility

Missions written for ZEI / ZEIC keep working:

| Legacy | New behaviour |
|---|---|
| `[_type, _data] call ZEIC_fnc_addCustomTemplate` | Kept. Accepts the old string format **and** a plain array; writes into the mission template cache. Any category name is accepted, not only `mil`/`civ`. Fixes the current mil/civ swap and the `splitString` parsing. |
| `ZEIC_fnc_addCustomHouse` / `ZEIC_additionalBuildings` | Kept as a shim: listed classes are still treated as fill candidates. |
| `ZEIC_SaveRadius`, `ZEIC_DEBUG` | Unchanged. |
| Module classes (`ZEIC_InteriorFill`, …) | Class names unchanged. |

## 9. Multiplayer and locality

| What | Created where | Queue |
|---|---|---|
| Interior objects (Zeus) | **Server**, global | Server-side queue with its own, smaller time budget |
| Interior objects (Eden) | Local (`create3DENEntity`) | Local queue |
| Garrison units | **Zeus client** (stays local to Zeus, like any Zeus-placed unit; ACE HC & co. take over from there) | Client-side queue |
| Feedback (boxes) | Every curator client, local | Drawn from server progress messages, only while that client is in the Zeus camera |

- **One request per fill:** the Zeus client sends a single `remoteExec` to the server with
  `[buildings, category, options]`. The server does lookup, validation and spawning itself, and
  calls `addCuratorEditableObjects` / `enableSimulationGlobal` directly instead of one
  `remoteExec` per object.
- **Progress goes to all Zeuses.** The server sends to the owners of all assigned curators
  (`allCurators` → `getAssignedCuratorUnit` → `owner`). Messages are batched (at most once per
  server frame) and only carry `[building, state]` pairs, a few KB for a whole 300-building
  fill. Each client decides locally whether to draw (`!isNull curatorCamera`), so a Zeus who
  opens the interface mid-fill sees the current state immediately. A Zeus who joins mid-fill
  sees nothing for that fill.
- **No extra security check:** only clients with Zeus access can place the module in the first
  place.
- **`CfgRemoteExec` whitelists are out of scope.**
- If the requesting Zeus disconnects mid-fill, the server finishes the job.

## Open questions

1. **`mil_other.sqf`** contains `Land_blud_hut*` buildings. The source mod is unknown; on the
   maintainer's machine only ZEI/ZEIC reference these classes. Candidates: drop them, or keep
   them in a separate addon with no known dependency (they would simply never validate).
2. ~~**GM's "overwrite" behaviour** in `fn_randomiseObject`~~: replaced by the **Cold War era**
   fill modifier (section 10). GM's variant groups no longer win over the vanilla ones.

## 10. Fill modifiers (`CfgZEIC_Modifiers`)

Optional checkboxes in the **Interior tab of Advanced Fill** that change objects **while
furnishing**, with their own root class. Only in Advanced Fill for now, not in Interior Fill.

```cpp
class CfgZEIC_Modifiers {
    class defencesOnly {
        displayName = "$STR_ZEIC_core_Modifier_DefencesOnly_DisplayName";
        tooltip = "$STR_ZEIC_core_Modifier_DefencesOnly_Tooltip";
        order = 10;
        keep[] = {"Land_BagFence_base_F", "Land_HBarrier_base_F" /* ... */};
    };
    class noElectronics {
        displayName = "No modern electronics";
        remove[] = {"Land_Laptop_unfolded_F", "Land_MobilePhone_smart_F" /* ... */};
    };
    class coldWar {
        displayName = "Cold War era";
        remove[] = { /* drones, solar panels, ... */ };
        class replace {
            Land_PlasticCase_01_medium_F[] = {"land_gm_..._crate", "Land_WoodenCrate_01_F"};
        };
    };
};
```

| Property | Type | Required | Meaning |
|---|---|---|---|
| `displayName` | string | no | Checkbox label. Default: the class name. |
| `tooltip` | string | no | Checkbox tooltip. |
| `order` | number | no | Position in the dialog (default 100), then by display name. |
| `remove[]` | array | no | Matching objects are skipped. |
| `keep[]` | array | no | Only matching objects are placed, everything else is skipped. |
| `replace` | class | no | `<object class>[] = {candidates in order of preference}`. |

- **Matching by `isKindOf`**: an entry covers its child classes too, so a parent class like
  `Land_BagFence_base_F` covers every sandbag wall, incl. mod variants that inherit from it. This
  holds for `remove[]`, `keep[]` and the object classes in `replace`.
- **`remove[]`** is always safe: the object is skipped, nothing has to fit.
- **`replace`** lists candidates in order of preference. Candidates that don't exist are skipped,
  and if none exist the object is kept as-is. So a modifier **works without GM** and gets better
  with it. A replacement is not randomised again.
- Replacements should be limited to objects of similar size (crate → crate). Anything that needs
  different positions belongs in dedicated `mil_cw` / `civ_cw` templates.
- **Order**: the modifiers apply to the object class after its random variant
  (section 4) is picked, in the order **replace → remove → keep**: a replacement can still be
  removed, and `keep[]` checks the replacement. With several checked modifiers, `replace` rules
  are tried in the modifiers' `order` (the first matching rule wins), and an object matching
  the `keep[]` of any checked modifier is kept.
- Classes in `remove[]` / `keep[]` that don't exist are ignored, so a modifier can list mod
  classes without depending on the mod.
- **Mods and missions** add modifiers the same way as categories: a template addon adds its own
  classes, a mission adds them in `description.ext`. To **extend** a modifier:
  - a **subclass** of it (any name but `replace`) adds its `remove[]`, `keep[]` and `replace` to
    the modifier's, since config arrays can't be appended across addons. `templates_gm` adds its
    sandbags to `defencesOnly` this way (`class defencesOnly { class gm { keep[] = {...}; }; };`);
  - an entry in its `replace` class overrides that object's candidates, e.g. to put a mod's
    candidate first (`templates_gm`: `Land_CanisterFuel_F[] = {"gm_jerrycan"};`);
  - a mission class with the name of an addon modifier is read too, before the addon's, so its
    `replace` rules win.
- **Where it runs**: the Zeus client sends only the checked class names with the fill request.
  The server (in Eden: the local machine) reads them once per fill, picks the replacement
  candidates and caches the result per object class, see `fn_fillModifiers_resolve.sqf`. It works
  with every object mode and with the collision check (*furniture gives way* checks the
  replacement). Alt repeats the last checked modifiers.

## 11. Object Switch (`CfgZEIC_ObjectSwitch`)

The Object Switch module swaps objects for their counterpart in another camouflage set.
Each **row** is one object, named after its vanilla (desert) class; each **set** is a property of the row.

```cpp
class CfgZEIC_ObjectSwitch {
    class Sets {
        class jungle { displayName = "Jungle (Apex)"; order = 20; };
    };
    class Objects {
        class Land_BagFence_Long_F { desert = "Land_BagFence_Long_F"; jungle = "Land_BagFence_01_long_green_F"; };
    };
};
```

- An object found in **any** set of a row is replaced by the row's entry for the chosen set (the first row in config order wins).
- A mod adds a set by declaring it in `Sets` and adding its property to the existing rows (and new rows for its own objects),
  from an addon that loads after `ZEIC_core`. The CUP and SOG sets live in their template addons, so they only exist with their mod.
- Rows without an entry for the chosen set are left as they are.

## 12. Fill Table / Shelf (`CfgZEIC_ObjectFill`)

```cpp
class CfgZEIC_ObjectFill {
    class Types {
        class food {
            displayName = "Food";
            order = 10;
            floor = "Land_Garbage_square3_F";   // under tables (objects with one level)
            objects[] = { "Land_BakedBeans_F", "Land_Can_V1_F" };
        };
    };
    class Surfaces {
        class Land_Metal_rack_F {
            edge[] = {0.15, 0.1, 0.15, 0.1};      // indent from the bounding box: x min, x max, y min, y max
            levels[] = {-0.35, -0.8, -1.25, -1.7}; // shelf heights below the top of the bounding box
        };
    };
};
```

- The dialog lists "Random" (the props of all types) and every type, sorted by `order`.
- Objects that aren't in `Surfaces` are filled on the top of their model.
- Props that don't exist (mod not loaded) are left out.

