#!/usr/bin/env python3
"""Generate C48 roof unique props: chimney stack, clothesline, telescope (3/4 pixel craft)."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"

OUTLINE = (36, 28, 22, 255)
# Cool brick / stone (roof chimney — not indoor hearth)
BRICK = (148, 92, 78, 255)
BRICK_DK = (98, 58, 48, 255)
BRICK_LT = (178, 120, 100, 255)
BRICK_HI = (210, 156, 132, 255)
MORTAR = (120, 112, 108, 255)
STONE = (118, 122, 130, 255)
STONE_DK = (72, 76, 84, 255)
STONE_LT = (158, 162, 170, 255)
STONE_HI = (196, 200, 208, 255)
SOOT = (48, 46, 50, 255)
SMOKE = (170, 176, 186, 180)
WOOD = (132, 92, 54, 255)
WOOD_DK = (78, 48, 30, 255)
WOOD_LT = (164, 118, 72, 255)
WOOD_HI = (198, 156, 102, 255)
ROPE = (150, 128, 90, 255)
ROPE_DK = (100, 82, 52, 255)
CLOTH_W = (228, 224, 216, 255)
CLOTH_W_DK = (180, 176, 168, 255)
CLOTH_B = (86, 118, 168, 255)
CLOTH_B_DK = (52, 78, 120, 255)
CLOTH_R = (176, 72, 68, 255)
CLOTH_R_DK = (120, 42, 40, 255)
CLOTH_G = (72, 128, 88, 255)
CLOTH_G_DK = (42, 86, 56, 255)
BRASS = (188, 148, 72, 255)
BRASS_L = (228, 196, 110, 255)
BRASS_D = (128, 96, 42, 255)
IRON = (64, 66, 74, 255)
IRON_LT = (110, 114, 122, 255)
IRON_DK = (42, 44, 50, 255)
SHADOW = (40, 38, 44, 90)


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
		base[3] if len(base) > 3 else 255,
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


def make_chimney() -> Image.Image:
	"""Roof brick chimney stack with pot/cap — outdoor silhouette, NOT indoor fireplace."""
	rng = np.random.default_rng(48)
	a = blank(48, 72)

	# Contact shadow on roof deck
	for y in range(60, 70):
		for x in range(8, 40):
			if abs(x - 24) / 18 + abs(y - 65) / 5 < 1.0:
				put(a, x, y, (40, 38, 44, int(70 + rng.integers(0, 40))))

	# Flashing / foot collar (stone)
	fill_rect(
		a,
		10,
		56,
		38,
		64,
		lambda x, y: shade(
			STONE_HI if (x + y) % 5 == 0 else (STONE_DK if y in (56, 64) or x in (10, 38) else STONE),
			int(rng.integers(-12, 13)),
		),
	)
	outline_rect(a, 10, 56, 38, 64)

	# Main stack (front + right foreshorten) — tall brick column
	x0, y0, w, h = 14, 18, 18, 40
	x1, y1 = x0 + w - 1, y0 + h - 1
	side = 7

	def front(x, y):
		nx = (x - x0) / max(1, w - 1)
		ny = (y - y0) / max(1, h - 1)
		# brick courses
		row = (y - y0) // 4
		col = (x - x0 + (row % 2) * 3) // 6
		lit = -nx * 0.4 - ny * 0.25
		base = BRICK_HI if lit > 0.3 else (BRICK_DK if lit < -0.25 else BRICK)
		if (y - y0) % 4 == 0:
			base = MORTAR
		if (x - x0 - (row % 2) * 3) % 6 == 0:
			base = shade(MORTAR, -10)
		# soot streak near top mouth
		if ny < 0.22 and (x * 3 + y) % 5 != 0:
			base = SOOT if lit < 0 else shade(BRICK_DK, -20)
		if (x * 17 + y * 13 + col) % 23 == 0:
			base = shade(base, int(rng.integers(-22, 18)))
		return shade(base, int(rng.integers(-10, 11)))

	fill_rect(a, x0, y0, x1, y1, front)
	# right side foreshorten
	for dy in range(h):
		yy = y0 + dy
		for sx in range(side):
			xx = x1 + 1 + sx
			c = BRICK_DK if sx > side // 2 else BRICK
			if dy % 4 == 0:
				c = MORTAR
			put(a, xx, yy - min(sx // 2, 2), shade(c, int(rng.integers(-12, 10))))
	# top foreshorten cap ledge
	for sx in range(w + side - 1):
		xx = x0 + sx - 1
		yy = y0 - 1 - min(sx // 4, 3)
		put(a, xx, yy, shade(STONE_LT if sx < w // 2 else STONE, int(rng.integers(-8, 9))))

	outline_rect(a, x0, y0, x1, y1)

	# Chimney pot / crown (distinct from fireplace mantel)
	pot_x0, pot_y0 = 16, 8
	pot_x1, pot_y1 = 30, 17
	fill_rect(
		a,
		pot_x0,
		pot_y0,
		pot_x1,
		pot_y1,
		lambda x, y: shade(
			STONE_HI if y < pot_y0 + 2 else (STONE_DK if x in (pot_x0, pot_x1) else STONE),
			int(rng.integers(-10, 11)),
		),
	)
	# flue hole (dark mouth — no indoor fire)
	for y in range(10, 15):
		for x in range(19, 28):
			put(a, x, y, SOOT if (x + y) % 3 else IRON_DK)
	outline_rect(a, pot_x0, pot_y0, pot_x1, pot_y1)
	# pot rim overhang
	for x in range(15, 32):
		put(a, x, 7, STONE_HI)
		put(a, x, 6, OUTLINE)

	# Soft smoke wisps (static pixels — roof cue)
	for sx, sy in ((21, 3), (22, 2), (24, 1), (26, 3), (23, 4), (27, 2)):
		put(a, sx, sy, shade(SMOKE, int(rng.integers(-20, 20))))
		put(a, sx + 1, sy, (170, 176, 186, 120))

	# Tiny iron band mid-stack (name≠pixels cue)
	for x in range(x0 + 1, x1):
		put(a, x, 36, IRON)
		put(a, x, 37, IRON_LT if x % 2 else IRON_DK)

	return Image.fromarray(crop_opaque(a), "RGBA")


def _shirt(a: np.ndarray, cx: int, top: int, color, color_dk, rng: np.random.Generator, w: int = 8, h: int = 12) -> None:
	"""Simple hanging garment silhouette under the line."""
	x0 = cx - w // 2
	for y in range(top, top + h):
		taper = abs(y - top) // 4
		for x in range(x0 + taper, x0 + w - taper):
			lit = (x - cx) / max(1, w)
			c = color if lit < 0.15 else color_dk
			if (x + y * 3) % 7 == 0:
				c = shade(c, 18)
			put(a, x, y, shade(c, int(rng.integers(-8, 9))))
	# sleeves / shoulders
	for dx in (-w // 2 - 1, w // 2):
		for dy in range(0, 4):
			put(a, cx + dx, top + dy, shade(color_dk, int(rng.integers(-6, 7))))
	# hem outline
	for x in range(x0 + 1, x0 + w - 1):
		put(a, x, top + h - 1, OUTLINE)
	put(a, cx, top - 1, ROPE_DK)  # peg


def make_clothesline() -> Image.Image:
	"""Two posts + sagging rope with hanging laundry — not herbs."""
	rng = np.random.default_rng(480)
	a = blank(88, 56)

	# Ground contact under posts
	for px in (10, 76):
		for y in range(48, 54):
			for x in range(px - 4, px + 5):
				if abs(x - px) / 5 + abs(y - 51) / 3 < 1.0:
					put(a, x, y, (40, 38, 44, int(60 + rng.integers(0, 35))))

	def post(px: int) -> None:
		fill_rect(
			a,
			px - 2,
			10,
			px + 2,
			50,
			lambda x, y: shade(
				WOOD_HI if x <= px else (WOOD_DK if x >= px + 1 else WOOD),
				int(rng.integers(-10, 11)),
			),
		)
		outline_rect(a, px - 2, 10, px + 2, 50)
		# cross arm tip
		for x in range(px - 3, px + 4):
			put(a, x, 10, WOOD_LT)
			put(a, x, 9, OUTLINE)

	post(10)
	post(76)

	# Sagging rope between posts
	for x in range(12, 75):
		t = (x - 12) / 63.0
		sag = int(4 + 10 * (1.0 - (2 * t - 1) ** 2))
		y = 12 + sag
		put(a, x, y, ROPE if x % 2 else ROPE_DK)
		put(a, x, y + 1, shade(ROPE_DK, -10))

	# Laundry pieces (left→right): white shirt, blue trousers, red cloth, green apron
	_shirt(a, 24, 18, CLOTH_W, CLOTH_W_DK, rng, w=9, h=14)
	# trousers (two legs)
	for leg_dx in (-2, 3):
		for y in range(20, 36):
			for x in range(40 + leg_dx, 44 + leg_dx):
				put(a, x, y, shade(CLOTH_B if x < 42 + leg_dx else CLOTH_B_DK, int(rng.integers(-8, 9))))
		put(a, 41 + leg_dx, 19, ROPE_DK)
	_shirt(a, 54, 22, CLOTH_R, CLOTH_R_DK, rng, w=8, h=11)
	_shirt(a, 66, 20, CLOTH_G, CLOTH_G_DK, rng, w=7, h=13)

	# Peg dots
	for px in (24, 41, 54, 66):
		put(a, px, 16, WOOD_DK)
		put(a, px, 17, WOOD)

	return Image.fromarray(crop_opaque(a), "RGBA")


def make_telescope() -> Image.Image:
	"""Small brass/wood rooftop telescope on tripod — stargazing signature."""
	rng = np.random.default_rng(481)
	a = blank(48, 56)

	# Tripod shadow
	for y in range(48, 54):
		for x in range(8, 40):
			if abs(x - 24) / 16 + abs(y - 51) / 3 < 1.0:
				put(a, x, y, (40, 38, 44, int(55 + rng.integers(0, 30))))

	# Tripod legs (3)
	legs = [(12, 50, 22, 28), (36, 50, 26, 28), (24, 52, 24, 30)]
	for x0, y0, x1, y1 in legs:
		steps = max(abs(x1 - x0), abs(y1 - y0), 1)
		for i in range(steps + 1):
			t = i / steps
			x = int(round(x0 + (x1 - x0) * t))
			y = int(round(y0 + (y1 - y0) * t))
			put(a, x, y, WOOD_DK if i % 3 else WOOD)
			put(a, x + 1, y, WOOD_LT)
	# hub
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			if dx * dx + dy * dy <= 5:
				put(a, 24 + dx, 28 + dy, IRON if dx * dx + dy * dy > 2 else IRON_LT)

	# Tube body (angled up-right for sky)
	# rear eyepiece
	fill_rect(
		a,
		14,
		22,
		20,
		28,
		lambda x, y: shade(BRASS_D if x < 16 else BRASS, int(rng.integers(-8, 9))),
	)
	outline_rect(a, 14, 22, 20, 28)
	# main barrel
	for i in range(18):
		x = 20 + i
		y = 20 - i // 3
		for t in range(-3, 4):
			c = BRASS_L if t < -1 else (BRASS_D if t > 1 else BRASS)
			if i in (4, 10, 15):
				c = IRON_LT  # bands
			put(a, x, y + t, shade(c, int(rng.integers(-6, 7))))
		put(a, x, y - 4, OUTLINE)
		put(a, x, y + 4, OUTLINE)
	# objective lens glint
	for t in range(-2, 3):
		put(a, 38, 14 + t, IRON_DK)
		put(a, 39, 14 + t, shade(STONE_HI, 20) if abs(t) < 2 else OUTLINE)
	put(a, 39, 14, (220, 230, 255, 255))  # cool night lens flash

	# wood mount plate under barrel
	fill_rect(
		a,
		20,
		28,
		30,
		32,
		lambda x, y: shade(WOOD if (x + y) % 2 else WOOD_LT, int(rng.integers(-8, 9))),
	)
	outline_rect(a, 20, 28, 30, 32)

	return Image.fromarray(crop_opaque(a), "RGBA")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	chimney = make_chimney()
	line = make_clothesline()
	scope = make_telescope()
	chimney.save(OUT / "chimney_00.png")
	line.save(OUT / "clothesline_00.png")
	scope.save(OUT / "telescope_00.png")
	print("wrote chimney_00.png", chimney.size)
	print("wrote clothesline_00.png", line.size)
	print("wrote telescope_00.png", scope.size)

	pad = 12
	dw = chimney.width + line.width + scope.width + pad * 4
	dh = max(chimney.height, line.height, scope.height) + 20
	diag = Image.new("RGBA", (dw, dh), (28, 32, 48, 255))
	x = pad
	for im in (chimney, line, scope):
		diag.paste(im, (x, dh - im.height - 8), im)
		x += im.width + pad
	diag.save(OUT / "_diag_roof_c48_props.png")
	print("wrote _diag_roof_c48_props.png")


if __name__ == "__main__":
	main()
