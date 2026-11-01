# Wording and stringtable keys

All user-facing text lives in `addons/core/stringtable.xml`. This page keeps new text consistent with the existing text.

## Glossary

| Term | Meaning |
|---|---|
| *furnish* | What Interior Fill (and the interior part of Advanced Fill) does to a building. |
| *fill* | What Object Fill does to a table, shelf or rack. |
| *objects* | The things ZEIC places. Not "props". |
| *template* | One interior layout for one building class, as in `CfgZEIC`. |
| *category* | A group of templates (Military, Civilian, CBRN, ...), a subclass of `CfgZEIC`. |
| *set* | An Object Switch camouflage set, as in `CfgZEIC_ObjectSwitch`. |
| *object mode* | Simple / Objects / Editable: how the placed objects are created. |
| *shortcuts* | Keys held while placing a module to skip its dialog (Alt, Ctrl, Shift). |
| *modifiers* | Reserved for the fill modifiers of Advanced Fill (#55). Not used for held keys. |

## Key names

Keys follow ACE3: `STR_ZEIC_core_<Thing>[_<Field>][_<Suffix>]`, readable CamelCase, no abbreviations.

- `<Thing>` is the module (`ModuleInteriorFill`, `ModuleGarrisonBuilding`, ...) or nothing for shared keys.
- `<Field>` is a dialog field, an option or a message of that module: `ModuleObjectFill_Type_Food`, `ModuleInteriorFill_Done`.
- Suffixes: `_DisplayName` (module name), `_Description`, `_Tooltip`. Field labels have no suffix.
- Messages are grouped under their module (`ModuleObjectSwitch_Nothing`), not in a `MSG_` block.
- In the XML, each module has its own `<Container>`; shared keys are in `Common`.

### Shared keys

Fields that mean the same in several dialogs use one key, so their texts can't drift apart:

- `Radius` / `Radius_Tooltip`
- `Percentage` / `Percentage_Tooltip`: the share of buildings within the radius. A field with another meaning keeps the label and gets its own tooltip (`ModuleObjectFill_Percentage_Tooltip`, the chance per spot). Only a dialog with several percentage sliders uses more specific labels.
- `ObjectMode`, `ObjectMode_Simple`, `ObjectMode_Normal`, `ObjectMode_Editable` (+ `_Tooltip`)
- `Category`, `Description`, `Shortcuts`, `Cancel`
- `NoBuilding`: takes the module name as `%1`

## Text rules

- The dialog title is the module name (`ModuleX_DisplayName`), no separate title keys.
- Every chat message starts with the module name: `Interior Fill: ...`, `Object Switch: ...`.
- Units in brackets: `Radius [m]`. Sentence case for labels and options: `Allow damage`, `Max templates`.
- Tooltips have 1-2 lines; `\n` starts a new line (also in `stringtable.xml`).
- Below the rows, every dialog shows `Description (?)` and, if it has any, `Shortcuts (?)` (see `fn_ui_dialogFinish.sqf`). The description says in one sentence what the module does; details of a field go into that field's tooltip.
- The shortcuts tooltip is a list:

  ```
  Hold while placing the module (skips this dialog):
  Alt: repeat the last fill
  Ctrl: Military
  Uses the last radius, percentage and object mode.
  ```
