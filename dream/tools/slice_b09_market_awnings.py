#!/usr/bin/env python3
"""Slice raw/B09-04_awnings.png (6x6) into sprites/market/ for Stall-C05 art upgrade."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "raw" / "B09-04_awnings.png"
OUT = ROOT / "assets" / "sprites" / "market"
COLS, ROWS = 6, 6
BLACK_T = 18
TARGET_H = 96

# Semantic names for freestanding stall row (row index 4) + useful awnings.
NAMES = {
	(4, 0): "stall_open_redstripe_00",
	(4, 1): "stall_open_bluestripe_00",
	(4, 2): "stall_open_cream_00",
	(4, 3): "stall_open_green_00",
	(4, 4): "stall_open_patched_00",
	(4, 5): "stall_open_wood_00",
	(1, 2): "awning_drape_cream_00",  # draped — closed-ish cue
	(1, 3): "awning_drape_blue_00",
	(0, 0): "awning_wall_redstripe_00",
	(0, 1): "awning_wall_bluestripe_00",
}


def punch_black(im: Image.Image) -> Image.Image:
	a = np.array(im.convert("RGBA"))
	m = (a[:, :, 0] < BLACK_T) & (a[:, :, 1] < BLACK_T) & (a[:, :, 2] < BLACK_T)
	a[m, 3] = 0
	ys, xs = np.where(a[:, :, 3] > 12)
	if len(xs) == 0:
		return Image.fromarray(a, "RGBA")
	crop = a[ys.min() : ys.max() + 1, xs.min() : xs.max() + 1]
	out = Image.fromarray(crop, "RGBA")
	scale = TARGET_H / float(out.height)
	nw = max(8, int(round(out.width * scale)))
	return out.resize((nw, TARGET_H), Image.Resampling.NEAREST)


def main() -> None:
	if not SRC.exists():
		raise SystemExit(f"missing {SRC}")
	OUT.mkdir(parents=True, exist_ok=True)
	im = Image.open(SRC).convert("RGBA")
	cw, ch = im.width // COLS, im.height // ROWS
	print(f"cell {cw}x{ch}")
	for (ry, cx), name in NAMES.items():
		x0, y0 = cx * cw, ry * ch
		cell = im.crop((x0, y0, x0 + cw, y0 + ch))
		out = punch_black(cell)
		path = OUT / f"{name}.png"
		out.save(path)
		print("wrote", path.name, out.size)
	# Also dump all cells as b09_r{row}_c{col} for future mapping.
	dump = OUT / "_grid"
	dump.mkdir(exist_ok=True)
	for ry in range(ROWS):
		for cx in range(COLS):
			x0, y0 = cx * cw, ry * ch
			cell = punch_black(im.crop((x0, y0, x0 + cw, y0 + ch)))
			cell.save(dump / f"b09_r{ry}_c{cx}.png")
	print("OK", OUT)


if __name__ == "__main__":
	main()
