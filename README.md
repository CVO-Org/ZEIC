<p align="center">
    <img src="https://github.com/CVO-Org/ZEIC/blob/main/img/ZEIC-Full-Transparent.png" width="512">
    </br>
    <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3567067667"><img src="https://img.shields.io/steam/subscriptions/3567067667?style=for-the-badge&logo=steam&label=Steam%20Workshop&color=%23690000"></a>
</p>



# ZEIC - Community Version

This STANDALONE Mod is the spiritual successor of ZEI and ZEI Continued.

The goal is to follow Sgt. J. Andrews / Samantha initial attempt maintain this highly useful mod.

**Contributions and Pull Requests are very welcome!**
More Details below

# ZEIC - Changes
- New dialogs in the style of Zeus Enhanced, with a description of each module; translatable.
- Buildings are processed over several frames (no freezes on large areas), with coloured wireframes showing the progress to every Zeus.
- Templates live in config: any mod or mission can add templates and categories (see `docs/config-schema.md`). Template addons load only with their mod (CUP, GM, SOG, Western Sahara, OPTRE).
- Area fills and area garrisons with a radius preview on the ground.
- New Advanced Fill module: furnish and garrison in one go, with a collision check and fill modifiers.
- Eden: one layer per module, fill and building.

# ZEI - Zeus and Eden Interiors
A tool to quickly decorate and populate interiors for your missions in either Zeus or Eden.

## ZEI Interior Modules
### Advanced Fill
- Furnishes and garrisons a building, or a share of the buildings within a radius, in one go: per building the interior first, then the units. Either part can be turned off.
- Collision check: units aren't placed on positions blocked by furniture. Choose whether the units or the furniture give way.
- Fill modifiers change what a template places: Military defences only, No modern electronics, Cold War era. Mods and missions can add their own (see `docs/config-schema.md`).
- Hold Alt while placing to fill again with the last settings.

### Garrison Building
- Fills a building, or a share of the buildings within a radius, with infantry of any faction (supports any units addon).
- Units as a percentage of each building's positions, with a live estimate of the unit count; asks before creating over 400 units.
- Pick a faction and subcategory from one list (e.g. NATO Men (Special Forces)), with side filter and search; recently used ones are listed on top.
- Optional Move AI trigger: the units hold their positions until an enemy player comes close, then some and later all of them move.
- Attempts to find the best direction for the units to face. Avoids spawning pilots, crew etc.
- Hold Alt while placing to garrison again with the last settings.

### Interior Fill
- Furnishes a building, or a share of the buildings within a radius, from the templates of a category (Military, Civilian, CBRN, and any category a mod or mission adds).
- Simple objects (fastest), normal objects, or objects editable in Zeus.
- Shortcuts, held while placing: Alt repeats the last fill, Ctrl fills Military, Shift Civilian, Ctrl+Shift CBRN.

### Fill Table / Shelf
- Puts small objects on a table, shelf or rack (food, medical, office, tools, modern or old electronics, CBRN cleaning or random).
- Choose how full and how the objects are created.
- Hold Alt while placing to fill again with the last settings.

### Object Switch
- Converts objects of one region to another region (e.g. Green Sandbags to Brown Sandbags)
- Supports CUP objects but positioning may be affected due to model sizes.

## ZEI Development Modules
The following modules are designed to make it easier for you to help with the development of this addon, they are not available in Zeus.

### List Buildings
- Use it to quickly find which buildings have little or no ZEI templates.
- VR World Only
- Creates rows of buildings having the chosen number of templates or less.
- Coloured arrows in front of the buildings show the template count per category (the colours are listed in chat).

### Mark Positions
- Highlights all building positions in a building.
- Don't block these when creating a template!

### Save Building Scheme
- Saves a building in the ZEI template format, no need to run any code through the debug menu now.
- Pressing 'LookAround' (Default: ALT) will 'force save' the highlighted object so you can save objects that aren't buildings.

## Additional Informations
### Technical Details
- **This Mod is a STANDALONE Version - No need to Load the Original ZEI Mod.**
- Only the Zeus needs it; other players don't. Can be loaded as an optional mod.
- In multiplayer the **server needs it too** for Interior Fill, Advanced Fill and the Move AI trigger (the objects and triggers are created on the server).
- Creates no dependency in mission file.
- This mod is build and signed with hemtt - each update will produce a new bikey.

### Contribute
- Contributions of Compositions for Buildings are welcome and one of the main motivators for the community project.
- Contribute Compositions via Steam Workshop Discussion
- Contribute Compositions directly to Github via Pull Request.
- I am looking for Co-Maintainers so it doesnt get stale in case i wont have time to attend to the matter.

### Why ZEI Community Version when there is ZEI Continued
I tried to contact the author of the ZEI Continued via Steam Workshop, Github and Discord to offer my help to maintain and streamline "ZEI Continued" but never have gotten a response and the last update was 10 Mar, 2025.

### Links
- [Github: Zeus Eden Interior - Community Version](https://github.com/CVO-Org/ZEIC)
- [Steam Workshop: ZEI - Zeus and Eden Interior - The Original](https://steamcommunity.com/sharedfiles/filedetails/?id=1251859358)
- [Steam Workshop: ZEI - Zeus and Eden Interiors ( Continued )](https://steamcommunity.com/sharedfiles/filedetails/?id=3438718557)
- [Bohemia Forums: ZEI - Zeus and Eden Interior](https://steamcommunity.com/sharedfiles/filedetails/?id=1920324184)

### Credits
[List of Authors](https://github.com/CVO-Org/ZEIC/blob/main/AUTHORS.txt)
