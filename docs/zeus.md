# ZEIC for Zeus game masters

**For you if** you run missions as Zeus and want to furnish or garrison buildings while the game is running.

**You need:** ZEIC loaded on your game. In multiplayer, the server needs it too (see [Multiplayer](#multiplayer)). Your players don't need it.

## Summary

Drop a ZEIC module on a building, choose a few options, and the building is furnished, garrisoned, or both. Set a radius and the module does the same for many buildings around it, up to a whole town. Hold a key while placing the module and it skips the dialog and reuses your last settings.

## Step by step

1. Open the Zeus interface and go to **Modules**, category **ZEIC - Interiors**.
2. Pick the module:

   | Module | Does |
   |---|---|
   | **Interior Fill** | furnishes buildings from the templates of a category (Military, Civilian, CBRN, ...) |
   | **Garrison Building** | puts infantry of a faction on the building positions |
   | **Advanced Fill** | both in one go: per building the furniture first, then the units |
   | **Fill Table / Shelf** | puts small objects on one table, shelf or rack |
   | **Object Switch** | swaps sandbags, H-barriers, camo nets and the like for another camouflage set |

3. Place it **on the building**. The module uses the building under it, or the nearest one within 25 m.
4. In the dialog:
   - **Radius [m]:** `0` means only that building. Anything above uses every building within that distance, shown as a circle on the ground.
   - **Percentage:** with a radius, the share of those buildings that gets filled, picked at random.
   - **Objects:** how the furniture is created, see [Object modes](#object-modes).
   - The rest depends on the module. Every dialog has a **Description (?)** and a **Shortcuts (?)** tooltip at the bottom.
5. Confirm. Large areas are processed a few buildings per frame, so the game doesn't freeze. Coloured wireframes show the progress on each building to every Zeus.
6. When it's done, a chat message tells you how many buildings were furnished and how many had no template.

## Shortcuts

Hold the key **while placing the module**. The dialog is skipped and the last radius, percentage and object mode are used.

| Key | Interior Fill | Garrison Building, Advanced Fill, Fill Table / Shelf |
|---|---|---|
| Alt | repeat the last fill | repeat the last settings |
| Ctrl | fill Military | - |
| Shift | fill Civilian | - |
| Ctrl+Shift | fill CBRN | - |

Before you've used a dialog in this session, Interior Fill falls back to its defaults (only the building under the module, simple objects). Garrison Building and Advanced Fill need a faction, so they ask you to open the dialog once first.

## Things worth knowing

### Object modes

| Mode | Use it for |
|---|---|
| **Simple** | big areas. Fastest, but you can't move or delete the objects in Zeus. |
| **Objects** | normal objects, not added to Zeus. |
| **Editable** | objects you want to move or delete later. Zeus gets slow with many of them, so keep it for single buildings. |

### Garrisons
- The unit count is a percentage of each building's positions, with a live estimate in the dialog. ZEIC asks before it creates more than 400 units.
- Pick a faction and subcategory from one list, with a side filter and search. Recently used ones are listed on top.
- **Move AI trigger:** the units hold their positions until an enemy player comes close, then some and later all of them start to move. Without it they stay put.
- Garrisoned units are local to you, like any unit you place as Zeus. Headless client mods take them over from there as usual.

### Furniture
- A building is furnished only once. Filling it again gives "all selected buildings are already furnished".
- Buildings of identical type next to each other get different templates in turn, so a street doesn't look copy-pasted.
- **Allow damage** off (default) keeps the building intact, so the furniture can't end up floating in a ruin.
- **Fill modifiers** in Advanced Fill change the objects while furnishing: *Military defences only*, *No modern electronics*, *Cold War era*.

### Multiplayer
- The **server needs ZEIC** for Interior Fill, Advanced Fill and the Move AI trigger. The furniture and triggers are created on the server, so every player sees them.
- **ZEIC doesn't check whether the server has it.** Without it on the server, nothing tells you: Interior Fill places no furniture and gives no message, and garrisoned units never get their Move AI trigger, so they stay in place. Advanced Fill with a garrison waits 120 s per building for the interior, then garrisons it anyway with *no interior reported for ...*.
- Garrison Building, Fill Table / Shelf and Object Switch work without ZEIC on the server.
- In singleplayer and on a game you host yourself, your game is the server, so this doesn't apply.
- If you disconnect in the middle of a big fill, the server finishes it.
- Players without ZEIC see everything normally. They don't need the mod.

## When it doesn't work

Every message starts with the module name.

| Message | Meaning |
|---|---|
| *no valid building within 25 m of the module* | Place the module closer to, or on, a building. |
| *no valid buildings found* | No building in the radius can be furnished. Only buildings with building positions or a template count. |
| *no template for X (Y) yet* | Nobody has made a layout for this building in this category yet. Try another category, or [make one](custom-templates.md) and share it. |
| *... furnished, N without template (see RPT)* | Some buildings were skipped. The RPT lists which ones, and templates that were skipped because of a missing mod. |
| *Alt repeats the last ..., open the dialog once first* | Garrison Building or Advanced Fill: use the dialog once, then Alt works. |
| *select a faction first* | Garrison Building or Advanced Fill needs a faction. |
| *no infantry found for faction X* | That faction has no infantry ZEIC can use. Pick another subcategory. |
| *nothing to switch within the radius* | Object Switch found no objects it knows in the radius. |
| *Advanced Fill: no interior reported for X after 120 s, garrisoned without waiting.* | The interior never arrived. In multiplayer, the server most likely doesn't run ZEIC, see [Multiplayer](#multiplayer). |

**No message and no furniture at all** after an Interior Fill in multiplayer: the server most likely doesn't run ZEIC, see [Multiplayer](#multiplayer).

## Going further

- Every field of every module: [Module reference](modules.md)
- Furnishing in Eden instead: [Mission maker guide](mission-makers.md)
- A building has no template, or you want your own layouts: [Your own templates](custom-templates.md)
