#!/usr/bin/env python3
"""Generate C50 farm cellar signature props: cheese aging rack, pickle crocks, wine rack.

Distinct from C15 home-basement storage (shelf+keg+lamp_indoor) and C39 cheese_press screw machine.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"

OUTLINE = (36, 26, 18, 255)
WOOD = (118, 82, 48, 255)
WOOD_DK = (72, 46, 28, 255)
WOOD_LT = (152, 110, 68, 255)
WOOD_HI = (186, 144, 92, 255)
IRON = (68, 70, 76, 255)
IRON_LT = (108, 112, 120, 255)
IRON_DK = (46, 48, 54, 255)
CHEESE = (226, 188, 92, 255)
CHEESE_D = (186, 148, 58, 255)
CHEESE_L = (244, 214, 132, 255)
CHEESE_RIND = (168, 132, 72, 255)
MOLD = (148, 168, 120, 255)
CERAMIC = (188, 176, 158, 255)
CERAMIC_L = (220, 210, 192, 255)
CERAMIC_D = (132, 120, 104, 255)
GLAZE = (92, 108, 98, 255)
GLAZE_L = (128, 148, 136, 255)
GLAZE_D = (58, 72, 64, 255)
BRINE = (168, 176, 150, 255)
PICKLE = (92, 128, 72, 255)
PICKLE_L = (118, 156, 92, 255)
GLASS = (72, 48, 58, 255)
GLASS_L = (120, 72, 88, 255)
GLASS_D = (42, 28, 36, 255)
WINE = (96, 36, 48, 255)
WINE_L = (148, 58, 72, 255)
CORK = (168, 128, 78, 255)
CORK_D = (118, 86, 48, 255)
LABEL = (214, 198, 160, 255)


def blank(w: int, h: int) -> np.ndarray:
	return np.zeros((h, w, 4), dtype=np.uint8)


def put(a: np.ndarray, x: int, y: int, c: tuple[int, int, int, int]) -> None:
	h, w = a.shape[:2]
	if 0 <= x < w and 0 <= y < h:
		a[y, x] = c


def rect(a: np.ndarray, x0: int, y0: int, x1: int, y1: int, color_fn) -> None:
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


def ellipse_fill(a: np.ndarray, cx: int, cy: int, rx: int, ry: int, color_fn) -> None:
	for y in range(cy - ry - 1, cy + ry + 2):
		for x in range(cx - rx - 1, cx + rx + 2):
			nx = (x - cx) / max(1.0, rx)
			ny = (y - cy) / max(1.0, ry)
			if nx * nx + ny * ny <= 1.0:
				put(a, x, y, color_fn(nx, ny, x, y))


def outline_ellipse(a: np.ndarray, cx: int, cy: int, rx: int, ry: int, c=OUTLINE) -> None:
	for t in range(0, 360, 2):
		rad = np.deg2rad(t)
		put(a, int(round(cx + rx * np.cos(rad))), int(round(cy + ry * np.sin(rad))), c)


def crop_opaque(a: np.ndarray, pad: int = 1) -> np.ndarray:
	ys, xs = np.where(a[:, :, 3] > 0)
	return a[max(0, ys.min() - pad) : ys.max() + pad + 1, max(0, xs.min() - pad) : xs.max() + pad + 1]


def shade(base: tuple[int, int, int, int], d: int) -> tuple[int, int, int, int]:
	return (
		max(0, min(255, base[0] + d)),
		max(0, min(255, base[1] + d)),
		max(0, min(255, base[2] + d)),
		255,
	)


def make_cheese_aging() -> Image.Image:
	"""Open wooden aging rack with multiple cheese wheels on shelves — NOT a screw press."""
	rng = np.random.default_rng(50)
	a = blank(64, 72)

	def wood_fn(x, y, lit_bias=0.0):
		lit = (x - 32) / 28 - (y - 36) / 40 + lit_bias
		c = WOOD_HI if lit > 0.35 else (WOOD_DK if lit < -0.3 else (WOOD_LT if (x + y) % 6 == 0 else WOOD))
		return shade(c, int(rng.integers(-10, 11)))

	# Side posts (open rack frame — no top screw)
	for x0, x1 in ((6, 11), (52, 57)):
		rect(a, x0, 8, x1, 66, lambda x, y, _x0=x0: wood_fn(x, y, -0.1 if x < _x0 + 3 else 0.15))
		outline_rect(a, x0, 8, x1, 66)

	# Base sled
	rect(a, 4, 64, 59, 69, lambda x, y: wood_fn(x, y, 0.05))
	outline_rect(a, 4, 64, 59, 69)

	# Three open shelves (aging boards)
	shelf_ys = (18, 36, 54)
	for sy in shelf_ys:
		rect(a, 11, sy, 52, sy + 4, lambda x, y: wood_fn(x, y, 0.2))
		outline_rect(a, 11, sy, 52, sy + 4)
		# back rail hint
		for x in range(12, 52):
			put(a, x, sy - 1, shade(WOOD_DK, int(rng.integers(-4, 5))))

	def wheel(cx: int, cy: int, rx: int, ry: int, aged: bool) -> None:
		def cheese_c(nx, ny, x, y):
			lit = -nx * 0.55 - ny * 0.25
			if abs(ny) > 0.78:
				return shade(CHEESE_RIND if aged else WOOD_DK, int(rng.integers(-6, 7)))
			c = CHEESE_L if lit > 0.35 else (CHEESE_D if lit < -0.3 else CHEESE)
			if aged and (x * 7 + y * 3) % 13 == 0:
				c = MOLD
			if (x * 5 + y * 11) % 17 == 0:
				c = shade(c, -22)
			return shade(c, int(rng.integers(-10, 11)))

		ellipse_fill(a, cx, cy, rx, ry, cheese_c)
		outline_ellipse(a, cx, cy, rx, ry)
		# rind band
		for x in range(cx - rx + 1, cx + rx):
			nx = (x - cx) / max(1.0, rx)
			if abs(nx) <= 0.95:
				put(a, x, cy + ry - 1, shade(CHEESE_RIND, int(rng.integers(-8, 9))))

	# Top shelf: two small wheels
	wheel(22, 14, 7, 4, True)
	wheel(40, 14, 6, 4, False)
	# Mid shelf: large aged wheel + small
	wheel(24, 31, 9, 5, True)
	wheel(44, 32, 6, 4, False)
	# Bottom shelf: two mid wheels
	wheel(20, 49, 8, 5, True)
	wheel(38, 49, 7, 4, True)
	wheel(50, 50, 5, 3, False)

	# Small chalk tag on mid rail (production cue)
	rect(a, 28, 37, 36, 40, lambda x, y: shade(LABEL, int(rng.integers(-6, 7))))
	outline_rect(a, 28, 37, 36, 40)
	put(a, 30, 38, IRON_DK)
	put(a, 32, 38, IRON)
	put(a, 34, 38, IRON_DK)

	return Image.fromarray(crop_opaque(a), "RGBA")


def make_pickle_crock() -> Image.Image:
	"""Cluster of glazed stoneware pickle crocks with lids — production brine, not mug shelf."""
	rng = np.random.default_rng(51)
	a = blank(72, 56)

	def crock(cx: int, base_y: int, rx: int, body_h: int, glaze: bool) -> None:
		top_y = base_y - body_h
		# body bands
		for i, (cy, rxx, ryy) in enumerate(
			(
				(base_y - 2, rx, max(3, rx // 2)),
				(base_y - body_h // 3, rx + 1, max(4, rx // 2 + 1)),
				(base_y - (2 * body_h) // 3, rx, max(4, rx // 2)),
				(top_y + 4, rx - 1, max(3, rx // 2 - 1)),
			)
		):

			def body_c(nx, ny, x, y, _glaze=glaze):
				lit = -nx * 0.55
				if _glaze:
					c = GLAZE_L if lit > 0.3 else (GLAZE_D if lit < -0.35 else GLAZE)
				else:
					c = CERAMIC_L if lit > 0.3 else (CERAMIC_D if lit < -0.35 else CERAMIC)
				if (x * 9 + y * 5) % 15 == 0:
					c = shade(c, 18 if lit > 0 else -16)
				return shade(c, int(rng.integers(-10, 11)))

			ellipse_fill(a, cx, cy, rxx, ryy, body_c)
			outline_ellipse(a, cx, cy, rxx, ryy)
			# hoop / glaze ring
			if i in (1, 2):
				for x in range(cx - rxx, cx + rxx + 1):
					nx = (x - cx) / max(1.0, rxx)
					if abs(nx) <= 1.0:
						put(a, x, cy + ryy - 1, shade(IRON_DK if glaze else CERAMIC_D, int(rng.integers(-4, 5))))

		# lid dome
		def lid_c(nx, ny, x, y):
			lit = -nx * 0.4 - ny * 0.5
			c = CERAMIC_L if lit > 0.2 else (CERAMIC_D if lit < -0.3 else CERAMIC)
			return shade(c, int(rng.integers(-8, 9)))

		ellipse_fill(a, cx, top_y, rx - 1, max(3, rx // 2), lid_c)
		outline_ellipse(a, cx, top_y, rx - 1, max(3, rx // 2))
		# lid knob
		ellipse_fill(
			a,
			cx,
			top_y - 3,
			3,
			2,
			lambda nx, ny, x, y: shade(WOOD_LT if nx < 0 else WOOD_DK, int(rng.integers(-4, 5))),
		)
		outline_ellipse(a, cx, top_y - 3, 3, 2)

		# brine drip / pickle hint at rim crack
		put(a, cx + rx - 2, top_y + 2, BRINE)
		put(a, cx + rx - 1, top_y + 3, shade(PICKLE_L, -10))
		put(a, cx - rx + 1, base_y - 4, shade(PICKLE, int(rng.integers(-6, 7))))

	# Three crocks: large back-left, medium right, small front
	crock(22, 48, 12, 28, True)
	crock(48, 46, 10, 24, False)
	crock(34, 50, 8, 18, True)

	# Salt scoop / ladle leaning (production cue)
	for t in range(0, 14):
		x = 58 + t // 4
		y = 28 + t
		put(a, x, y, shade(WOOD if t % 2 else WOOD_LT, int(rng.integers(-4, 5))))
		put(a, x + 1, y, shade(WOOD_DK, int(rng.integers(-4, 5))))
	ellipse_fill(
		a,
		62,
		26,
		5,
		3,
		lambda nx, ny, x, y: shade(IRON_LT if nx < 0 else IRON, int(rng.integers(-6, 7))),
	)
	outline_ellipse(a, 62, 26, 5, 3)

	# Contact shadow under cluster
	for x in range(10, 62):
		put(a, x, 52, shade(OUTLINE, 40))
		if 14 <= x <= 56:
			put(a, x, 53, shade(OUTLINE, 55))

	return Image.fromarray(crop_opaque(a), "RGBA")


def make_wine_rack() -> Image.Image:
	"""Diamond-cell wine bottle rack with bottles — production cellar, not mug_shelf."""
	rng = np.random.default_rng(52)
	a = blank(64, 72)

	def wood_fn(x, y):
		lit = (x - 32) / 30 - (y - 36) / 50
		c = WOOD_HI if lit > 0.3 else (WOOD_DK if lit < -0.25 else WOOD)
		if (x + y * 2) % 7 == 0:
			c = WOOD_LT
		return shade(c, int(rng.integers(-8, 9)))

	# Outer frame
	rect(a, 6, 6, 57, 66, wood_fn)
	outline_rect(a, 6, 6, 57, 66)
	# Inner hollow (dark cellar void behind bottles)
	rect(a, 10, 10, 53, 60, lambda x, y: shade(IRON_DK if (x + y) % 5 else (28, 22, 18, 255), int(rng.integers(-6, 7))))
	outline_rect(a, 10, 10, 53, 60)

	# Diamond lattice (wine rack cells)
	cells = [
		(20, 18),
		(32, 18),
		(44, 18),
		(14, 30),
		(26, 30),
		(38, 30),
		(50, 30),
		(20, 42),
		(32, 42),
		(44, 42),
		(26, 54),
		(38, 54),
	]
	for cx, cy in cells:
		# diamond wood cell
		for dy in range(-6, 7):
			span = 6 - abs(dy)
			for dx in range(-span, span + 1):
				x, y = cx + dx, cy + dy
				edge = abs(dx) + abs(dy) >= 5
				if edge:
					put(a, x, y, shade(WOOD_DK if dx > 0 else WOOD_LT, int(rng.integers(-4, 5))))
				elif abs(dx) + abs(dy) == 4:
					put(a, x, y, OUTLINE)

		def bottle_c(nx, ny, x, y):
			lit = -nx * 0.5
			c = GLASS_L if lit > 0.25 else (GLASS_D if lit < -0.3 else GLASS)
			# wine fill lower half of bottle ellipse
			if ny > -0.15:
				c = WINE_L if lit > 0.2 else WINE
			if abs(nx) < 0.2 and ny < -0.4:
				c = CORK
			return shade(c, int(rng.integers(-10, 11)))

		# bottle neck toward upper-left (3/4 cellar rack)
		ellipse_fill(a, cx - 1, cy + 1, 4, 3, bottle_c)
		# neck
		for y in range(cy - 5, cy - 1):
			for x in range(cx - 2, cx + 1):
				put(a, x, y, shade(GLASS if x == cx - 1 else GLASS_D, int(rng.integers(-4, 5))))
		put(a, cx - 1, cy - 6, CORK)
		put(a, cx - 2, cy - 6, CORK_D)
		# tiny label + glass highlight variety
		put(a, cx, cy + 1, LABEL)
		put(a, cx + 1, cy + 1, shade(LABEL, -20))
		put(a, cx - 3, cy, shade(GLASS_L, 30))
		put(a, cx + 2, cy + 2, shade(WINE_L, 20))
		if (cx + cy) % 3 == 0:
			put(a, cx - 2, cy + 2, shade((180, 90, 70, 255), int(rng.integers(-12, 13))))

	# Top rail plaque + brass studs
	rect(a, 22, 4, 42, 8, lambda x, y: shade(WOOD_HI if y == 5 else WOOD, int(rng.integers(-6, 7))))
	outline_rect(a, 22, 4, 42, 8)
	for x in (26, 30, 34, 38):
		put(a, x, 6, shade((190, 150, 70, 255), int(rng.integers(-10, 11))))
		put(a, x + 1, 6, shade(IRON_LT, int(rng.integers(-8, 9))))
	# Side grain flecks for craft color budget
	for y in range(12, 58, 3):
		put(a, 8, y, shade(WOOD_LT, int(rng.integers(-14, 15))))
		put(a, 55, y, shade(WOOD_DK, int(rng.integers(-14, 15))))
		put(a, 7, y + 1, shade((160, 120, 70, 255), int(rng.integers(-10, 11))))

	# Feet
	for x0, x1 in ((8, 14), (49, 55)):
		rect(a, x0, 64, x1, 69, lambda x, y: wood_fn(x, y))
		outline_rect(a, x0, 64, x1, 69)

	return Image.fromarray(crop_opaque(a), "RGBA")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	aging = make_cheese_aging()
	crock = make_pickle_crock()
	wine = make_wine_rack()
	aging.save(OUT / "cheese_aging_00.png")
	crock.save(OUT / "pickle_crock_00.png")
	wine.save(OUT / "wine_rack_00.png")
	print("wrote cheese_aging_00.png", aging.size)
	print("wrote pickle_crock_00.png", crock.size)
	print("wrote wine_rack_00.png", wine.size)
	for name, im in (
		("cheese_aging_00.png", aging),
		("pickle_crock_00.png", crock),
		("wine_rack_00.png", wine),
	):
		a = np.array(im)
		opaque = a[:, :, 3] > 200
		colors = len({tuple(c) for c in a[:, :, :3][opaque]})
		print(f"  {name}: unique_colors={colors} size={im.size}")
	gap = 12
	diag_w = aging.width + crock.width + wine.width + gap * 4
	diag_h = max(aging.height, crock.height, wine.height) + 20
	diag = Image.new("RGBA", (diag_w, diag_h), (32, 30, 28, 255))
	x = gap
	for im in (aging, crock, wine):
		diag.paste(im, (x, diag_h - im.height - 6), im)
		x += im.width + gap
	diag.save(OUT / "_diag_farm_cellar_c50_props.png")
	print("wrote _diag_farm_cellar_c50_props.png")


if __name__ == "__main__":
	main()
