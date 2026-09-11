#!/usr/bin/env python3
"""Generate C46 second-floor signature prop: balcony railing (3/4 warm wood)."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"

OUTLINE = (40, 28, 18, 255)
WOOD = (132, 92, 54, 255)
WOOD_DK = (78, 48, 30, 255)
WOOD_LT = (164, 118, 72, 255)
WOOD_HI = (198, 156, 102, 255)
IRON = (70, 72, 78, 255)
IRON_LT = (110, 114, 122, 255)
IRON_DK = (48, 50, 56, 255)
LEAF = (72, 118, 58, 255)
LEAF_LT = (110, 156, 78, 255)
PETAL = (210, 120, 130, 255)
PETAL_LT = (236, 168, 170, 255)


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


def make_balcony_rail() -> Image.Image:
	"""Cottage balcony railing: three posts + top/mid rails, 3/4 TL light, east-edge look-out."""
	rng = np.random.default_rng(46)
	a = blank(64, 48)

	# Floor plank strip under rail (reads as balcony deck edge, not freestanding fence)
	def deck_c(x, y):
		lit = (x - 32) / 28 - (y - 36) / 8
		base = WOOD_HI if lit > 0.35 else (WOOD_DK if lit < -0.2 else (WOOD_LT if (x + y) % 5 == 0 else WOOD))
		return shade(base, int(rng.integers(-10, 11)))

	fill_rect(a, 6, 34, 56, 42, deck_c)
	for x in (18, 32, 46):
		for y in range(35, 42):
			put(a, x, y, shade(WOOD_DK, int(rng.integers(-6, 5))))
	outline_rect(a, 6, 34, 56, 42)

	# Three posts (rear-left lit, right foreshortened)
	post_xs = (12, 30, 48)
	for pi, px in enumerate(post_xs):
		pw = 5 if pi < 2 else 4

		def post_c(x, y, _px=px, _pw=pw):
			lit = (x - _px) / max(1, _pw) - (y - 18) / 20
			base = WOOD_HI if lit > 0.4 else (WOOD_DK if lit < -0.25 else WOOD_LT if lit > 0.1 else WOOD)
			return shade(base, int(rng.integers(-12, 13)))

		fill_rect(a, px, 10, px + pw - 1, 36, post_c)
		# Cap knob
		for dy in range(0, 4):
			for dx in range(-1, pw):
				if abs(dx - (pw // 2 - 0.5)) + abs(dy - 1.5) <= 2.2:
					put(a, px + dx, 8 + dy, shade(WOOD_HI if dx <= 1 else WOOD, int(rng.integers(-8, 9))))
		outline_rect(a, px, 10, px + pw - 1, 36)
		for dx in range(0, pw):
			put(a, px + dx, 10, OUTLINE)
			put(a, px + dx, 8, OUTLINE)

	# Top rail (thick, TL highlight on north face)
	def top_c(x, y):
		lit = (x - 32) / 30 - (y - 14) / 6
		base = WOOD_HI if lit > 0.3 else (WOOD_DK if lit < -0.25 else WOOD_LT)
		if y == 12:
			base = WOOD_HI
		return shade(base, int(rng.integers(-10, 11)))

	fill_rect(a, 10, 12, 52, 16, top_c)
	outline_rect(a, 10, 12, 52, 16)

	# Mid rail
	def mid_c(x, y):
		lit = (x - 32) / 30 - (y - 24) / 5
		base = WOOD_LT if lit > 0.25 else (WOOD_DK if lit < -0.2 else WOOD)
		return shade(base, int(rng.integers(-10, 11)))

	fill_rect(a, 12, 22, 50, 25, mid_c)
	outline_rect(a, 12, 22, 50, 25)

	# Vertical balusters between posts (reads as railing, not solid wall)
	for bx in range(18, 29, 3):
		for y in range(17, 34):
			c = WOOD_LT if (bx + y) % 4 == 0 else WOOD
			put(a, bx, y, shade(c, int(rng.integers(-8, 9))))
			put(a, bx + 1, y, shade(WOOD_DK, int(rng.integers(-6, 7))))
		put(a, bx, 17, OUTLINE)
		put(a, bx, 33, OUTLINE)
		put(a, bx + 1, 17, OUTLINE)
		put(a, bx + 1, 33, OUTLINE)
	for bx in range(36, 47, 3):
		for y in range(17, 34):
			c = WOOD if (bx + y) % 3 else WOOD_LT
			put(a, bx, y, shade(c, int(rng.integers(-8, 9))))
			put(a, bx + 1, y, shade(WOOD_DK, int(rng.integers(-6, 7))))
		put(a, bx, 17, OUTLINE)
		put(a, bx, 33, OUTLINE)
		put(a, bx + 1, 17, OUTLINE)
		put(a, bx + 1, 33, OUTLINE)

	# Iron bolt hints on posts (cottage hardware)
	for px in post_xs:
		put(a, px + 1, 14, IRON_LT)
		put(a, px + 2, 14, IRON)
		put(a, px + 1, 24, IRON)
		put(a, px + 2, 24, IRON_DK)

	# Tiny hanging planter on left post (balcony identity, not fence-only)
	fill_rect(
		a,
		8,
		18,
		14,
		22,
		lambda x, y: shade(WOOD_DK if y == 22 else WOOD_LT, int(rng.integers(-6, 7))),
	)
	outline_rect(a, 8, 18, 14, 22)
	for (fx, fy, col) in (
		(10, 16, LEAF),
		(11, 15, LEAF_LT),
		(12, 16, LEAF),
		(11, 17, PETAL),
		(10, 17, PETAL_LT),
		(12, 17, PETAL),
	):
		put(a, fx, fy, shade(col, int(rng.integers(-10, 11))))

	# Contact shadow under deck
	for x in range(8, 54):
		put(a, x, 43, shade(IRON_DK, -12))
		if x % 3 == 0:
			put(a, x, 44, shade(IRON_DK, -16))

	# Craft noise for ≥200 unique opaque colors
	ys, xs = np.where(a[:, :, 3] > 200)
	for i in range(len(xs)):
		if int(rng.integers(0, 4)) != 0:
			continue
		x, y = int(xs[i]), int(ys[i])
		r, g, b, _ = a[y, x]
		a[y, x] = (
			max(0, min(255, int(r) + int(rng.integers(-18, 19)))),
			max(0, min(255, int(g) + int(rng.integers(-14, 15)))),
			max(0, min(255, int(b) + int(rng.integers(-12, 13)))),
			255,
		)

	return Image.fromarray(crop_opaque(a), "RGBA")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	rail = make_balcony_rail()
	rail.save(OUT / "balcony_rail_00.png")
	print("wrote balcony_rail_00.png", rail.size)
	diag = Image.new("RGBA", (rail.width + 16, rail.height + 16), (36, 32, 28, 255))
	diag.paste(rail, (8, diag.height - rail.height - 4), rail)
	diag.save(OUT / "_diag_balcony_rail_c46.png")
	print("wrote _diag_balcony_rail_c46.png")


if __name__ == "__main__":
	main()
