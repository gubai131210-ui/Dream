#!/usr/bin/env python3
"""Generate C13 mill unique props: millstone + gear frame (3/4 pixel craft)."""
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
STONE = (150, 142, 130, 255)
STONE_M = (118, 112, 102, 255)
STONE_DK = (86, 82, 74, 255)
STONE_HI = (188, 180, 168, 255)
IRON = (70, 72, 78, 255)
IRON_LT = (110, 114, 122, 255)
IRON_DK = (48, 50, 56, 255)
IRON_HI = (150, 154, 162, 255)
FLOUR = (230, 220, 200, 255)
FLOUR_D = (200, 188, 164, 255)
BRASS = (180, 140, 60, 255)
BRASS_L = (220, 180, 90, 255)


def blank(w: int, h: int) -> np.ndarray:
	return np.zeros((h, w, 4), dtype=np.uint8)


def put(a: np.ndarray, x: int, y: int, c: tuple[int, int, int, int]) -> None:
	h, w = a.shape[:2]
	if 0 <= x < w and 0 <= y < h:
		a[y, x] = c


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


def make_millstone() -> Image.Image:
	rng = np.random.default_rng(13)
	a = blank(72, 56)
	for y in range(40, 54):
		for x in range(8, 64):
			lit = (x - 36) / 30 - (y - 47) / 10
			c = WOOD_HI if lit > 0.35 else (WOOD_DK if lit < -0.2 else (WOOD_LT if (x + y) % 5 == 0 else WOOD))
			put(a, x, y, shade(c, int(rng.integers(-10, 11))))
	for x in range(8, 64):
		put(a, x, 40, OUTLINE)
		put(a, x, 53, OUTLINE)
	for y in range(40, 54):
		put(a, 8, y, OUTLINE)
		put(a, 63, y, OUTLINE)

	def lower_c(nx, ny, x, y):
		lit = -nx * 0.4 - ny * 0.55
		base = STONE_HI if lit > 0.35 else (STONE_DK if lit < -0.25 else (STONE if (x * 3 + y * 5) % 7 else STONE_M))
		if (x * 17 + y * 13) % 29 == 0 and lit > -0.1:
			return FLOUR if (x + y) % 2 == 0 else FLOUR_D
		return shade(base, int(rng.integers(-14, 15)))

	ellipse_fill(a, 36, 30, 26, 14, lower_c)
	outline_ellipse(a, 36, 30, 26, 14)

	def upper_c(nx, ny, x, y):
		lit = -nx * 0.45 - ny * 0.5
		c = STONE_HI if lit > 0.4 else (STONE_DK if lit < -0.3 else STONE_M)
		if abs(nx) < 0.12 and abs(ny) < 0.25:
			return shade(IRON_DK, int(rng.integers(-6, 7)))
		if (x + 2 * y) % 11 == 0:
			return STONE
		# radial grooves
		ang = int((np.arctan2(ny, nx) + np.pi) * 8 / np.pi) % 2
		if ang == 0 and lit > -0.2:
			c = shade(c, -12)
		return shade(c, int(rng.integers(-12, 13)))

	ellipse_fill(a, 36, 24, 22, 11, upper_c)
	outline_ellipse(a, 36, 24, 22, 11)
	for y in range(14, 28):
		for x in range(34, 39):
			put(a, x, y, shade(IRON if (x + y) % 2 == 0 else IRON_LT, int(rng.integers(-8, 9))))
	for x in range(33, 40):
		put(a, x, 14, OUTLINE)
	for y in range(4, 16):
		w = 6 + (y - 4) // 2
		for x in range(36 - w, 37 + w):
			lit = (x - 36) / 8
			c = WOOD_LT if lit < -0.2 else (WOOD_DK if lit > 0.3 else WOOD)
			put(a, x, y, shade(c, int(rng.integers(-8, 9))))
		put(a, 36 - w, y, OUTLINE)
		put(a, 36 + w, y, OUTLINE)
	for x in range(30, 43):
		put(a, x, 4, OUTLINE)
	for x, y in ((20, 34), (22, 35), (48, 33), (50, 34), (24, 36), (46, 36), (28, 37), (18, 32), (52, 32)):
		put(a, x, y, FLOUR)
		put(a, x + 1, y, FLOUR_D)
		put(a, x, y + 1, shade(FLOUR, -20))
	return Image.fromarray(crop_opaque(a), "RGBA")


def gear_disk(a: np.ndarray, cx: int, cy: int, r: int, teeth: int = 8, iron: bool = True, rng=None) -> None:
	if rng is None:
		rng = np.random.default_rng(0)

	def gc(nx, ny, x, y):
		dist = (nx * nx + ny * ny) ** 0.5
		lit = -nx * 0.4 - ny * 0.5
		if iron:
			if dist < 0.25:
				return shade(IRON_DK, int(rng.integers(-8, 9)))
			if dist < 0.45:
				return shade(BRASS if lit > 0 else BRASS_L, int(rng.integers(-10, 11)))
			c = IRON_HI if lit > 0.35 else (IRON_DK if lit < -0.25 else IRON)
			if abs(nx) < 0.08 or abs(ny) < 0.08:
				c = IRON_LT
			return shade(c, int(rng.integers(-12, 13)))
		return shade(WOOD_HI if lit > 0.3 else (WOOD_DK if lit < -0.2 else WOOD), int(rng.integers(-10, 11)))

	ellipse_fill(a, cx, cy, r, int(r * 0.85), gc)
	outline_ellipse(a, cx, cy, r, int(r * 0.85))
	for i in range(teeth):
		ang = np.deg2rad(i * (360 / teeth))
		tx = int(round(cx + (r + 2) * np.cos(ang)))
		ty = int(round(cy + (r * 0.85 + 2) * np.sin(ang)))
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				put(a, tx + dx, ty + dy, shade(IRON_LT if iron else WOOD_LT, int(rng.integers(-6, 7))))
		put(a, tx, ty, OUTLINE)


def make_mill_gear() -> Image.Image:
	rng = np.random.default_rng(17)
	a = blank(56, 64)
	# fill frame cavity first (no hollow black)
	for y in range(14, 52):
		for x in range(12, 44):
			put(a, x, y, shade((52, 40, 28, 255), int(rng.integers(-8, 9))))
	for y in range(8, 60):
		for x in range(6, 12):
			put(a, x, y, shade(WOOD_DK if x in (6, 11) else (WOOD_LT if (y % 4) == 0 else WOOD), int(rng.integers(-8, 9))))
		for x in range(44, 50):
			put(a, x, y, shade(WOOD_DK if x in (44, 49) else (WOOD_LT if (y % 4) == 0 else WOOD), int(rng.integers(-8, 9))))
	for x in range(6, 50):
		for y in range(8, 14):
			put(a, x, y, shade(WOOD_HI if y < 10 else WOOD, int(rng.integers(-8, 9))))
		for y in range(52, 58):
			put(a, x, y, shade(WOOD if y < 55 else WOOD_DK, int(rng.integers(-8, 9))))
	for x in range(6, 50):
		put(a, x, 8, OUTLINE)
		put(a, x, 57, OUTLINE)
	for y in range(8, 58):
		put(a, 6, y, OUTLINE)
		put(a, 49, y, OUTLINE)
	for x in range(12, 44):
		put(a, x, 30, shade(IRON, int(rng.integers(-6, 7))))
		put(a, x, 31, shade(IRON_LT, int(rng.integers(-6, 7))))
		put(a, x, 32, shade(IRON_DK, int(rng.integers(-6, 7))))
	gear_disk(a, 22, 28, 12, teeth=10, iron=True, rng=rng)
	gear_disk(a, 38, 34, 9, teeth=8, iron=True, rng=rng)
	gear_disk(a, 30, 18, 6, teeth=6, iron=False, rng=rng)
	for x, y in ((10, 12), (45, 12), (10, 54), (45, 54), (28, 10)):
		put(a, x, y, BRASS_L)
		put(a, x + 1, y, BRASS)
	return Image.fromarray(crop_opaque(a), "RGBA")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	ms = make_millstone()
	ge = make_mill_gear()
	ms.save(OUT / "millstone_00.png")
	ge.save(OUT / "mill_gear_00.png")
	print("wrote millstone_00.png", ms.size)
	print("wrote mill_gear_00.png", ge.size)
	diag = Image.new("RGBA", (ms.width + ge.width + 24, max(ms.height, ge.height) + 16), (36, 32, 28, 255))
	diag.paste(ms, (8, diag.height - ms.height - 4), ms)
	diag.paste(ge, (16 + ms.width, diag.height - ge.height - 4), ge)
	diag.save(OUT / "_diag_mill_props.png")
	print("wrote _diag_mill_props.png")


if __name__ == "__main__":
	main()
