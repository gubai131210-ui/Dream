#!/usr/bin/env python3
"""Generate biome rock families (pixel art) for Dream outdoor scenes.

Families:
  coastal  — cooler blue-gray, flatter, almost no moss (lighthouse / pier)
  terrace  — dry sandstone / tan angular lips (hill farm)
  cobble   — small rounded warm gray (plaza / station ballast)
  river    — darker wet stones, slight teal, low moss (river / waterfall bank)

Existing rock_00–05 remain forest_moss fallback.
"""
from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "props" / "rocks"

PALETTES = {
	"coastal": {
		"base": [(90, 110, 130), (120, 140, 155), (160, 175, 185), (200, 210, 218)],
		"moss": None,
		"shadow": (45, 55, 70),
	},
	"terrace": {
		"base": [(130, 105, 75), (160, 130, 90), (190, 160, 115), (210, 185, 140)],
		"moss": None,
		"shadow": (70, 50, 35),
	},
	"cobble": {
		"base": [(110, 108, 100), (140, 135, 125), (165, 160, 148), (190, 185, 170)],
		"moss": None,
		"shadow": (55, 52, 48),
	},
	"river": {
		"base": [(70, 85, 95), (95, 115, 120), (125, 145, 148), (155, 175, 178)],
		"moss": [(70, 110, 60), (95, 140, 70)],
		"shadow": (35, 45, 55),
	},
}


def _disk(draw: ImageDraw.ImageDraw, cx: float, cy: float, rx: float, ry: float, color: tuple) -> None:
	bbox = [cx - rx, cy - ry, cx + rx, cy + ry]
	draw.ellipse(bbox, fill=color)


def make_rock(family: str, idx: int, seed: int) -> Image.Image:
	rng = random.Random(seed + idx * 97)
	pal = PALETTES[family]
	w, h = (72, 48) if family == "cobble" else (110, 72)
	if family == "terrace":
		w, h = 100, 64
	if family == "coastal":
		w, h = 120, 58  # flatter
	img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	draw = ImageDraw.Draw(img)
	cx, cy = w * 0.5, h * 0.58
	# Stacked lobes for silhouette variety
	lobes = 3 + (idx % 3)
	for i in range(lobes):
		ox = rng.uniform(-w * 0.22, w * 0.22)
		oy = rng.uniform(-h * 0.12, h * 0.08)
		rx = rng.uniform(w * 0.18, w * 0.32)
		ry = rng.uniform(h * 0.18, h * 0.30)
		if family == "terrace":
			# More angular: draw polygon approx via smaller ellipses offset
			ry *= 0.85
		shade = pal["base"][min(i, len(pal["base"]) - 1)]
		_disk(draw, cx + ox, cy + oy, rx, ry, shade)
	# Top highlight lobe
	hi = pal["base"][-1]
	_disk(draw, cx - w * 0.08, cy - h * 0.18, w * 0.22, h * 0.16, hi)
	# Shadow undercut
	_disk(draw, cx + w * 0.05, cy + h * 0.12, w * 0.28, h * 0.12, pal["shadow"])
	# Speckle texture
	px = img.load()
	for _ in range(int(w * h * 0.08)):
		x = rng.randrange(w)
		y = rng.randrange(h)
		if px[x, y][3] < 20:
			continue
		c = pal["base"][rng.randrange(len(pal["base"]))]
		a = px[x, y][3]
		px[x, y] = (c[0], c[1], c[2], a)
	# Optional moss for river
	moss = pal.get("moss")
	if moss:
		for _ in range(18 + idx * 4):
			x = int(cx + rng.uniform(-w * 0.2, w * 0.25))
			y = int(cy - h * 0.25 + rng.uniform(-4, 8))
			if 0 <= x < w and 0 <= y < h and px[x, y][3] > 40:
				mc = moss[rng.randrange(len(moss))]
				px[x, y] = (mc[0], mc[1], mc[2], 255)
				if x + 1 < w:
					px[x + 1, y] = (mc[0], mc[1], mc[2], 230)
	# Soft alpha edge cleanup: keep opaque body
	return img


def main() -> None:
	for family in PALETTES:
		folder = OUT / family
		folder.mkdir(parents=True, exist_ok=True)
		for i in range(3):
			img = make_rock(family, i, seed=20260913)
			path = folder / f"rock_{i:02d}.png"
			img.save(path)
			print("wrote", path.relative_to(ROOT), img.size)
	print("GREEN biome rocks")


if __name__ == "__main__":
	main()
