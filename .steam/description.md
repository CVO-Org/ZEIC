<!-- Steam Workshop description of the stable item, converted to BBCode on every full release.
     Edits on the Workshop page are overwritten - change this file instead. -->

# Support the Project
![Support the Project](https://i.imgur.com/3Qd4tiO.gif)

# [Join Our Discord!](https://discord.gg/ag4v6kxYAa)

# ZEIC - Zeus and Eden Interiors, Community Version
Furnish and garrison buildings in seconds, in Zeus or in Eden. Place a module on a building, or on a whole town, and ZEIC fills the rooms with furniture and the windows with soldiers.

ZEIC continues ZEI, the original Zeus and Eden Interiors. It is actively maintained and improved by the community, and it is **standalone: you don't need the original ZEI**.

# What you need
- Only the Zeus or mission maker needs ZEIC. Other players don't, so it can be an optional mod.
- In multiplayer the server needs it too for Interior Fill, Advanced Fill and the Move AI trigger.
- No dependency in the mission file. A mission furnished in Eden runs without ZEIC.
- CUP Terrains, Global Mobilization, S.O.G. Prairie Fire, Western Sahara and OPTRE buildings get their own templates, loaded only when that mod is loaded.

# Guides
- [Zeus guide](https://github.com/CVO-Org/ZEIC/blob/main/docs/zeus.md): furnish and garrison buildings live, as Zeus.
- [Mission maker guide](https://github.com/CVO-Org/ZEIC/blob/main/docs/mission-makers.md): furnish buildings in Eden, for a mission you build.
- [Your own templates](https://github.com/CVO-Org/ZEIC/blob/main/docs/custom-templates.md): use your own interior layouts in your missions.
- [Mod author guide](https://github.com/CVO-Org/ZEIC/blob/main/docs/mod-authors.md): make ZEIC furnish the buildings of your terrain or mod.
- [Module reference](https://github.com/CVO-Org/ZEIC/blob/main/docs/modules.md): what each module, field and shortcut does.

# Modules
All modules are in the module list under **ZEIC - Interiors**.

### Interior Fill
- Furnishes a building, or a share of the buildings within a radius, from the templates of a category (Military, Civilian, CBRN, and any category a mod or mission adds).
- Simple objects (fastest), normal objects, or objects editable in Zeus.
- Shortcuts, held while placing: Alt repeats the last fill, Ctrl fills Military, Shift Civilian, Ctrl+Shift CBRN.

### Garrison Building
- Fills a building, or a share of the buildings within a radius, with infantry of any faction (supports any units addon).
- Units as a percentage of each building's positions, with a live estimate of the unit count.
- Pick a faction and subcategory from one list, with side filter and search; recently used ones are listed on top.
- Optional Move AI trigger: the units hold their positions until an enemy player comes close, then some and later all of them move.

### Advanced Fill
- Furnishes and garrisons in one go: per building the interior first, then the units.
- Collision check: units aren't placed on positions blocked by furniture.
- Fill modifiers change what a template places: Military defences only, No modern electronics, Cold War era.

### Fill Table / Shelf
- Puts small objects on a table, shelf or rack (food, medical, office, tools, modern or old electronics, CBRN cleaning or random).

### Object Switch
- Swaps military objects within a radius for another camouflage set (e.g. green sandbags for brown ones), including CUP and S.O.G. sets when those mods are loaded.

### Template tools (Eden only)
Under **ZEIC - Interiors Development**: Save Building Scheme copies a building's objects as a template, Mark Positions shows the building positions, List Buildings (VR only) lines up buildings with few or no templates.

# Contribute
- **Templates are the most welcome contribution, and they need no code.** Furnish a building in Eden, copy it with Save Building Scheme and post the text in the Discussions of this page, or send a pull request on GitHub: [Contributing](https://github.com/CVO-Org/ZEIC/blob/main/CONTRIBUTING.md).
- I am looking for co-maintainers, so the mod doesn't go stale when I don't have time for it.

# Why a community version
There are three versions of this mod:
- **[ZEI](https://steamcommunity.com/sharedfiles/filedetails/?id=1251859358)**, the original Zeus and Eden Interiors.
- **[ZEI Continued](https://steamcommunity.com/sharedfiles/filedetails/?id=3438718557)**, an attempt to improve it. It went stale: the last update was on 10 Mar 2025, and its author never answered my offers of help via Steam Workshop, GitHub and Discord.
- **ZEIC, the Community Version** (this mod), open on GitHub, actively maintained and improved, with contributions from anyone.

# Links
- [GitHub: ZEIC](https://github.com/CVO-Org/ZEIC) and its [releases](https://github.com/CVO-Org/ZEIC/releases)
- [Steam Workshop: ZEIC - DEV Version](https://steamcommunity.com/sharedfiles/filedetails/?id=3831519489), with every pre-release
- [Steam Workshop: ZEI, the original](https://steamcommunity.com/sharedfiles/filedetails/?id=1251859358)
- [Steam Workshop: ZEI Continued](https://steamcommunity.com/sharedfiles/filedetails/?id=3438718557)
- [Credits: list of authors](https://github.com/CVO-Org/ZEIC/blob/main/AUTHORS.txt)
