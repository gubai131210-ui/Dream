#!/usr/bin/env python3
"""Synthesize modular 32px interior foundation tiles matching outdoor cottage palette.

Outputs under assets/sprites/interior/tiles/ for InteriorCraft TileMap-style assembly.
Does not paste outdoor grass/dirt atlases as indoor floors.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "tiles"
TILE = 32

# Palette sampled to match outdoor cottage (building_00): cream walls, warm wood.
CREAM = [(236, 220, 190), (224, 206, 172), (210, 190, 155), (196, 174, 138)]
WOOD_DK = [(92, 58, 36), (110, 72, 44), (78, 48, 30), (128, 86, 52)]
WOOD_FL = [(148, 104, 62), (132, 92, 54), (164, 118, 72), (120, 82, 48), (156, 110, 66)]
STONE = [(140, 140, 148), (120, 120, 128), (160, 158, 152), (100, 100, 108)]
RUG = [(210, 190, 150), (198, 176, 136), (120, 150, 90), (90, 120, 70)]
OUTLINE = (48, 32, 22, 255)


def _px(img: Image.Image, x: int, y: int, rgb, a: int = 255) -> None:
    if 0 <= x < img.width and 0 <= y < img.height:
        c = rgb if len(rgb) == 4 else (*rgb, a)
        img.putpixel((x, y), c)


def floor_tile(seed: int) -> Image.Image:
    rng = np.random.default_rng(seed)
    im = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    band_h = 8
    for by in range(0, TILE, band_h):
        base = WOOD_FL[int(rng.integers(0, len(WOOD_FL)))]
        for y in range(by, min(by + band_h, TILE)):
            for x in range(TILE):
                shade = int(rng.integers(-8, 9))
                col = tuple(max(0, min(255, c + shade)) for c in base)
                # plank seam
                if x in (0, TILE - 1) or (y - by) == 0:
                    col = tuple(max(0, c - 22) for c in col)
                _px(im, x, y, col)
                if rng.random() < 0.02 and 2 < x < TILE - 2:
                    _px(im, x, y, (40, 28, 18))  # nail
    return im


def wall_upper(seed: int) -> Image.Image:
    rng = np.random.default_rng(seed + 40)
    im = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    for x in range(TILE):
        base = CREAM[x % len(CREAM)]
        for y in range(TILE):
            shade = int(rng.integers(-6, 7))
            col = tuple(max(0, min(255, c + shade)) for c in base)
            if x % 8 == 0:
                col = tuple(max(0, c - 18) for c in col)
            if y == 0 or y == TILE - 1:
                col = tuple(max(0, c - 12) for c in col)
            _px(im, x, y, col)
    return im


def wall_lower(seed: int) -> Image.Image:
    rng = np.random.default_rng(seed + 80)
    im = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    for x in range(TILE):
        base = WOOD_DK[x % len(WOOD_DK)]
        for y in range(TILE):
            shade = int(rng.integers(-8, 8))
            col = tuple(max(0, min(255, c + shade)) for c in base)
            if x % 6 == 0:
                col = tuple(max(0, c - 20) for c in col)
            _px(im, x, y, col)
    return im


def pillar() -> Image.Image:
    im = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    for y in range(TILE):
        for x in range(8, 24):
            base = WOOD_DK[(x + y) % len(WOOD_DK)]
            col = list(base)
            if x in (8, 23):
                col = [max(0, c - 30) for c in col]
            if x in (14, 15):
                col = [min(255, c + 18) for c in col]
            _px(im, x, y, tuple(col))
    return im


def stone_step() -> Image.Image:
    rng = np.random.default_rng(3)
    im = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    for y in range(TILE):
        for x in range(TILE):
            base = STONE[int(rng.integers(0, len(STONE)))]
            if y < 4 or y > TILE - 5 or x < 2 or x > TILE - 3:
                base = tuple(max(0, c - 25) for c in base)
            _px(im, x, y, base)
    return im


def rug_tile(qx: int, qy: int) -> Image.Image:
    """2x2 rug quarters; qx,qy in {0,1}."""
    im = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    for y in range(TILE):
        for x in range(TILE):
            base = RUG[0] if ((x // 4) + (y // 4)) % 2 == 0 else RUG[1]
            # fringe on outer edges of the 2x2
            edge = (
                (qy == 0 and y < 2)
                or (qy == 1 and y > TILE - 3)
                or (qx == 0 and x < 2)
                or (qx == 1 and x > TILE - 3)
            )
            if edge:
                base = RUG[1]
            # leaf corners
            if (qx, qy) == (0, 0) and x < 10 and y < 10 and (x - 4) ** 2 + (y - 4) ** 2 < 16:
                base = RUG[2]
            if (qx, qy) == (1, 0) and x > 21 and y < 10 and (x - 27) ** 2 + (y - 4) ** 2 < 16:
                base = RUG[3]
            if (qx, qy) == (0, 1) and x < 10 and y > 21 and (x - 4) ** 2 + (y - 27) ** 2 < 16:
                base = RUG[3]
            if (qx, qy) == (1, 1) and x > 21 and y > 21 and (x - 27) ** 2 + (y - 27) ** 2 < 16:
                base = RUG[2]
            _px(im, x, y, base)
    return im


def window_frame() -> Image.Image:
    im = Image.new("RGBA", (TILE * 2, TILE * 2), (0, 0, 0, 0))
    # outer wood frame
    for y in range(TILE * 2):
        for x in range(TILE * 2):
            in_frame = x < 4 or x >= TILE * 2 - 4 or y < 4 or y >= TILE * 2 - 4
            cross = abs(x - TILE) < 2 or abs(y - TILE) < 2
            if in_frame or cross:
                base = WOOD_DK[(x + y) % len(WOOD_DK)]
                _px(im, x, y, base)
            elif 6 <= x < TILE * 2 - 6 and 6 <= y < TILE * 2 - 6:
                # cool glass hint
                g = 40 + (x + y) % 20
                _px(im, x, y, (90, 130, 150, 180))
    return im


def bed_sprite() -> Image.Image:
    """Simple top-down bed matching wood + linen, ~96x64."""
    w, h = 96, 64
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    # frame
    for y in range(8, h - 4):
        for x in range(4, w - 4):
            _px(im, x, y, WOOD_DK[(x // 8) % len(WOOD_DK)])
    # mattress
    for y in range(12, h - 10):
        for x in range(10, w - 10):
            _px(im, x, y, (220, 210, 190))
    # blanket
    for y in range(12, h - 10):
        for x in range(10, 52):
            _px(im, x, y, (170, 90, 78) if (x + y) % 5 else (158, 82, 70))
    # pillow
    for y in range(16, 36):
        for x in range(58, 84):
            _px(im, x, y, (235, 225, 205))
    return im


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for i in range(4):
        floor_tile(10 + i).save(OUT / f"floor_{i:02d}.png")
        wall_upper(20 + i).save(OUT / f"wall_upper_{i:02d}.png")
        wall_lower(30 + i).save(OUT / f"wall_lower_{i:02d}.png")
    pillar().save(OUT / "pillar_00.png")
    stone_step().save(OUT / "doorstep_00.png")
    for qy in range(2):
        for qx in range(2):
            rug_tile(qx, qy).save(OUT / f"rug_{qy}_{qx}.png")
    window_frame().save(OUT / "window_00.png")
    bed_sprite().save(OUT / "bed_00.png")
    # atlas preview
    atlas = Image.new("RGBA", (TILE * 8, TILE * 4), (0, 0, 0, 255))
    files = sorted(OUT.glob("*.png"))
    for i, f in enumerate(files[:32]):
        tile = Image.open(f).convert("RGBA")
        if tile.size != (TILE, TILE):
            continue
        ax, ay = (i % 8) * TILE, (i // 8) * TILE
        atlas.paste(tile, (ax, ay), tile)
    atlas.save(OUT / "atlas_preview.png")
    print(f"wrote {len(list(OUT.glob('*.png')))} files -> {OUT}")


if __name__ == "__main__":
    main()
