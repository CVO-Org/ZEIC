"""Generate the UI textures of the ZEIC dialogs (rounded corners, circle) as PAA.

White shapes with an anti-aliased alpha channel; the dialogs tint them with the control's text colour.
Run from the repository root (needs Pillow and HEMTT):
    python tools/make_ui_textures.py
"""

import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "addons" / "core" / "ui" / "data"
SUPERSAMPLE = 8


def shape(size, inside):
    """White image whose alpha is the share of each pixel that lies inside the shape (supersampled)."""
    image = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    pixels = image.load()
    step = 1 / SUPERSAMPLE
    for y in range(size):
        for x in range(size):
            hits = 0
            for sy in range(SUPERSAMPLE):
                for sx in range(SUPERSAMPLE):
                    if inside(x + (sx + 0.5) * step, y + (sy + 0.5) * step):
                        hits += 1
            pixels[x, y] = (255, 255, 255, round(255 * hits / SUPERSAMPLE ** 2))
    return image


def quarter(size, cx, cy):
    """Quarter circle of radius `size` around the corner (cx, cy) of the tile."""
    return lambda x, y: (x - cx) ** 2 + (y - cy) ** 2 <= size ** 2


def main():
    corner = 64
    circle = 128
    textures = {
        # The rounded corner sits in the tile's outer corner, the circle's center in the inner one.
        "corner_tl_ca": shape(corner, quarter(corner, corner, corner)),
        "corner_tr_ca": shape(corner, quarter(corner, 0, corner)),
        "corner_bl_ca": shape(corner, quarter(corner, corner, 0)),
        "corner_br_ca": shape(corner, quarter(corner, 0, 0)),
        "circle_ca": shape(circle, lambda x, y: (x - circle / 2) ** 2 + (y - circle / 2) ** 2 <= (circle / 2) ** 2),
    }

    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for name, image in textures.items():
            png = Path(tmp) / f"{name}.png"
            image.save(png)
            paa = OUT / f"{name}.paa"
            subprocess.run(["hemtt", "utils", "paa", "convert", str(png), str(paa)], check=True)
            print("wrote", paa.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    sys.exit(main())
