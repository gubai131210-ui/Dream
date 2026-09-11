#!/usr/bin/env python3
"""Generate C49 backyard unique props: doghouse, clothesline, wood pile (3/4 pixel craft)."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"

OUTLINE = (42, 30, 18, 255)
WOOD = (138, 98, 58, 255)
WOOD_DK = (86, 56, 32, 255)
WOOD_LT = (172, 128, 78, 255)
WOOD_HI = (208, 168, 108, 255)
BARK = (96, 68, 42, 255)
BARK_DK = (62, 42, 26, 255)
BARK_LT = (128, 96, 62, 255)
RING = (186, 150, 98, 255)
RING_DK = (140, 108, 68, 255)
RING_HI = (220, 188, 130, 255)
IRON = (72, 74, 78, 255)
IRON_LT = (118, 120, 126, 255)
ROPE = (120, 96, 58, 255)
CLOTH_W = (236, 232, 222, 255)
CLOTH_B = (120, 150, 190, 255)
CLOTH_R = (190, 90, 78, 255)
CLOTH_G = (110, 150, 98, 255)
CLOTH_Y = (220, 190, 90, 255)
SOIL = (78, 56, 36, 255)
SOIL_D = (54, 38, 24, 255)
GRASS = (86, 140, 58, 255)


def blank(w: int, h: int) -> np.ndarray:
	return np.zeros((h, w, 4), dtype=np.uint8)


def put(a: np.ndarray, x: int, y: int, c: tuple[int, int, int, int]) -> None:
	h, w = a.shape[:2]
	if 0 <= x < w and 0 <= y < h:
		a[y, x] = c


def shade(base: tuple[int, int, int, int], d: int) -> tuple[int, int, int, int]:
	return (
		max(0, min(255, base[0] + d)),
		max(0, min(255, base[1] + d)),
		max(0, min(255, base[2] + d)),
		255,
	)


def fill_rect(a: np.ndarray, x0: int, y0: int, x1: int, y1: int, color_fn) -> None:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			put(a, x, y, color_fn(x, y))


def outline_rect(a: np.ndarray, x0: int, y0: int, x1: int, y1: int, c=OUTLINE) -> None:
	for x in range(x0, x1 + 1):
		put(a, x, y0, c)
		put(a, x, y1, c)
	for y in range(y0, y1 + 1):
		put(a, x0, y, c)
		put(a, x1, y, c)


def crop_opaque(a: np.ndarray, pad: int = 1) -> np.ndarray:
	ys, xs = np.where(a[:, :, 3] > 0)
	return a[max(0, ys.min() - pad) : ys.max() + pad + 1, max(0, xs.min() - pad) : xs.max() + pad + 1]


def make_doghouse() -> Image.Image:
	"""Classic A-frame kennel with arched door — not a chicken nest box."""
	rng = np.random.default_rng(49)
	a = blank(56, 56)
	# ground contact
	for y in range(46, 54):
		for x in range(6, 48):
			if abs(x - 26) / 20 + abs(y - 50) / 5 < 1.0:
				put(a, x, y, shade(SOIL_D, int(rng.integers(-6, 7))))
	# floor planks
	fill_rect(
		a,
		10,
		42,
		42,
		48,
		lambda x, y: shade(
			WOOD_DK if y in (42, 48) or x in (10, 42) else (WOOD if (x + y) % 5 else WOOD_LT),
			int(rng.integers(-10, 11)),
		),
	)
	outline_rect(a, 10, 42, 42, 48)
	# front face walls
	fill_rect(
		a,
		12,
		22,
		40,
		42,
		lambda x, y: shade(
			WOOD_HI if (x - 12) < 4 else (WOOD_DK if (x - 12) > 24 else (WOOD_LT if (y % 4 == 0) else WOOD)),
			int(rng.integers(-16, 17)),
		),
	)
	# plank seams
	for y in range(24, 42, 4):
		for x in range(12, 41):
			put(a, x, y, shade(WOOD_DK, int(rng.integers(-8, 5))))
	outline_rect(a, 12, 22, 40, 42)
	# right foreshorten wall
	for dy in range(22):
		yy = 22 + dy
		for sx in range(7):
			xx = 41 + sx
			c = WOOD_DK if sx > 3 else WOOD
			if dy % 4 == 0:
				c = WOOD_DK
			put(a, xx, yy - sx // 3, shade(c, int(rng.integers(-12, 13))))
	# A-frame roof (front triangle + right slope)
	peak_x, peak_y = 26, 8
	for y in range(peak_y, 24):
		t = (y - peak_y) / max(1, 23 - peak_y)
		half = int(2 + t * 16)
		for x in range(peak_x - half, peak_x + half + 1):
			lit = (x - peak_x) / max(1, half)
			c = WOOD_HI if lit < -0.2 else (WOOD_DK if lit > 0.35 else WOOD_LT)
			if abs(x - peak_x) < 2:
				c = WOOD_HI
			if (x * 11 + y * 7) % 13 == 0:
				c = shade(c, -18)
			put(a, x, y, shade(c, int(rng.integers(-12, 13))))
		# outline eaves
		put(a, peak_x - half, y, OUTLINE)
		put(a, peak_x + half, y, OUTLINE)
	put(a, peak_x, peak_y, OUTLINE)
	# roof right foreshorten
	for y in range(10, 24):
		for sx in range(6):
			put(a, 40 + sx, y - sx // 2, shade(WOOD_DK if sx > 2 else BARK, int(rng.integers(-10, 11))))
	# arched doorway (dark interior + straw bedding hint — still kennel, not nest/egg)
	for y in range(28, 43):
		for x in range(20, 33):
			nx = (x - 26) / 7.0
			ny = (y - 36) / 8.0
			# arch top
			if y < 32 and nx * nx + ((y - 32) / 5.0) ** 2 > 1.0:
				continue
			if abs(nx) > 1.0:
				continue
			c = SOIL_D if ny > 0.4 else (BARK_DK if (x + y) % 3 else SOIL)
			put(a, x, y, shade(c, int(rng.integers(-8, 9))))
	# door arch rim
	for t in range(-90, 91, 4):
		rad = np.deg2rad(t)
		put(a, int(round(26 + 7 * np.cos(rad))), int(round(32 + 5 * np.sin(rad))), OUTLINE)
	for y in range(32, 43):
		put(a, 20, y, OUTLINE)
		put(a, 32, y, OUTLINE)
	# iron nail heads + name plate
	for nx, ny in ((14, 26), (38, 26), (14, 36), (38, 36)):
		put(a, nx, ny, IRON_LT)
		put(a, nx, ny + 1, IRON)
	for x in range(22, 31):
		put(a, x, 24, shade(WOOD_HI if x % 2 else WOOD_LT, int(rng.integers(-6, 7))))
	outline_rect(a, 22, 23, 30, 25)
	# bone toy outside entrance (doghouse cue)
	for x in range(34, 42):
		put(a, x, 46, shade(CLOTH_W, int(rng.integers(-10, 11))))
	put(a, 34, 45, CLOTH_W)
	put(a, 34, 47, CLOTH_W)
	put(a, 41, 45, CLOTH_W)
	put(a, 41, 47, CLOTH_W)
	return Image.fromarray(crop_opaque(a), "RGBA")


def _shirt(a: np.ndarray, cx: int, top: int, color: tuple, rng: np.random.Generator) -> None:
	"""Hanging shirt silhouette on line."""
	for y in range(top, top + 14):
		w = 5 if y < top + 3 else (7 if y < top + 10 else 6)
		for x in range(cx - w // 2, cx + w // 2 + 1):
			# sleeve cutouts near shoulders
			if top + 3 <= y <= top + 6 and abs(x - cx) > 2 and abs(x - cx) < w // 2:
				if y == top + 4:
					continue
			c = shade(color, int(rng.integers(-18, 19)))
			if y == top:
				c = ROPE
			if (x + y) % 9 == 0:
				c = shade(c, -22)
			put(a, x, y, c)
	# hem fold
	for x in range(cx - 3, cx + 4):
		put(a, x, top + 13, shade(color, -25))
	# clothespin
	put(a, cx, top - 1, WOOD_DK)
	put(a, cx, top - 2, WOOD)


def _sheet(a: np.ndarray, x0: int, top: int, w: int, color: tuple, rng: np.random.Generator) -> None:
	for y in range(top, top + 18):
		sway = int(np.sin((y - top) * 0.35) * 1.5)
		for x in range(x0 + sway, x0 + w + sway):
			c = shade(color, int(rng.integers(-14, 15)))
			if (x + y * 2) % 11 == 0:
				c = shade(c, -20)
			if y == top:
				c = ROPE
			put(a, x, y, c)
	for x in range(x0, x0 + w):
		put(a, x, top + 17, shade(color, -30))
	put(a, x0 + w // 2, top - 1, WOOD_DK)


def make_clothesline() -> Image.Image:
	"""Two poles + rope + hanging laundry — not hanging herbs."""
	rng = np.random.default_rng(490)
	a = blank(80, 56)
	# ground shadows under poles
	for px in (8, 70):
		for y in range(48, 54):
			for x in range(px - 4, px + 5):
				if abs(x - px) / 5 + abs(y - 51) / 3 < 1.0:
					put(a, x, y, shade(SOIL_D, int(rng.integers(-5, 6))))
	# poles
	for px in (8, 70):
		fill_rect(
			a,
			px - 2,
			10,
			px + 2,
			50,
			lambda x, y, p=px: shade(
				WOOD_DK if x in (p - 2, p + 2) or y % 6 == 0 else (WOOD_LT if x == p else WOOD),
				int(rng.integers(-12, 13)),
			),
		)
		outline_rect(a, px - 2, 10, px + 2, 50)
		# cross arm tip
		for x in range(px - 4, px + 5):
			put(a, x, 12, WOOD_DK)
			put(a, x, 11, OUTLINE)
	# rope line (slight sag)
	for x in range(10, 70):
		t = (x - 10) / 60.0
		sag = int(2 + 4 * (1.0 - (2 * t - 1) ** 2))
		y = 14 + sag
		put(a, x, y, ROPE)
		put(a, x, y + 1, shade(ROPE, -20))
	# laundry left → right: blue shirt, white sheet, red shirt, yellow cloth, green shirt
	_shirt(a, 18, 18, CLOTH_B, rng)
	_sheet(a, 26, 17, 14, CLOTH_W, rng)
	_shirt(a, 46, 19, CLOTH_R, rng)
	_sheet(a, 52, 18, 10, CLOTH_Y, rng)
	_shirt(a, 64, 18, CLOTH_G, rng)
	# grass tufts at feet
	for gx, gy in ((6, 49), (12, 50), (66, 49), (74, 50)):
		put(a, gx, gy, GRASS)
		put(a, gx + 1, gy - 1, shade(GRASS, 20))
	return Image.fromarray(crop_opaque(a), "RGBA")


def _log_end(a: np.ndarray, cx: int, cy: int, rx: int, ry: int, rng: np.random.Generator) -> None:
	"""Circular log end with growth rings — firewood cue."""
	for y in range(cy - ry - 1, cy + ry + 2):
		for x in range(cx - rx - 1, cx + rx + 2):
			nx = (x - cx) / max(1.0, rx)
			ny = (y - cy) / max(1.0, ry)
			r2 = nx * nx + ny * ny
			if r2 > 1.0:
				continue
			r = np.sqrt(r2)
			# bark rim
			if r > 0.82:
				c = BARK_DK if (x + y) % 2 else BARK
			else:
				band = int(r * 5) % 2
				c = RING_HI if band == 0 else RING
				if r < 0.18:
					c = RING_DK
				if (x * 13 + y * 17) % 19 == 0:
					c = shade(c, -22)
			lit = -nx * 0.35 - ny * 0.25
			put(a, x, y, shade(c, int(lit * 30) + int(rng.integers(-10, 11))))
	# outline
	for t in range(0, 360, 8):
		rad = np.deg2rad(t)
		put(
			a,
			int(round(cx + rx * np.cos(rad))),
			int(round(cy + ry * np.sin(rad))),
			OUTLINE,
		)


def _log_side(a: np.ndarray, x0: int, y0: int, length: int, thick: int, rng: np.random.Generator) -> None:
	"""Side-view log cylinder (bark lengthwise)."""
	for y in range(y0, y0 + thick):
		for x in range(x0, x0 + length):
			ny = (y - y0) / max(1, thick - 1)
			c = BARK_LT if ny < 0.25 else (BARK_DK if ny > 0.75 else BARK)
			if (x + y * 2) % 7 == 0:
				c = shade(c, -18)
			if x == x0 or x == x0 + length - 1:
				c = RING_DK
			put(a, x, y, shade(c, int(rng.integers(-12, 13))))
	for x in range(x0, x0 + length):
		put(a, x, y0, OUTLINE)
		put(a, x, y0 + thick - 1, OUTLINE)


def make_wood_pile() -> Image.Image:
	"""Stacked firewood mass — log ends + side bark, not a hay cone."""
	rng = np.random.default_rng(491)
	a = blank(64, 56)
	# ground
	for y in range(44, 54):
		for x in range(4, 58):
			if abs(x - 30) / 28 + abs(y - 49) / 6 < 1.0:
				put(a, x, y, shade(SOIL_D if (x + y) % 3 else SOIL, int(rng.integers(-6, 7))))
	# back row of side logs (height mass)
	_log_side(a, 8, 28, 22, 7, rng)
	_log_side(a, 28, 26, 24, 7, rng)
	_log_side(a, 14, 20, 20, 6, rng)
	_log_side(a, 32, 18, 18, 6, rng)
	_log_side(a, 20, 12, 16, 5, rng)
	# front facing log ends (readable firewood)
	ends = [
		(14, 42, 7, 6),
		(26, 44, 8, 6),
		(38, 42, 7, 6),
		(48, 40, 6, 5),
		(18, 34, 6, 5),
		(30, 36, 7, 5),
		(42, 34, 6, 5),
		(24, 28, 5, 4),
		(36, 28, 5, 4),
		(30, 22, 5, 4),
	]
	for cx, cy, rx, ry in ends:
		_log_end(a, cx, cy, rx, ry, rng)
	# axe handle leaning (yard work cue; small)
	for y in range(18, 46):
		put(a, 54, y, shade(WOOD_DK if y % 3 else WOOD, int(rng.integers(-8, 9))))
	put(a, 53, 18, IRON)
	put(a, 54, 17, IRON_LT)
	put(a, 55, 18, IRON)
	put(a, 52, 19, IRON)
	put(a, 56, 19, IRON)
	return Image.fromarray(crop_opaque(a), "RGBA")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	dog = make_doghouse()
	line = make_clothesline()
	wood = make_wood_pile()
	dog.save(OUT / "doghouse_00.png")
	line.save(OUT / "clothesline_00.png")
	wood.save(OUT / "wood_pile_00.png")
	print("wrote doghouse_00.png", dog.size)
	print("wrote clothesline_00.png", line.size)
	print("wrote wood_pile_00.png", wood.size)
	# diag strip
	pad = 8
	dw = dog.width + line.width + wood.width + pad * 4
	dh = max(dog.height, line.height, wood.height) + pad * 2
	diag = Image.new("RGBA", (dw, dh), (40, 48, 32, 255))
	x = pad
	for im in (dog, line, wood):
		diag.paste(im, (x, dh - im.height - pad), im)
		x += im.width + pad
	diag.save(OUT / "_diag_backyard_c49_props.png")
	print("wrote _diag_backyard_c49_props.png")


if __name__ == "__main__":
	main()
