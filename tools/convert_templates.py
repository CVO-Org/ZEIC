"""Convert the SQF interior templates (addons/core/templates/*.sqf) to config (CfgZEIC).

One-off migration (#24): the SQF templates have been removed since, the config files in
addons/templates_*/ are the source now and are edited directly. Kept to convert templates in the
old SQF `case` format, e.g. Save Building Scheme output of older versions: put them into
addons/core/templates/<file from SOURCES> and run it on a branch.

The SQF templates are `case` blocks of one big `switch` in fn_findTemplates.sqf:

    case "Land_A";              // fall-through: shares the templates below
    case "Land_B": {
        [
            [["Class", [x, y, z], dir], ...]      // template 1
            ,[["Class", [x, y, z], dir, [rx, ry, rz]], ...]   // template 2
        ]
    };

They become config classes, one template addon per dependency (see docs/config-schema.md):

    class CfgZEIC {
        class mil {
            class Land_B {
                class vanilla_1 { objects[] = { {"Class", {x, y, z}, dir}, ... }; };
            };
            class Land_A: Land_B {};
        };
    };

Usage (from the repository root):
    python tools/convert_templates.py          # write addons/templates_*/CfgZEIC.hpp
    python tools/convert_templates.py --check  # only parse and print the statistics
"""

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "addons" / "core" / "templates"

# source file -> (template addon, category)
SOURCES = {
    "mil_vanilla.sqf": ("vanilla", "mil"),
    "mil_other.sqf": ("vanilla", "mil"),
    "civ_vanilla.sqf": ("vanilla", "civ"),
    "cbrn_vanilla.sqf": ("vanilla", "cbrn"),
    "mil_cup.sqf": ("cup", "mil"),
    "civ_cup.sqf": ("cup", "civ"),
    "mil_gm.sqf": ("gm", "mil"),
    "civ_gm.sqf": ("gm", "civ"),
    "mil_sog.sqf": ("sog", "mil"),
    "mil_ws.sqf": ("ws", "mil"),
    "civ_ws.sqf": ("ws", "civ"),
    "optre_military.sqf": ("optre", "optre_mil"),
    "optre_civilian.sqf": ("optre", "optre_civ"),
}

# Categories that only exist with their template addon (core defines mil, civ and cbrn)
ADDON_CATEGORIES = {
    "optre": {
        "optre_mil": ('"OPTRE - Military"', 40),
        "optre_civ": ('"OPTRE - Civilian"', 50),
    },
}

IDENTIFIER = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


class ConvertError(Exception):
    pass


# ---------------------------------------------------------------- parsing

def strip_comments(text):
    """Remove // and /* */ comments outside of strings."""
    out = []
    i = 0
    in_string = False
    while i < len(text):
        c = text[i]
        if in_string:
            out.append(c)
            if c == '"':
                if text[i + 1:i + 2] == '"':  # escaped quote ""
                    out.append('"')
                    i += 1
                else:
                    in_string = False
            i += 1
        elif c == '"':
            in_string = True
            out.append(c)
            i += 1
        elif text.startswith("//", i):
            end = text.find("\n", i)
            i = len(text) if end == -1 else end
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end == -1:
                raise ConvertError("unterminated /* comment")
            i = end + 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


TOKEN = re.compile(r'\s*(?:(?P<str>"(?:[^"]|"")*")|(?P<num>-?\d+(?:\.\d*)?(?:[eE][-+]?\d+)?|-?\.\d+)|(?P<sym>[\[\],;:{}])|(?P<word>[A-Za-z_][A-Za-z0-9_]*))')


TRAILING_SPACE = re.compile(r"\s*\Z")


def tokenize(text):
    pos = 0
    line = 1
    line_pos = 0  # position up to which newlines have been counted
    tokens = []
    while not TRAILING_SPACE.match(text, pos):
        m = TOKEN.match(text, pos)
        if not m:
            line += text.count("\n", line_pos, pos)
            raise ConvertError(f"unexpected character {text[pos:pos + 20]!r} on line {line}")
        kind = m.lastgroup
        start = m.start(kind)
        line += text.count("\n", line_pos, start)
        line_pos = start
        tokens.append((kind, m.group(kind), line))
        pos = m.end()
    return tokens


class Parser:
    def __init__(self, tokens, source):
        self.tokens = tokens
        self.pos = 0
        self.source = source

    def peek(self):
        return self.tokens[self.pos] if self.pos < len(self.tokens) else (None, None, None)

    def take(self, value=None, kind=None):
        tok = self.peek()
        if tok[0] is None:
            raise ConvertError(f"{self.source}: unexpected end of file")
        if (value is not None and tok[1] != value) or (kind is not None and tok[0] != kind):
            raise ConvertError(f"{self.source}:{tok[2]}: expected {value or kind}, got {tok[1]!r}")
        self.pos += 1
        return tok

    def array(self):
        """SQF array literal -> nested Python list of ("str"/"num", text) leaves."""
        self.take("[")
        items = []
        if self.peek()[1] == "]":
            self.take("]")
            return items
        while True:
            if self.peek()[1] == "[":
                items.append(self.array())
            else:
                kind, value, _ = self.peek()
                if kind not in ("str", "num"):
                    raise ConvertError(f"{self.source}:{self.peek()[2]}: unexpected {value!r} in array")
                self.pos += 1
                items.append((kind, value))
            if self.peek()[1] == ",":
                self.take(",")
                if self.peek()[1] == "]":  # trailing comma
                    break
                continue
            break
        self.take("]")
        return items

    def cases(self, warnings):
        """Yield (building names, list of templates) for every case block."""
        pending = []
        while self.peek()[0] is not None:
            _, word, line = self.take(kind="word")
            if word != "case":
                raise ConvertError(f"{self.source}:{line}: expected 'case', got {word!r}")
            name = self.take(kind="str")[1][1:-1].replace('""', '"')
            pending.append((name, line))
            if self.peek()[1] == ";":
                self.take(";")
                if self.peek()[1] != "{":
                    continue
                # `case "X"; {` - in SQF the block isn't attached to the case, so it fell through to the next one
                warnings.append(f"{self.source}:{line}: 'case \"{name}\";' followed by a block (typo for ':'), treated as ':'")
            else:
                self.take(":")
            self.take("{")
            templates = self.array()
            if self.peek()[1] == ";":  # optional ; after the array
                self.take(";")
            self.take("}")
            self.take(";")
            yield pending, templates
            pending = []
        if pending:
            raise ConvertError(f"{self.source}:{pending[-1][1]}: case without a body at the end of the file")


def check_entry(entry, where):
    """[class, [x,y,z], dir?, [rx,ry,rz]?]"""
    if not isinstance(entry, list) or not 2 <= len(entry) <= 4:
        raise ConvertError(f"{where}: object entry must have 2-4 elements: {entry}")
    if entry[0] == () or not isinstance(entry[0], tuple) or entry[0][0] != "str":
        raise ConvertError(f"{where}: first element must be a class name: {entry}")
    for index in (1, 3):
        if len(entry) > index:
            vec = entry[index]
            if not (isinstance(vec, list) and len(vec) == 3 and all(isinstance(v, tuple) and v[0] == "num" for v in vec)):
                raise ConvertError(f"{where}: element {index} must be [x, y, z]: {entry}")
    if len(entry) > 2 and not (isinstance(entry[2], tuple) and entry[2][0] == "num"):
        raise ConvertError(f"{where}: direction must be a number: {entry}")


# ---------------------------------------------------------------- output

def config_value(value):
    if isinstance(value, tuple):
        return value[1]
    return "{" + ", ".join(config_value(v) for v in value) + "}"


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--check", action="store_true", help="only parse and print statistics, write nothing")
    args = parser.parse_args()

    # addon -> category -> building -> list of templates
    data = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    # addon -> category -> alias building -> parent building
    aliases = defaultdict(lambda: defaultdict(dict))
    # addon -> category -> lower-case building -> file it was first listed in
    first_seen = defaultdict(lambda: defaultdict(dict))
    warnings = []
    source_stats = {}

    for file_name, (addon, category) in SOURCES.items():
        path = SOURCE_DIR / file_name
        if not path.exists():
            warnings.append(f"{file_name}: missing, skipped")
            continue
        tokens = tokenize(strip_comments(path.read_text(encoding="utf-8")))
        cases = templates_total = objects_total = 0

        for names, templates in Parser(tokens, file_name).cases(warnings):
            clean = []
            for name, line in names:
                stripped = name.strip()
                if stripped != name:
                    warnings.append(f"{file_name}:{line}: building class {name!r} had surrounding spaces (it could never match), fixed")
                if not IDENTIFIER.match(stripped):
                    raise ConvertError(f"{file_name}:{line}: {stripped!r} is not a valid config class name")
                clean.append(stripped)
            cases += len(clean)

            for t_index, template in enumerate(templates):
                if not isinstance(template, list):
                    raise ConvertError(f"{file_name}: building {clean[-1]}: template {t_index + 1} is not an array")
                for entry in template:
                    check_entry(entry, f"{file_name}: building {clean[-1]}, template {t_index + 1}")
                objects_total += len(template)
            templates_total += len(templates)

            # A building listed more than once only ever matched its first case in the SQF switch: keep that one.
            seen = first_seen[addon][category]
            group = []
            for name in clean:
                if name.lower() in seen:
                    warnings.append(f"{file_name}: {name} is listed again (first in {seen[name.lower()]}), the later entry never matched and is dropped")
                    continue
                seen[name.lower()] = file_name
                group.append(name)

            if not group:
                # Same as the duplicate cases merged in #30: keep the templates as extra variants of the first entry.
                first = next(n for n in data[addon][category] if n.lower() == clean[-1].lower()) if any(n.lower() == clean[-1].lower() for n in data[addon][category]) else None
                if first is None:
                    first = aliases[addon][category][next(a for a in aliases[addon][category] if a.lower() == clean[-1].lower())]
                warnings.append(f"{file_name}: case group ending with {clean[-1]} only lists buildings matched earlier, its {len(templates)} template(s) never matched: added as extra variants of {first}")
                data[addon][category][first].extend(templates)
                continue

            # The building with the body holds the templates, the fall-through ones inherit from it.
            holder = group[-1]
            data[addon][category][holder].extend(templates)
            for alias in group[:-1]:
                aliases[addon][category][alias] = holder

        source_stats[file_name] = (cases, templates_total, objects_total)

    # Config class names are case-insensitive.
    for addon in data:
        for category in data[addon]:
            seen = {}
            for name in list(data[addon][category]) + list(aliases[addon][category]):
                if name.lower() in seen and seen[name.lower()] != name:
                    raise ConvertError(f"{addon}/{category}: {name} and {seen[name.lower()]} differ only in case")
                seen[name.lower()] = name

    # ---- statistics
    print(f"{'source':<22} {'cases':>6} {'templates':>10} {'objects':>8}")
    for file_name, (cases, templates, objects) in source_stats.items():
        print(f"{file_name:<22} {cases:>6} {templates:>10} {objects:>8}")
    print()
    print(f"{'addon/category':<22} {'buildings':>10} {'inherit':>8} {'templates':>10} {'objects':>8}")
    for addon in sorted(data):
        for category in sorted(data[addon]):
            buildings = data[addon][category]
            n_templates = sum(len(t) for t in buildings.values())
            n_objects = sum(len(tpl) for t in buildings.values() for tpl in t)
            print(f"{addon + '/' + category:<22} {len(buildings):>10} {len(aliases[addon][category]):>8} {n_templates:>10} {n_objects:>8}")
    for warning in warnings:
        print("WARNING:", warning)

    if args.check:
        return 0

    # ---- write
    for addon in sorted(data):
        lines = [
            "// Interior templates, converted from the former SQF templates by tools/convert_templates.py. Edit this file directly.",
            "class CfgZEIC {",
        ]
        for category in sorted(data[addon]):
            lines.append(f"    class {category} {{")
            if category in ADDON_CATEGORIES.get(addon, {}):
                display_name, order = ADDON_CATEGORIES[addon][category]
                lines.append(f"        displayName = {display_name};")
                lines.append(f"        order = {order};")
                lines.append("")
            for building in sorted(data[addon][category], key=str.lower):
                lines.append(f"        class {building} {{")
                for t_index, template in enumerate(data[addon][category][building], start=1):
                    lines.append(f"            class {addon}_{t_index} {{")
                    lines.append("                objects[] = {")
                    for o_index, entry in enumerate(template):
                        comma = "," if o_index < len(template) - 1 else ""
                        lines.append(f"                    {config_value(entry)}{comma}")
                    lines.append("                };")
                    lines.append("            };")
                lines.append("        };")
            for alias in sorted(aliases[addon][category], key=str.lower):
                lines.append(f"        class {alias}: {aliases[addon][category][alias]} {{}};")
            lines.append("    };")
        lines.append("};")
        lines.append("")

        out = ROOT / "addons" / f"templates_{addon}" / "CfgZEIC.hpp"
        if not out.parent.exists():
            raise ConvertError(f"{out.parent} doesn't exist - create the addon first (config.cpp, script_component.hpp, $PBOPREFIX$)")
        out.write_text("\n".join(lines), encoding="utf-8", newline="\n")
        print(f"wrote {out.relative_to(ROOT)}")

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except ConvertError as error:
        print("ERROR:", error, file=sys.stderr)
        sys.exit(1)
