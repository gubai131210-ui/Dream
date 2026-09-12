#!/usr/bin/env python3
"""Slice waterfall_water_anim_sheet_v3 into fixed-canvas loop frames."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
SHEET = PROPS / "waterfall_water_anim_sheet_v3.png"
TMPL = (PROPS / "waterfall_tall_00.png.import").read_text(encoding="utf-8")
OUT_PREFIX = "waterfall_water"


def write_import(name: str) -> None:
	old = "waterfall_tall_00.png"
	text = TMPL.replace(old, name)
	uid = "uid://w" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(PROPS / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def content_islands(im: Image.Image) -> list[tuple[int, int]]:
	w, h = im.size
	cols: list[tuple[int, int]] = []
	x = 0
	px = im.load()
	while x < w:
		while x < w and all(px[x, y][3] < 8 for y in range(0, h, 4)):
			x += 1
		if x >= w:
			break
		x0 = x
		while x < w and any(px[x, y][3] >= 8 for y in range(0, h, 4)):
			x += 1
		cols.append((x0, x))
	return cols


def main() -> None:
	sheet = Image.open(SHEET).convert("RGBA")
	islands = content_islands(sheet)
	if len(islands) < 4:
		raise SystemExit(f"expected ≥4 water frames, got {len(islands)}")
	# Normalize to shared canvas from max island bbox
	crops: list[Image.Image] = []
	max_w = 0
	max_h = 0
	for x0, x1 in islands:
		cell = sheet.crop((x0, 0, x1, sheet.height))
		bbox = cell.getbbox()
		if bbox is None:
			continue
		cropped = cell.crop(bbox)
		crops.append(cropped)
		max_w = max(max_w, cropped.width)
		max_h = max(max_h, cropped.height)
	print(f"frames={len(crops)} canvas=({max_w},{max_h})")
	for i, cropped in enumerate(crops):
		canvas = Image.new("RGBA", (max_w, max_h), (0, 0, 0, 0))
		# Bottom-center align so foot of fall stays fixed.
		ox = (max_w - cropped.width) // 2
		oy = max_h - cropped.height
		canvas.paste(cropped, (ox, oy), cropped)
		name = f"{OUT_PREFIX}_{i:02d}.png"
		canvas.save(PROPS / name)
		write_import(name)
		print(f"wrote {name}")


if __name__ == "__main__":
	main()
