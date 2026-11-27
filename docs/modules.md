# Modules

What each ZEIC module does, its dialog fields and its shortcuts. For how to use them, see the [Zeus guide](zeus.md) or the [mission maker guide](mission-makers.md).

| Module | Category | Zeus | Eden |
|---|---|---|---|
| [Interior Fill](#interior-fill) | ZEIC - Interiors | yes | yes |
| [Garrison Building](#garrison-building) | ZEIC - Interiors | yes | yes |
| [Advanced Fill](#advanced-fill) | ZEIC - Interiors | yes | yes |
| [Fill Table / Shelf](#fill-table--shelf) | ZEIC - Interiors | yes | yes |
| [Object Switch](#object-switch) | ZEIC - Interiors | yes | yes |
| [Save Building Scheme](#save-building-scheme) | ZEIC - Interiors Development | - | yes |
| [Mark Positions](#mark-positions) | ZEIC - Interiors Development | - | yes |
| [List Buildings](#list-buildings) | ZEIC - Interiors Development | - | yes, VR only |

All modules work the same way: place the module, a dialog opens, the module is removed again. Nothing of the module stays in the mission.

## Fields most dialogs share

| Field | Meaning |
|---|---|
| **Radius [m]** | `0`: only the building under the module (or the nearest within 25 m). Otherwise every building within this distance, shown as a circle on the ground. |
| **Percentage** | With a radius: the share of those buildings that gets filled, picked at random. Not used at radius 0. |
| **Objects** | How the placed objects are created: **Simple** (fastest, can't be moved or deleted in Zeus), **Objects** (normal objects, not added to Zeus), **Editable** (can be moved and deleted in Zeus, but Zeus gets slow with many of them). |

At the bottom of every dialog, **Description (?)** and **Shortcuts (?)** show what the module does and which keys skip the dialog.

## Interior Fill

Furnishes buildings from the templates of the ticked categories.

| Field | Meaning |
|---|---|
| Categories | A checkbox per category: Military, Civilian, CBRN, and any category a mod or the mission adds. Tick one or more: each building gets a template from all ticked categories together. At least one has to be ticked. |
| Radius, Percentage, Objects | see [above](#fields-most-dialogs-share) |
| Allow damage | Off (default): the furnished building can't be destroyed. On: it can, but its interior may be left floating. |

**Shortcuts**, held while placing: **Alt** repeats the last fill with the last ticked categories. **Ctrl** fills only Military, **Shift** only Civilian, **Ctrl+Shift** only CBRN; they don't change which categories are ticked next time. All use the last radius, percentage and object mode.

- Buildings that are already furnished are skipped.
- Neighbouring buildings of the same type get different templates in turn.
- A building can be furnished if it has building positions, or if one of the ticked categories has a template for it (bunkers, towers).
- The chat message at the end says how many buildings were furnished and how many had no template. The RPT lists them.
- In Zeus multiplayer, the fill runs on the server. If the server doesn't run ZEIC, nothing is placed and no message comes.

## Garrison Building

Puts infantry of a faction on the building positions.

| Field | Meaning |
|---|---|
| Recently used | Faction and subcategory pairs used in this session. Picking one replaces the faction below. |
| Side, Search, Faction | Pick a faction and subcategory from one list, e.g. *NATO Men (Special Forces)*. Search takes words of the name, class, subcategory or side, e.g. `TKA`, `nato special`, `opfor`. |
| Radius | see [above](#fields-most-dialogs-share) |
| Buildings [%] | With a radius: the share of the buildings that gets a garrison, at least one. |
| Positions [%] | How full each building gets: the share of its positions, at least one unit. Very large buildings count with at most 1.5 times the median of the selected buildings, so one big building doesn't take all the units. |
| Move AI trigger | Units hold their positions until an enemy player comes close. Then about a fifth of them may move, and after 30 to 120 seconds all of them. |
| Dynamic simulation | Enables dynamic simulation for the units. Don't use it where the AI can easily be seen (outside, on roofs). |

Below the fields, an estimate shows how many units in how many buildings. Over 400 units, ZEIC asks before creating them.

**Shortcut:** **Alt** repeats the last garrison with the last faction and settings.

- ZEIC tries to find the best direction for each unit to face. Pilots, crew and similar units are left out.
- In Zeus, the units are local to the Zeus who placed them. The Move AI trigger is created on the server. If the server doesn't run ZEIC, the units are placed without the trigger and nothing warns you.

## Advanced Fill

Furnishes and garrisons in one go: per building, first the interior, then the units. The dialog has an **Interior** and a **Garrison** tab with the fields of [Interior Fill](#interior-fill) and [Garrison Building](#garrison-building), and a **Settings** tab. Above the tabs are the presets.

| Field | Meaning |
|---|---|
| Preset | Picking a preset applies its settings to all three tabs. **Delete** removes it (click twice). Presets from a mod or the mission are marked *(read-only)* and can't be deleted. |
| Save as | A name and **Save**: saves the settings of all three tabs as a preset in your profile. With the name of one of your presets the button says **Overwrite**. Enter in the name field saves. |
| Interior / Garrison on or off | Turns that part on or off. One always stays on. |
| Collision check | No units on building positions blocked by furniture. Only with both parts on. |
| Blocked positions | **Units give way:** fewer units in heavily furnished buildings. **Furniture gives way:** the garrison positions are picked first, and the interior leaves them free. |
| Fill modifiers | Change the objects while furnishing, see below. |

**Fill modifiers:**

| Modifier | Effect |
|---|---|
| Military defences only | Only places sandbags, H-barriers, bunkers, camo nets and similar defences. |
| No modern electronics | Leaves out laptops, tablets, phones, monitors, routers, drones and similar. |
| Cold War era | Leaves out modern objects and replaces plastic cases with older-looking crates. Uses Global Mobilization objects when GM is loaded. |

With several checked, objects are first replaced, then removed, then kept. Mods and missions can add their own modifiers.

**Shortcut:** **Alt** repeats the last fill with all the last settings, including which parts are on.

**Presets** are kept in your profile, so they work in every mission. A preset made with a mod's category, modifier or faction still loads without that mod: those entries are left out with a note in chat. Mods and missions can ship their own presets, see [the config reference](config-schema.md#13-advanced-fill-presets-cfgzeic_presets).

- With both parts on, each building is garrisoned once its interior is done. If no interior is reported within 120 s, the building is garrisoned anyway, with *no interior reported for ...* in chat. In multiplayer this usually means the server doesn't run ZEIC, so the interior part does nothing.

## Fill Table / Shelf

Puts small objects on a table, shelf or rack: the one under the module, or the nearest one within 10 m. Tables also get something on the floor below them.

| Field | Meaning |
|---|---|
| Type | Food, Medical, Office, Tools, Electronics (modern), Electronics (old), CBRN cleaning, or Random (all of them) |
| Percentage | The chance for each spot on the furniture to get an object |
| Objects | see [above](#fields-most-dialogs-share) |

**Shortcut:** **Alt** repeats the last fill with the last type, percentage and object mode.

Furniture ZEIC doesn't know the shelves of gets objects on its top only.

## Object Switch

Swaps military objects within the radius for their counterpart in another camouflage set: sandbags, H-barriers, camo nets, cargo buildings, crates and furniture.

| Field | Meaning |
|---|---|
| Convert to | Desert (vanilla), Jungle (Apex), Woodland (Contact); with CUP: Desert (CUP), Woodland (CUP); with S.O.G.: Green (SOG), Brown (SOG) |
| Radius | Objects within this distance of the module are switched |

Objects without a counterpart in the chosen set stay as they are. CUP objects can sit slightly differently, because their models have other sizes.

## Save Building Scheme

Eden only. Place it on a building to copy the objects in and around it as a template: everything within the building's size plus 5 m, without the building itself and without Mark Positions arrows. The template goes to the clipboard and to the RPT, ready to paste into a mission's `description.ext` or a mod. Step by step: [Your own templates](custom-templates.md).

- Hold **Alt** while placing to save an object that has no building positions, such as a bunker.
- It warns when the building isn't level, and when you're not on the VR map.
- The copied text starts with a header: the building, a category guess and the mods the building and its objects need.
- To get it into ZEIC itself, use the [Template submission](https://github.com/CVO-Org/ZEIC/issues/new?template=template_submission.yml) form ([Contributing](../CONTRIBUTING.md#templates)).
- Advanced: set `ZEIC_SaveRadius` (default `5`) to change the distance around the building.

## Mark Positions

Eden only. Puts an arrow on every building position of the building, where garrisoned units will stand. Keep these spots free when you make a template. The arrows are not saved by Save Building Scheme.

## List Buildings

Eden, VR map only, for template authors. Places rows of buildings and shows how many templates each has: one arrow per template below each building, one colour per category (the colours are listed in chat).

| Field | Meaning |
|---|---|
| Category | The categories to count, or All |
| Max templates | Buildings with more templates than this are left out. `0`: only buildings without any template. |
| Mark positions | Also puts an arrow on every building position |

Use it to find the buildings that still need templates: [Contributing](../CONTRIBUTING.md#templates).
