#!/usr/bin/env python3
"""Paint outdoor landmark props for empty investigate hotspots (reed/ruin/grave)."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
TMPL = (PROPS / "crate_0.png.import").read_text(encoding="utf-8")

STONE = [(55, 54, 61), (72, 70, 77), (83, 79, 85), (98, 94, 100)]
MOSS = [(62, 92, 54), (78, 110, 60)]
REED = [(70, 108, 52), (92, 128, 58), (48, 78, 40), (120, 140, 70)]
WOOD = [(92, 64, 42), (110, 78, 50), (70, 48, 32)]


def _put(px, x: int, y: int, rgb: tuple[int, int, int], a: int = 255) -> None:
	px[x, y] = (*rgb, a)


def paint_reed(w: int = 48, h: int = 56) -> Image.Image:
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Clump of vertical stalks with tips.
	bases = [10, 16, 22, 28, 34, 38]
	for i, bx in enumerate(bases):
		hgt = 28 + (i * 3) % 11
		col = REED[i % len(REED)]
		for y in range(h - 4, h - 4 - hgt, -1):
			x = bx + ((h - 4 - y) // 7) * (1 if i % 2 == 0 else -1)
			if 0 <= x < w and 0 <= y < h:
				_put(px, x, y, col)
				if x + 1 < w:
					_put(px, x + 1, y, REED[(i + 1) % len(REED)], 220)
		# Seed tip
		ty = h - 4 - hgt
		for dx in (-1, 0, 1):
			for dy in (0, 1):
				xx, yy = bx + dx, ty + dy
				if 0 <= xx < w and 0 <= yy < h:
					_put(px, xx, yy, REED[2])
	# Mud foot
	for x in range(8, 42):
		_put(px, x, h - 3, (68, 58, 42), 200)
		_put(px, x, h - 2, (58, 48, 34), 180)
	return im


def paint_ruin_arch(w: int = 64, h: int = 56) -> Image.Image:
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Two pillars + broken lintel.
	for x in list(range(8, 16)) + list(range(48, 56)):
		for y in range(14, h - 4):
			_put(px, x, y, STONE[(x + y) % len(STONE)])
	for x in range(8, 56):
		for y in range(10, 18):
			if 22 <= x <= 42 and y > 14:
				continue  # broken gap
			_put(px, x, y, STONE[(x + y) % len(STONE)])
	# Moss patches
	for x, y in ((10, 20), (12, 28), (50, 22), (52, 34), (30, 12)):
		_put(px, x, y, MOSS[0])
		_put(px, x + 1, y, MOSS[1], 200)
	# Rubble foot
	for x in range(6, 58):
		if (x + 3) % 5 == 0:
			continue
		_put(px, x, h - 4, STONE[1], 210)
		_put(px, x, h - 3, STONE[0], 190)
	return im


def paint_grave(w: int = 32, h: int = 48) -> Image.Image:
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Headstone
	for x in range(8, 24):
		for y in range(8, 36):
			# rounded top
			if y < 12 and (x < 10 or x > 21):
				continue
			_put(px, x, y, STONE[(x + y) % len(STONE)])
	# Cross notch
	for x in range(14, 18):
		for y in range(14, 28):
			_put(px, x, y, STONE[0])
	for x in range(11, 21):
		for y in range(16, 19):
			_put(px, x, y, STONE[0])
	# Base slab
	for x in range(4, 28):
		_put(px, x, 36, STONE[2])
		_put(px, x, 37, STONE[1])
		_put(px, x, 38, WOOD[0], 180)
	return im


def write_import(name: str) -> None:
	text = TMPL.replace("crate_0.png", name)
	uid = "uid://p" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(PROPS / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def main() -> None:
	PROPS.mkdir(parents=True, exist_ok=True)
	for name, fn in (
		("reed_clump_00.png", paint_reed),
		("ruin_arch_00.png", paint_ruin_arch),
		("grave_marker_00.png", paint_grave),
	):
		fn().save(PROPS / name)
		write_import(name)
		print("wrote", name)


if __name__ == "__main__":
	main()
