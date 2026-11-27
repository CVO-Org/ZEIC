# Contributing

**For you if** you want to help ZEIC: report a bug, send a template, translate, or work on the code.

## Summary

The most useful contribution is a **template for a building that doesn't have one yet**, and you don't need to know any code for it. Bugs and ideas go into GitHub issues. Code, translations and templates can come as pull requests. Every pull request needs a `pr/*` label, because the label sorts it into the changelog.

| You want to... | Go to |
|---|---|
| send a template | [Templates](#templates) |
| report a bug or suggest something | [Issues](#issues) |
| translate | [Translations](#translations) |
| change the code | [Pull requests](#pull-requests), [Development setup](#development-setup) |

## Templates

### Simple way: post it
1. Make the template with **Save Building Scheme**, as in [Your own templates](docs/custom-templates.md#step-by-step).
2. Post the copied text in the [Workshop discussions](https://steamcommunity.com/workshop/filedetails/discussions/3567067667/) or in a GitHub issue, and say which mods it needs.

A maintainer adds it to the next release.

### Pull request
1. **Find a building that needs one.** On the VR map, place **ZEIC - Interiors Development → List Buildings** with *Max templates* `0`. It lines up every building without a template.
2. **Make the template** with Save Building Scheme. Use **Mark Positions** first and keep the arrows free, so garrisons still fit.
3. **Pick the pack.** A template's dependencies are the building **and every object in it**. It goes into the pack of its heaviest dependency:

   | Building | Objects | Pack |
   |---|---|---|
   | vanilla | vanilla | `addons/templates_vanilla` |
   | vanilla | some CUP | `addons/templates_cup` |
   | CUP | vanilla | `addons/templates_cup` |
   | GM | some CUP | needs both: ask in the issue first |

   The copied text's `// Uses objects from:` line helps, but it only lists the objects' mods, not the building's.
4. **Paste it** into that pack's `CfgZEIC.hpp`, under the category (`mil`, `civ`, `cbrn`) and the building class. If the building class is already there, add your template next to the existing ones.
5. **Rename the template class** from `saved_<time>` to the pack's tag plus the next free number in that building, for example `vanilla_3` or `cup_2`.
6. **Test it:** `hemtt launch default vr`, place the building, and fill it with Interior Fill.
7. Open the pull request with the label `pr/improvement`.

## Issues
Use the issue templates (Bug Report / Feature Request). For bugs, the mod version, the steps to reproduce and the RPT log help the most.

For more detail in the RPT, run `ZEIC_DEBUG = true` in the debug console before you reproduce the bug.

## Pull requests
1. Fork the repository and create a branch from `main`.
2. Keep a PR focused on one change.
3. Title: `Scope - Type: Short description`, imperative, in English, for example `Interior Fill - Fix: Skip buildings that are already furnished`. It becomes the changelog entry.
4. Labels: at least one `pr/*` label is required, because it sorts the PR into the changelog:
   `pr/new`, `pr/improvement`, `pr/fix`, `pr/settings`, `pr/translation`, `pr/docs`, `pr/maintenance`, `pr/cleanup`, `pr/breaking` (in addition to a main label), `pr/ignore`.
   If you can't set labels, the maintainer will add them.
5. Fill in the PR template, including how you tested the change.

Every pull request runs `hemtt check` and checks the config style and the stringtables.

## Development setup
- Install [HEMTT](https://hemtt.dev): `winget install BrettMayson.HEMTT`
- `hemtt check`: lint and validate
- `hemtt launch`: build and start Arma 3 with the test mission on Altis (`hemtt launch default vr` for VR)
- New addons: `tools\new-addon.bat`

How the templates and the other config classes are structured: [config reference](docs/config-schema.md).

## Code style
- 4 spaces, no tabs, CRLF line endings (see `.editorconfig`).
- Follow the style of the surrounding code: ACE-style function headers, CBA / project macros (`GVAR`, `FUNC`, `LSTRING`, ...), aligned columns for repetitive lines.
- All user-facing text goes into `stringtable.xml`. Key names, shared keys and wording: see [`docs/wording.md`](docs/wording.md).

## Translations
Add or update entries in the addon's `stringtable.xml` and label the PR with `pr/translation`. The open issue **Translations** shows how complete each language is.
