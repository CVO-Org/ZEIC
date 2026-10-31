## How to add custom Templates to your mission

```sqf
[_category, _data] call ZEIC_fnc_addCustomTemplate;
```

`_category` is the Interior Fill category the template belongs to, e.g. `"mil"`, `"civ"` or `"cbrn"`.

`_data` is one of:
- the full string the **Save Building Scheme** module puts in your clipboard (`case "Class": { [...] };`)
- the legacy format `"Class: [...]"`
- an array: `[buildingClass, template]` or `[buildingClass, [template, ...]]`

A template is a list of objects: `["ObjectClass", [x, y, z], direction]` or `["ObjectClass", [x, y, z], direction, [rotX, rotY, rotZ]]`, with positions relative to the building.

The function returns `true` on success. Errors (unknown building class, no template data) are shown in chat and written to the RPT.

Custom templates are added to the built-in ones for that building. Call the function on every machine that places interiors, e.g. in `init.sqf`.
