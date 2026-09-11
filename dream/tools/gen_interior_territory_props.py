#!/usr/bin/env python3
"""Generate seamless interior fence family (H/V same fence) + mass props.

Fence lock (INTERIOR_TERRITORY):
- H and V are TWO VIEWS of one fence, not two designs.
- Segments tile at 32px (1 tile) with no visual gaps (shared post language).
- Stall = taller 3-rail; pen = shorter 2-rail; same wood / post / rail thickness.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"

# Cozy wood ramp
OUTLINE = (42, 28, 18, 255)
DARK = (78, 48, 28, 255)
MID = (128, 82, 48, 255)
LIT = (168, 118, 72, 255)
HI = (198, 156, 102, 255)
STRAW = (176, 148, 72, 255)
STRAW_D = (132, 108, 48, 255)
STRAW_L = (210, 180, 110, 255)
SACK = (142, 118, 72, 255)
SACK_D = (92, 72, 42, 255)
SACK_L = (172, 146, 98, 255)
SACK_TIE = (64, 48, 28, 255)

TILE = 32
POST_W = 4


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
	for x in range(min(x0, x1), max(x0, x1) + 1):
		put(a, x, y, c)


def vline(a: np.ndarray, x: int, y0: int, y1: int, c: tuple) -> None:
	for y in range(min(y0, y1), max(y0, y1) + 1):
		put(a, x, y, c)


def draw_post(a: np.ndarray, x: int, y0: int, y1: int) -> None:
	"""Square post: outline / lit left / mid / dark right."""
	fill_rect(a, x, y0, x + POST_W - 1, y1, MID)
	vline(a, x, y0, y1, OUTLINE)
	vline(a, x + 1, y0, y1, HI)
	vline(a, x + POST_W - 2, y0, y1, DARK)
	vline(a, x + POST_W - 1, y0, y1, OUTLINE)
	hline(a, x, x + POST_W - 1, y0, HI)
	hline(a, x, x + POST_W - 1, y1, OUTLINE)


def draw_rail_h(a: np.ndarray, x0: int, x1: int, y: int, thick: int = 3) -> None:
	"""Horizontal beam with top highlight."""
	fill_rect(a, x0, y, x1, y + thick - 1, MID)
	hline(a, x0, x1, y, HI)
	if thick >= 3:
		hline(a, x0, x1, y + 1, LIT)
	hline(a, x0, x1, y + thick - 1, OUTLINE)


def make_fence_h(rail_ys: list[int], ground_y: int, rail_thick: int = 3, pickets: bool = False) -> Image.Image:
	"""Front view: 32px tile. Left post + continuous rails/pickets to right edge."""
	h = ground_y + 2
	a = blank(TILE, h)
	if pickets:
		# Vertical pickets fill the span so chickens cannot walk through.
		for x in range(POST_W, TILE, 3):
			fill_rect(a, x, rail_ys[0], x + 1, ground_y - 1, MID if x % 6 == 0 else LIT)
			vline(a, x, rail_ys[0], ground_y - 1, OUTLINE)
		# Top + bottom rails lock pickets
		draw_rail_h(a, 0, TILE - 1, rail_ys[0], rail_thick)
		draw_rail_h(a, 0, TILE - 1, ground_y - rail_thick - 1, rail_thick)
	else:
		for ry in rail_ys:
			draw_rail_h(a, 0, TILE - 1, ry, rail_thick)
	draw_post(a, 0, rail_ys[0] - 2, ground_y)
	hline(a, 0, POST_W - 1, ground_y, OUTLINE)
	return Image.fromarray(a, "RGBA")


def make_fence_v(rail_ys: list[int], ground_y: int, rail_thick: int = 3, pickets: bool = False) -> Image.Image:
	"""Side view of SAME fence — same rail count/thickness/picket language."""
	h = ground_y + 2
	a = blank(TILE, h)
	near_x = 5
	far_x = TILE - POST_W - 5
	# Depth rails / picket edges (foreshortened)
	if pickets:
		for i, x in enumerate(range(near_x + POST_W, far_x + 1, 4)):
			t = (x - near_x) / max(1, far_x - near_x)
			y0 = rail_ys[0] + int(round(t))
			fill_rect(a, x, y0, x + 1, ground_y - 1, LIT if i % 2 == 0 else MID)
			vline(a, x, y0, ground_y - 1, OUTLINE)
		for ry in (rail_ys[0], ground_y - rail_thick - 1):
			for x in range(near_x + POST_W - 1, far_x + 1):
				t = (x - near_x) / max(1, far_x - near_x)
				yy = ry + int(round(t))
				put(a, x, yy, HI)
				put(a, x, yy + 1, MID)
				put(a, x, yy + rail_thick - 1, OUTLINE)
	else:
		for ry in rail_ys:
			for x in range(near_x + POST_W - 1, far_x + 1):
				t = (x - near_x) / max(1, far_x - near_x)
				yy = ry + int(round(t * 1.5))
				for k in range(rail_thick):
					c = HI if k == 0 else (MID if k < rail_thick - 1 else OUTLINE)
					put(a, x, yy + k, c)
	draw_post(a, near_x, rail_ys[0] - 2, ground_y)
	draw_post(a, far_x, rail_ys[0], ground_y)
	hline(a, near_x, near_x + POST_W - 1, ground_y, OUTLINE)
	hline(a, far_x, far_x + POST_W - 1, ground_y, OUTLINE)
	return Image.fromarray(a, "RGBA")


def make_grain_stack() -> Image.Image:
	"""Bulging grain sacks piled high — soft bags, not boxes."""
	a = blank(64, 80)

	def sack(cx: int, cy: int, rx: int, ry: int, shade: float = 0.0) -> None:
		for y in range(cy - ry, cy + ry + 1):
			for x in range(cx - rx, cx + rx + 1):
				nx = (x - cx) / max(1, rx)
				ny = (y - cy) / max(1, ry)
				# softer sack silhouette (squircle)
				if abs(nx) ** 2.4 + abs(ny) ** 2.2 > 1.0:
					continue
				# light from top-left
				lit = (-nx * 0.35 - ny * 0.45) + shade
				if lit > 0.25:
					c = SACK_L
				elif lit < -0.2:
					c = SACK_D
				else:
					c = SACK
				put(a, x, y, c)
		# outline rim
		for t in range(0, 360, 4):
			rad = np.deg2rad(t)
			x = int(round(cx + rx * np.cos(rad) * 0.98))
			y = int(round(cy + ry * np.sin(rad) * 0.98))
			put(a, x, y, OUTLINE)
		# mouth / tie
		hline(a, cx - 3, cx + 3, cy - ry + 2, SACK_TIE)
		hline(a, cx - 2, cx + 2, cy - ry + 3, SACK_D)
		# grain spill on crown
		for dx in range(-4, 5):
			put(a, cx + dx, cy - ry, STRAW if dx % 2 == 0 else STRAW_D)

	# pyramid mass
	sack(18, 66, 14, 10, 0.05)
	sack(40, 68, 13, 9, -0.05)
	sack(54, 62, 11, 8, 0.0)
	sack(22, 48, 12, 9, 0.1)
	sack(42, 50, 13, 9, 0.0)
	sack(32, 34, 12, 9, 0.08)
	sack(34, 20, 10, 8, 0.12)
	# loose grain peak
	for x, y in ((30, 10), (34, 8), (38, 10), (32, 12), (36, 12), (34, 6)):
		put(a, x, y, STRAW_L if y < 9 else STRAW)
		put(a, x, y + 1, STRAW_D)
	# crop
	ys, xs = np.where(a[:, :, 3] > 0)
	crop = a[ys.min() - 1 : ys.max() + 2, xs.min() - 1 : xs.max() + 2]
	return Image.fromarray(crop, "RGBA")


def make_hay_stack() -> Image.Image:
	"""Continuous hay mound mass (one silhouette, not floating ellipses)."""
	a = blank(52, 64)
	# stacked elliptical lobes that overlap into one pile
	lobes = [
		(26, 52, 22, 12),
		(18, 42, 16, 11),
		(34, 40, 15, 10),
		(26, 30, 16, 11),
		(22, 20, 13, 9),
		(30, 14, 11, 8),
		(26, 8, 8, 6),
	]
	for cx, cy, rx, ry in lobes:
		for y in range(cy - ry, cy + ry + 1):
			for x in range(cx - rx, cx + rx + 1):
				nx = (x - cx) / max(1.0, rx)
				ny = (y - cy) / max(1.0, ry)
				if nx * nx + ny * ny > 1.0:
					continue
				lit = -nx * 0.3 - ny * 0.5
				if lit > 0.3:
					c = STRAW_L
				elif lit < -0.25:
					c = STRAW_D
				else:
					c = STRAW if (x + 3 * y) % 4 else STRAW_D
				put(a, x, y, c)
	# silhouette outline
	mask = a[:, :, 3] > 0
	h, w = mask.shape
	for y in range(h):
		for x in range(w):
			if not mask[y, x]:
				continue
			for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
				if nx < 0 or ny < 0 or nx >= w or ny >= h or not mask[ny, nx]:
					put(a, x, y, OUTLINE)
					break
	ys, xs = np.where(a[:, :, 3] > 0)
	crop = a[ys.min() - 1 : ys.max() + 2, xs.min() - 1 : xs.max() + 2]
	return Image.fromarray(crop, "RGBA")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	# Stall: dense board rails (small gaps — livestock barrier)
	stall_rails = [5, 11, 17, 23, 29]
	stall_ground = 36
	# Pen: picket fill + top/bottom rails (chicken-proof)
	pen_rails = [6]
	pen_ground = 28

	items = {
		"stall_rail_00.png": make_fence_h(stall_rails, stall_ground, rail_thick=4, pickets=False),
		"stall_rail_v_00.png": make_fence_v(stall_rails, stall_ground, rail_thick=4, pickets=False),
		"pen_fence_00.png": make_fence_h(pen_rails, pen_ground, rail_thick=3, pickets=True),
		"pen_fence_v_00.png": make_fence_v(pen_rails, pen_ground, rail_thick=3, pickets=True),
		"grain_stack_00.png": make_grain_stack(),
		"hay_stack_00.png": make_hay_stack(),
	}
	for name, im in items.items():
		im.save(OUT / name)
		print("wrote", name, im.size)

	h = items["stall_rail_00.png"]
	pair = Image.new("RGBA", (TILE * 3, h.height), (30, 28, 24, 255))
	for i in range(3):
		pair.paste(h, (TILE * i, 0), h)
	pair.save(OUT / "_diag_fence_h_seamless.png")
	pv = items["pen_fence_00.png"]
	pp = Image.new("RGBA", (TILE * 3, pv.height), (30, 28, 24, 255))
	for i in range(3):
		pp.paste(pv, (TILE * i, 0), pv)
	pp.save(OUT / "_diag_pen_h_seamless.png")
	# H vs V family sheet
	sheet = Image.new("RGBA", (TILE * 4 + 12, max(h.height, items["stall_rail_v_00.png"].height) + 8), (36, 32, 28, 255))
	sheet.paste(items["stall_rail_00.png"], (4, 4), items["stall_rail_00.png"])
	sheet.paste(items["stall_rail_v_00.png"], (TILE + 8, 4), items["stall_rail_v_00.png"])
	sheet.paste(items["pen_fence_00.png"], (TILE * 2 + 12, 4), items["pen_fence_00.png"])
	sheet.paste(items["pen_fence_v_00.png"], (TILE * 3 + 16, 4), items["pen_fence_v_00.png"])
	sheet.save(OUT / "_diag_fence_family.png")
	print("diag ok")


if __name__ == "__main__":
	main()
