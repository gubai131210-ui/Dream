#!/usr/bin/env python3
"""Regenerate biome rocks with TRUE alpha (no white/black/checker backgrounds)."""
from __future__ import annotations

import random
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "props" / "rocks"

SPECS = {
	"coastal": {
		"size": (96, 48),
		"base": [(88, 108, 128), (118, 138, 152), (148, 168, 178), (178, 192, 200)],
		"shadow": (48, 58, 72),
		"moss": None,
		"flat": 1.35,
	},
	"terrace": {
		"size": (88, 56),
		"base": [(138, 112, 78), (168, 138, 98), (198, 168, 122), (218, 192, 148)],
		"shadow": (72, 52, 36),
		"moss": None,
		"flat": 1.0,
	},
	"cobble": {
		"size": (56, 36),
		"base": [(118, 114, 106), (148, 142, 132), (172, 166, 154), (196, 190, 176)],
		"shadow": (58, 54, 48),
		"moss": None,
		"flat": 1.1,
	},
	"river": {
		"size": (92, 58),
		"base": [(72, 88, 96), (98, 118, 122), (128, 148, 152), (158, 178, 180)],
		"shadow": (36, 46, 56),
		"moss": [(68, 108, 58), (92, 136, 68)],
		"flat": 1.05,
	},
}


def _paint_disk(px, w, h, cx, cy, rx, ry, color, alpha=255):
	rx = max(1.0, rx)
	ry = max(1.0, ry)
	x0 = max(0, int(cx - rx - 1))
	x1 = min(w - 1, int(cx + rx + 1))
	y0 = max(0, int(cy - ry - 1))
	y1 = min(h - 1, int(cy + ry + 1))
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			nx = (x + 0.5 - cx) / rx
			ny = (y + 0.5 - cy) / ry
			if nx * nx + ny * ny <= 1.0:
				px[x, y] = (color[0], color[1], color[2], alpha)


def make_rock(family: str, idx: int) -> Image.Image:
	cfg = SPECS[family]
	w, h = cfg["size"]
	flat = float(cfg["flat"])
	rng = random.Random(9000 + idx * 131 + hash(family) % 997)
	img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = img.load()
	cx, cy = w * 0.5, h * 0.58
	lobes = 3 + (idx % 3)
	for i in range(lobes):
		ox = rng.uniform(-w * 0.2, w * 0.2)
		oy = rng.uniform(-h * 0.1, h * 0.08)
		rx = rng.uniform(w * 0.16, w * 0.28)
		ry = rng.uniform(h * 0.16, h * 0.26) / flat
		shade = cfg["base"][min(i, len(cfg["base"]) - 1)]
		_paint_disk(px, w, h, cx + ox, cy + oy, rx, ry, shade)
	# highlight
	_paint_disk(px, w, h, cx - w * 0.08, cy - h * 0.16, w * 0.18, h * 0.12 / flat, cfg["base"][-1])
	# undercut shadow (still opaque rock tone, not black box)
	_paint_disk(px, w, h, cx + w * 0.04, cy + h * 0.1, w * 0.22, h * 0.1 / flat, cfg["shadow"], 230)
	# speckles only on opaque pixels
	for _ in range(int(w * h * 0.06)):
		x = rng.randrange(w)
		y = rng.randrange(h)
		if px[x, y][3] < 40:
			continue
		c = cfg["base"][rng.randrange(len(cfg["base"]))]
		a = px[x, y][3]
		px[x, y] = (c[0], c[1], c[2], a)
	moss = cfg.get("moss")
	if moss:
		for _ in range(14 + idx * 3):
			x = int(cx + rng.uniform(-w * 0.18, w * 0.22))
			y = int(cy - h * 0.22 + rng.uniform(-3, 6))
			if 0 <= x < w and 0 <= y < h and px[x, y][3] > 40:
				mc = moss[rng.randrange(len(moss))]
				px[x, y] = (mc[0], mc[1], mc[2], 255)
	# Hard-clear any near-white / near-black leftover fringe outside rock mass
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			# kill pure white / checker leftovers
			if r > 235 and g > 235 and b > 235:
				px[x, y] = (0, 0, 0, 0)
			elif r < 12 and g < 12 and b < 12 and a < 255:
				px[x, y] = (0, 0, 0, 0)
	return img


def assert_clean(path: Path) -> None:
	im = Image.open(path).convert("RGBA")
	px = im.load()
	w, h = im.size
	bad = 0
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a > 200 and r > 240 and g > 240 and b > 240:
				bad += 1
	if bad > 8:
		raise SystemExit(f"RED {path} still has {bad} whiteish opaque pixels")


def main() -> None:
	for family in SPECS:
		folder = OUT / family
		folder.mkdir(parents=True, exist_ok=True)
		for i in range(3):
			img = make_rock(family, i)
			path = folder / f"rock_{i:02d}.png"
			img.save(path)
			assert_clean(path)
			print("wrote", path.relative_to(ROOT), img.size)
	print("GREEN clean biome rocks")


if __name__ == "__main__":
	main()
