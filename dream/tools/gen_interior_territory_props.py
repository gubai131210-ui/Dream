#!/usr/bin/env python3
"""Generate interior territory props: stall rails, pen fence, grain stack."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"

# Cozy wood ramp (matches furniture family midtones)
OUTLINE = (42, 28, 18, 255)
DARK = (78, 48, 28, 255)
MID = (128, 82, 48, 255)
LIT = (168, 118, 72, 255)
HI = (198, 156, 102, 255)
STRAW = (176, 148, 72, 255)
STRAW_D = (132, 108, 48, 255)
SACK = (148, 122, 78, 255)
SACK_D = (98, 78, 48, 255)
SACK_L = (178, 152, 108, 255)


def blank(w: int, h: int) -> np.ndarray:
	return np.zeros((h, w, 4), dtype=np.uint8)


def put(a: np.ndarray, x: int, y: int, c: tuple[int, int, int, int]) -> None:
	h, w = a.shape[:2]
	if 0 <= x < w and 0 <= y < h:
		a[y, x] = c


def fill_rect(a: np.ndarray, x0: int, y0: int, x1: int, y1: int, c: tuple) -> None:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			put(a, x, y, c)


def hline(a: np.ndarray, x0: int, x1: int, y: int, c: tuple) -> None:
	for x in range(x0, x1 + 1):
		put(a, x, y, c)


def vline(a: np.ndarray, x: int, y0: int, y1: int, c: tuple) -> None:
	for y in range(y0, y1 + 1):
		put(a, x, y, c)


def trim(a: np.ndarray, pad: int = 1) -> Image.Image:
	ys, xs = np.where(a[:, :, 3] > 0)
	if len(xs) == 0:
		return Image.fromarray(a, "RGBA")
	y0, y1 = max(0, ys.min() - pad), min(a.shape[0], ys.max() + 1 + pad)
	x0, x1 = max(0, xs.min() - pad), min(a.shape[1], xs.max() + 1 + pad)
	return Image.fromarray(a[y0:y1, x0:x1], "RGBA")


def make_stall_rail() -> Image.Image:
	"""Horizontal stall rail: two posts + two rails, 3/4 cozy wood."""
	a = blank(48, 36)
	# posts
	for px in (4, 40):
		fill_rect(a, px, 8, px + 3, 33, MID)
		vline(a, px, 8, 33, OUTLINE)
		vline(a, px + 3, 8, 33, DARK)
		hline(a, px, px + 3, 8, HI)
		hline(a, px, px + 3, 33, OUTLINE)
	# upper rail
	fill_rect(a, 6, 12, 41, 15, LIT)
	hline(a, 6, 41, 12, HI)
	hline(a, 6, 41, 15, DARK)
	# lower rail
	fill_rect(a, 6, 22, 41, 25, MID)
	hline(a, 6, 41, 22, LIT)
	hline(a, 6, 41, 25, OUTLINE)
	return trim(a)


def make_stall_rail_v() -> Image.Image:
	"""Short vertical-facing rail segment (for north/south ends)."""
	a = blank(28, 40)
	# left post thick, right thinner (perspective)
	fill_rect(a, 6, 6, 10, 36, MID)
	vline(a, 6, 6, 36, OUTLINE)
	vline(a, 10, 6, 36, DARK)
	fill_rect(a, 16, 10, 19, 36, DARK)
	vline(a, 16, 10, 36, OUTLINE)
	vline(a, 19, 10, 36, MID)
	# rails receding
	for y, c1, c2 in ((12, LIT, DARK), (22, MID, OUTLINE)):
		hline(a, 8, 18, y, c1)
		hline(a, 8, 18, y + 2, c2)
		put(a, 8, y + 1, MID)
		put(a, 18, y + 1, DARK)
	return trim(a)


def make_pen_fence() -> Image.Image:
	"""Low chicken-pen fence segment (shorter than stall rail)."""
	a = blank(40, 28)
	for px in (3, 34):
		fill_rect(a, px, 6, px + 2, 25, MID)
		vline(a, px, 6, 25, OUTLINE)
		vline(a, px + 2, 6, 25, DARK)
	fill_rect(a, 4, 10, 35, 12, LIT)
	hline(a, 4, 35, 10, HI)
	hline(a, 4, 35, 12, DARK)
	fill_rect(a, 4, 17, 35, 19, MID)
	hline(a, 4, 35, 17, LIT)
	hline(a, 4, 35, 19, OUTLINE)
	return trim(a)


def make_grain_stack() -> Image.Image:
	"""Tall grain/sack stack — vertical mass for barn aisle end."""
	a = blank(56, 72)

	def sack(cx: int, cy: int, w: int, h: int) -> None:
		x0, x1 = cx - w // 2, cx + w // 2
		y0, y1 = cy - h // 2, cy + h // 2
		fill_rect(a, x0, y0, x1, y1, SACK)
		hline(a, x0, x1, y0, SACK_L)
		hline(a, x0, x1, y1, SACK_D)
		vline(a, x0, y0, y1, OUTLINE)
		vline(a, x1, y0, y1, DARK)
		# tie
		hline(a, cx - 2, cx + 2, y0 + 2, DARK)
		# grain spill hint on top sacks
		if h >= 10:
			for dx in range(-w // 3, w // 3):
				put(a, cx + dx, y0 + 1, STRAW if dx % 2 == 0 else STRAW_D)

	# bottom row (wide)
	sack(16, 58, 18, 14)
	sack(34, 60, 16, 12)
	sack(48, 56, 14, 12)
	# mid
	sack(20, 42, 16, 12)
	sack(36, 44, 18, 13)
	# top peak
	sack(28, 28, 16, 12)
	sack(30, 16, 12, 10)
	# loose grain crown
	for x, y in ((24, 8), (28, 6), (32, 8), (30, 10), (26, 10)):
		put(a, x, y, STRAW)
		put(a, x, y + 1, STRAW_D)
	return trim(a)


def make_hay_stack() -> Image.Image:
	"""Tall hay mass for stall back wall."""
	a = blank(48, 56)
	# layered hay mounds
	layers = [
		(24, 48, 20, 10),
		(20, 38, 18, 10),
		(28, 36, 16, 9),
		(24, 26, 16, 10),
		(22, 16, 14, 9),
		(26, 10, 10, 8),
	]
	for cx, cy, w, h in layers:
		for y in range(cy - h // 2, cy + h // 2 + 1):
			for x in range(cx - w // 2, cx + w // 2 + 1):
				# elliptical soft mound
				nx = (x - cx) / max(1, w / 2)
				ny = (y - cy) / max(1, h / 2)
				if nx * nx + ny * ny <= 1.05:
					c = STRAW if (x + y) % 3 else STRAW_D
					if y <= cy - h // 3:
						c = HI if (x + y) % 2 == 0 else STRAW
					put(a, x, y, c)
		# outline bottom
		hline(a, cx - w // 2, cx + w // 2, cy + h // 2, OUTLINE)
	return trim(a)


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	items = {
		"stall_rail_00.png": make_stall_rail(),
		"stall_rail_v_00.png": make_stall_rail_v(),
		"pen_fence_00.png": make_pen_fence(),
		"grain_stack_00.png": make_grain_stack(),
		"hay_stack_00.png": make_hay_stack(),
	}
	for name, im in items.items():
		path = OUT / name
		im.save(path)
		print("wrote", name, im.size)


if __name__ == "__main__":
	main()
