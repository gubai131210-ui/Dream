#!/usr/bin/env python3
"""Generate Dream interior specialty props, floor sets, and FX sheets.

Palette locked to outdoor cottage (cream / warm wood) — see make_interior_foundation.py.
Outputs:
  assets/sprites/interior/props/*.png
  assets/sprites/interior/tiles/floor_{straw,stone,dark}_*.png
  assets/sprites/interior/fx/{fire,forge}_*.png
  assets/sprites/animals/chicken/*.png  (simple coop ambient)
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
PROP = ROOT / "assets" / "sprites" / "interior" / "props"
TILE = ROOT / "assets" / "sprites" / "interior" / "tiles"
FX = ROOT / "assets" / "sprites" / "interior" / "fx"
CHICKEN = ROOT / "assets" / "sprites" / "animals" / "chicken"

CREAM = (236, 220, 190, 255)
WOOD = (132, 92, 54, 255)
WOOD_DK = (78, 48, 30, 255)
WOOD_LT = (164, 118, 72, 255)
STONE = (130, 128, 122, 255)
STONE_DK = (90, 88, 84, 255)
STRAW = (186, 158, 78, 255)
STRAW_DK = (150, 120, 50, 255)
IRON = (70, 72, 78, 255)
FIRE = [(255, 200, 60), (255, 140, 40), (255, 80, 30), (220, 50, 20)]
OUTLINE = (40, 28, 18, 255)
GREEN = (90, 130, 70, 255)
RED = (180, 70, 60, 255)
CLOTH = (120, 90, 140, 255)
GOLD = (210, 170, 70, 255)


def save(im: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)
    print("wrote", path.relative_to(ROOT))


def blank(w: int, h: int) -> Image.Image:
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def rect(d: ImageDraw.ImageDraw, box, fill, outline=OUTLINE) -> None:
    d.rectangle(box, fill=fill, outline=outline)


def ellipse(d: ImageDraw.ImageDraw, box, fill, outline=OUTLINE) -> None:
    d.ellipse(box, fill=fill, outline=outline)


# --- floors -----------------------------------------------------------------


def floor_straw(seed: int) -> Image.Image:
    rng = np.random.default_rng(seed)
    im = blank(32, 32)
    px = im.load()
    for y in range(32):
        for x in range(32):
            base = STRAW if (x + y * 2 + seed) % 5 else STRAW_DK
            shade = int(rng.integers(-12, 13))
            c = tuple(max(0, min(255, v + shade)) for v in base[:3]) + (255,)
            if rng.random() < 0.08:
                c = (max(0, c[0] - 30), max(0, c[1] - 20), max(0, c[2] - 10), 255)
            px[x, y] = c
    return im


def floor_stone(seed: int) -> Image.Image:
    rng = np.random.default_rng(seed + 20)
    im = blank(32, 32)
    px = im.load()
    for y in range(32):
        for x in range(32):
            cell = ((x // 8) + (y // 8) + seed) % 2
            base = STONE if cell == 0 else STONE_DK
            shade = int(rng.integers(-10, 11))
            c = tuple(max(0, min(255, v + shade)) for v in base[:3]) + (255,)
            if x % 8 == 0 or y % 8 == 0:
                c = tuple(max(0, v - 25) for v in c[:3]) + (255,)
            px[x, y] = c
    return im


def floor_dark(seed: int) -> Image.Image:
    rng = np.random.default_rng(seed + 40)
    im = blank(32, 32)
    px = im.load()
    for by in range(0, 32, 8):
        for y in range(by, min(by + 8, 32)):
            for x in range(32):
                base = WOOD_DK if (x // 10 + by // 8) % 2 == 0 else (60, 38, 24, 255)
                shade = int(rng.integers(-8, 9))
                c = tuple(max(0, min(255, v + shade)) for v in base[:3]) + (255,)
                if x in (0, 31) or y == by:
                    c = tuple(max(0, v - 18) for v in c[:3]) + (255,)
                px[x, y] = c
    return im


# --- props ------------------------------------------------------------------


def prop_fireplace() -> Image.Image:
    im = blank(48, 56)
    d = ImageDraw.Draw(im)
    rect(d, (4, 8, 43, 54), STONE_DK)
    rect(d, (10, 14, 37, 42), (30, 24, 22, 255))
    rect(d, (8, 44, 39, 54), WOOD_DK)
    # mantle
    rect(d, (2, 6, 45, 12), WOOD)
    return im


def prop_forge() -> Image.Image:
    im = blank(56, 48)
    d = ImageDraw.Draw(im)
    rect(d, (4, 18, 51, 46), STONE_DK)
    rect(d, (12, 8, 43, 36), IRON)
    rect(d, (16, 12, 39, 32), (40, 30, 28, 255))
    # chimney stub
    rect(d, (22, 2, 33, 12), STONE)
    return im


def prop_anvil() -> Image.Image:
    im = blank(40, 28)
    d = ImageDraw.Draw(im)
    rect(d, (14, 16, 25, 26), WOOD_DK)
    rect(d, (4, 8, 35, 18), IRON)
    rect(d, (28, 10, 38, 16), IRON)
    return im


def prop_stove() -> Image.Image:
    im = blank(40, 40)
    d = ImageDraw.Draw(im)
    rect(d, (4, 10, 35, 38), IRON)
    rect(d, (8, 14, 31, 28), (50, 48, 52, 255))
    ellipse(d, (12, 16, 20, 24), (30, 28, 30, 255))
    ellipse(d, (22, 16, 30, 24), (30, 28, 30, 255))
    rect(d, (16, 2, 23, 12), STONE_DK)  # pipe
    return im


def prop_shelf() -> Image.Image:
    im = blank(48, 56)
    d = ImageDraw.Draw(im)
    rect(d, (2, 4, 45, 54), WOOD_DK)
    for y in (14, 28, 42):
        rect(d, (4, y, 43, y + 3), WOOD_LT)
    # jars
    for i, col in enumerate([(180, 70, 60, 255), (70, 120, 160, 255), (200, 180, 80, 255)]):
        x = 8 + i * 12
        rect(d, (x, 18, x + 8, 26), col)
        rect(d, (x + 2, 32, x + 10, 40), GREEN)
    return im


def prop_counter() -> Image.Image:
    im = blank(64, 32)
    d = ImageDraw.Draw(im)
    rect(d, (2, 8, 61, 30), WOOD)
    rect(d, (2, 4, 61, 12), WOOD_LT)
    rect(d, (4, 14, 20, 28), WOOD_DK)  # under shelf
    return im


def prop_bar() -> Image.Image:
    im = blank(72, 36)
    d = ImageDraw.Draw(im)
    rect(d, (2, 10, 69, 34), WOOD_DK)
    rect(d, (2, 4, 69, 14), WOOD)
    # brass rail hint
    rect(d, (4, 28, 67, 31), GOLD)
    return im


def prop_table_round() -> Image.Image:
    im = blank(40, 36)
    d = ImageDraw.Draw(im)
    ellipse(d, (2, 4, 37, 28), WOOD)
    rect(d, (16, 24, 23, 34), WOOD_DK)
    return im


def prop_stool() -> Image.Image:
    im = blank(20, 22)
    d = ImageDraw.Draw(im)
    ellipse(d, (2, 2, 17, 10), WOOD_LT)
    rect(d, (4, 10, 7, 20), WOOD_DK)
    rect(d, (12, 10, 15, 20), WOOD_DK)
    return im


def prop_hay() -> Image.Image:
    im = blank(36, 28)
    d = ImageDraw.Draw(im)
    rect(d, (2, 6, 33, 26), STRAW)
    for y in (10, 16, 22):
        d.line([(4, y), (31, y)], fill=STRAW_DK, width=1)
    rect(d, (14, 2, 21, 8), (160, 100, 50, 255))  # twine
    return im


def prop_trough() -> Image.Image:
    im = blank(48, 24)
    d = ImageDraw.Draw(im)
    rect(d, (2, 6, 45, 22), WOOD_DK)
    rect(d, (6, 8, 41, 18), (90, 110, 140, 255))  # water
    return im


def prop_nest() -> Image.Image:
    im = blank(32, 28)
    d = ImageDraw.Draw(im)
    rect(d, (2, 8, 29, 26), WOOD)
    ellipse(d, (6, 10, 25, 22), STRAW)
    ellipse(d, (12, 12, 18, 18), (240, 220, 160, 255))  # egg
    return im


def prop_tool_rack() -> Image.Image:
    im = blank(40, 48)
    d = ImageDraw.Draw(im)
    rect(d, (4, 4, 35, 10), WOOD_DK)
    rect(d, (4, 40, 35, 46), WOOD_DK)
    # tools
    d.line([(12, 8), (12, 42)], fill=IRON, width=2)
    d.line([(20, 8), (20, 38)], fill=IRON, width=2)
    ellipse(d, (16, 6, 24, 14), IRON)
    d.line([(28, 10), (28, 40)], fill=WOOD, width=3)
    return im


def prop_dresser() -> Image.Image:
    im = blank(40, 44)
    d = ImageDraw.Draw(im)
    rect(d, (4, 4, 35, 42), WOOD)
    for y in (12, 22, 32):
        rect(d, (8, y, 31, y + 8), WOOD_DK)
        ellipse(d, (18, y + 2, 22, y + 6), GOLD)
    return im


def prop_medicine() -> Image.Image:
    im = blank(32, 36)
    d = ImageDraw.Draw(im)
    rect(d, (4, 4, 27, 34), WOOD_LT)
    rect(d, (8, 10, 23, 28), CREAM)
    # cross
    rect(d, (14, 14, 17, 24), RED)
    rect(d, (11, 17, 20, 20), RED)
    return im


def prop_ledger() -> Image.Image:
    im = blank(44, 32)
    d = ImageDraw.Draw(im)
    rect(d, (2, 8, 41, 30), WOOD)
    rect(d, (8, 4, 28, 18), (220, 210, 190, 255))  # paper
    d.line([(10, 8), (26, 8)], fill=WOOD_DK, width=1)
    d.line([(10, 12), (24, 12)], fill=WOOD_DK, width=1)
    ellipse(d, (30, 10, 38, 18), GOLD)  # ink pot
    return im


def prop_basket() -> Image.Image:
    im = blank(28, 24)
    d = ImageDraw.Draw(im)
    ellipse(d, (2, 8, 25, 22), WOOD_LT)
    rect(d, (6, 4, 21, 12), STRAW)
    # produce
    ellipse(d, (8, 6, 14, 12), (200, 80, 50, 255))
    ellipse(d, (14, 6, 20, 12), (80, 140, 60, 255))
    return im


def prop_notice() -> Image.Image:
    im = blank(28, 36)
    d = ImageDraw.Draw(im)
    rect(d, (2, 2, 25, 34), WOOD_DK)
    rect(d, (5, 5, 22, 30), (230, 220, 190, 255))
    for y in (10, 16, 22):
        d.line([(7, y), (20, y)], fill=WOOD_DK, width=1)
    return im


def prop_mug_shelf() -> Image.Image:
    im = blank(40, 40)
    d = ImageDraw.Draw(im)
    rect(d, (2, 4, 37, 38), WOOD_DK)
    rect(d, (4, 18, 35, 21), WOOD)
    for i in range(3):
        x = 8 + i * 10
        ellipse(d, (x, 8, x + 7, 16), CREAM)
        rect(d, (x + 6, 10, x + 9, 14), CREAM)
    return im


def prop_hearth_cauldron() -> Image.Image:
    im = blank(28, 28)
    d = ImageDraw.Draw(im)
    ellipse(d, (4, 8, 23, 26), IRON)
    rect(d, (10, 2, 17, 12), IRON)
    return im


def prop_roost() -> Image.Image:
    im = blank(48, 20)
    d = ImageDraw.Draw(im)
    rect(d, (2, 8, 45, 14), WOOD)
    rect(d, (4, 4, 8, 18), WOOD_DK)
    rect(d, (39, 4, 43, 18), WOOD_DK)
    return im


def prop_coin_chest() -> Image.Image:
    im = blank(32, 28)
    d = ImageDraw.Draw(im)
    rect(d, (4, 10, 27, 26), WOOD)
    rect(d, (4, 4, 27, 14), WOOD_LT)
    ellipse(d, (14, 12, 18, 16), GOLD)
    return im


def prop_herbs() -> Image.Image:
    im = blank(24, 32)
    d = ImageDraw.Draw(im)
    d.line([(12, 2), (12, 16)], fill=WOOD_DK, width=2)
    for dx, col in [(-6, GREEN), (0, (70, 110, 50, 255)), (6, GREEN)]:
        ellipse(d, (10 + dx, 14, 16 + dx, 28), col)
    return im


def prop_bed_single() -> Image.Image:
    im = blank(48, 40)
    d = ImageDraw.Draw(im)
    rect(d, (2, 10, 45, 38), WOOD_DK)
    rect(d, (4, 12, 43, 34), CLOTH)
    rect(d, (4, 12, 18, 24), CREAM)  # pillow
    return im


def prop_bed_double() -> Image.Image:
    im = blank(64, 44)
    d = ImageDraw.Draw(im)
    rect(d, (2, 10, 61, 42), WOOD_DK)
    rect(d, (4, 12, 59, 38), (100, 120, 150, 255))
    rect(d, (6, 12, 24, 24), CREAM)
    rect(d, (28, 12, 46, 24), CREAM)
    return im


def prop_rocking() -> Image.Image:
    im = blank(32, 36)
    d = ImageDraw.Draw(im)
    rect(d, (6, 10, 25, 26), WOOD)
    rect(d, (8, 4, 23, 14), WOOD_LT)
    d.arc([(2, 24), (29, 34)], 0, 180, fill=WOOD_DK, width=2)
    return im


# --- FX frames --------------------------------------------------------------


def fire_frame(i: int) -> Image.Image:
    rng = np.random.default_rng(100 + i)
    im = blank(24, 28)
    d = ImageDraw.Draw(im)
    base_y = 24 - (i % 3)
    for k in range(5):
        col = FIRE[(i + k) % len(FIRE)] + (230,)
        w = 4 + (k + i) % 3
        x = 6 + k * 3 + int(rng.integers(-1, 2))
        h = 10 + (k + i) % 5
        ellipse(d, (x, base_y - h, x + w, base_y), col)
    return im


def forge_frame(i: int) -> Image.Image:
    im = blank(28, 20)
    d = ImageDraw.Draw(im)
    glow = FIRE[i % len(FIRE)] + (200,)
    ellipse(d, (4, 4, 23, 16), glow)
    hot = (255, 240, 180, 230)
    ellipse(d, (8, 6, 19, 14), hot)
    # spark
    if i % 2 == 0:
        d.point((20, 4), fill=(255, 220, 100, 255))
        d.point((6, 5), fill=(255, 180, 80, 255))
    return im


# --- chicken ----------------------------------------------------------------


def chicken_idle(i: int) -> Image.Image:
    im = blank(24, 20)
    d = ImageDraw.Draw(im)
    body = (240, 230, 210, 255)
    ellipse(d, (4, 6, 18, 18), body)
    ellipse(d, (14, 4, 22, 12), body)
    # comb
    rect(d, (16, 2, 20, 6), RED)
    # beak
    d.polygon([(22, 7), (26, 8), (22, 9)], fill=GOLD)
    # leg bob
    ly = 16 + (i % 2)
    d.line([(10, 16), (10, ly + 3)], fill=GOLD, width=1)
    d.line([(14, 16), (14, ly + 2)], fill=GOLD, width=1)
    return im


def main() -> None:
    for i in range(4):
        save(floor_straw(i), TILE / f"floor_straw_{i:02d}.png")
        save(floor_stone(i), TILE / f"floor_stone_{i:02d}.png")
        save(floor_dark(i), TILE / f"floor_dark_{i:02d}.png")
        save(fire_frame(i), FX / f"fire_{i:02d}.png")
        save(forge_frame(i), FX / f"forge_{i:02d}.png")
        save(chicken_idle(i), CHICKEN / f"idle_{i}.png")

    props = {
        "fireplace_00.png": prop_fireplace,
        "forge_00.png": prop_forge,
        "anvil_00.png": prop_anvil,
        "stove_00.png": prop_stove,
        "shelf_00.png": prop_shelf,
        "counter_00.png": prop_counter,
        "bar_00.png": prop_bar,
        "table_round_00.png": prop_table_round,
        "stool_00.png": prop_stool,
        "hay_00.png": prop_hay,
        "trough_00.png": prop_trough,
        "nest_00.png": prop_nest,
        "tool_rack_00.png": prop_tool_rack,
        "dresser_00.png": prop_dresser,
        "medicine_00.png": prop_medicine,
        "ledger_00.png": prop_ledger,
        "basket_00.png": prop_basket,
        "notice_00.png": prop_notice,
        "mug_shelf_00.png": prop_mug_shelf,
        "cauldron_00.png": prop_hearth_cauldron,
        "roost_00.png": prop_roost,
        "coin_chest_00.png": prop_coin_chest,
        "herbs_00.png": prop_herbs,
        "bed_single_00.png": prop_bed_single,
        "bed_double_00.png": prop_bed_double,
        "rocking_00.png": prop_rocking,
    }
    for name, fn in props.items():
        save(fn(), PROP / name)

    print("done specialty interiors")


if __name__ == "__main__":
    main()
