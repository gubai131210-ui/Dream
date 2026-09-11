#!/usr/bin/env python3
"""Interior fence family: one design, H/V views + 4 corners, 32px seamless tiles.

Pen = short dense board fence (same language H/V/corners).
Stall = taller dense board fence (same language H/V).
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"

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
POST_W = 5


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
	fill_rect(a, x, y0, x + POST_W - 1, y1, MID)
	vline(a, x, y0, y1, OUTLINE)
	vline(a, x + 1, y0, y1, HI)
	vline(a, x + POST_W - 2, y0, y1, DARK)
	vline(a, x + POST_W - 1, y0, y1, OUTLINE)
	hline(a, x, x + POST_W - 1, y0, HI)
	hline(a, x, x + POST_W - 1, y1, OUTLINE)


def draw_board_h(a: np.ndarray, x0: int, x1: int, y: int, thick: int) -> None:
	fill_rect(a, x0, y, x1, y + thick - 1, MID)
	hline(a, x0, x1, y, HI)
	for k in range(1, thick - 1):
		hline(a, x0, x1, y + k, LIT if k == 1 else MID)
	hline(a, x0, x1, y + thick - 1, OUTLINE)


def board_ys(ground_y: int, n: int, thick: int) -> list[int]:
	"""Evenly pack n boards from top to near ground with ≤1px gaps."""
	usable = ground_y - 4 - n * thick
	gap = max(1, usable // max(1, n - 1)) if n > 1 else 1
	ys = []
	y = 3
	for _ in range(n):
		ys.append(y)
		y += thick + gap
	return ys


def make_fence_h(ground_y: int, n_boards: int, thick: int = 4) -> Image.Image:
	"""Front view along X: left post + boards to right edge (seamless tile)."""
	a = blank(TILE, ground_y + 2)
	ys = board_ys(ground_y, n_boards, thick)
	for y in ys:
		draw_board_h(a, 0, TILE - 1, y, thick)
	draw_post(a, 0, ys[0] - 2, ground_y)
	return Image.fromarray(a, "RGBA")


def make_fence_v(ground_y: int, n_boards: int, thick: int = 4) -> Image.Image:
	"""Side view of SAME boards: near post + boards foreshortened in depth + far post.

	Must read as the same board fence turned 90°, not a ladder / picket wall.
	"""
	a = blank(TILE, ground_y + 2)
	ys = board_ys(ground_y, n_boards, thick)
	near = 4
	far = TILE - POST_W - 4
	for y in ys:
		for x in range(near + POST_W - 1, far + 1):
			t = (x - near) / max(1.0, far - near)
			yy = y + int(round(t * 2))  # slight drop into depth
			for k in range(thick):
				c = HI if k == 0 else (LIT if k == 1 else (OUTLINE if k == thick - 1 else MID))
				put(a, x, yy + k, c)
	draw_post(a, near, ys[0] - 2, ground_y)
	draw_post(a, far, ys[0], ground_y)
	return Image.fromarray(a, "RGBA")


def make_corner(kind: str, ground_y: int, n_boards: int, thick: int = 4) -> Image.Image:
	"""Corner joins H+V runs: post + boards east/west and north/south stubs."""
	a = blank(TILE, ground_y + 2)
	ys = board_ys(ground_y, n_boards, thick)
	# Corner post centered-leftish for NW/SW, rightish for NE/SE
	if kind in ("nw", "sw"):
		px = 4
	else:
		px = TILE - POST_W - 4
	draw_post(a, px, ys[0] - 2, ground_y)
	# Horizontal stub (along X toward enclosure interior from corner)
	for y in ys:
		if kind in ("nw", "sw"):
			draw_board_h(a, px + POST_W - 1, TILE - 1, y, thick)
		else:
			draw_board_h(a, 0, px + 1, y, thick)
	# Vertical stub (along Y / depth) — short foreshortened boards matching V language
	for y in ys:
		if kind in ("nw", "ne"):
			# boards going "south" (down screen) from post
			x0 = px + 1
			for i in range(10):
				yy = y + 2 + i
				for k in range(thick):
					put(a, x0 + (0 if kind == "nw" else POST_W - 2), yy + k, LIT if k < 2 else DARK)
		else:
			# boards going "north" (up) — short stub above
			x0 = px + 1
			for i in range(8):
				yy = y - 1 - i
				for k in range(min(2, thick)):
					put(a, x0 + (0 if kind == "sw" else POST_W - 2), yy + k, LIT)
	return Image.fromarray(a, "RGBA")


def make_grain_stack() -> Image.Image:
	a = blank(64, 80)

	def sack(cx: int, cy: int, rx: int, ry: int, shade: float = 0.0) -> None:
		for y in range(cy - ry, cy + ry + 1):
			for x in range(cx - rx, cx + rx + 1):
				nx = (x - cx) / max(1, rx)
				ny = (y - cy) / max(1, ry)
				if abs(nx) ** 2.4 + abs(ny) ** 2.2 > 1.0:
					continue
				lit = (-nx * 0.35 - ny * 0.45) + shade
				c = SACK_L if lit > 0.25 else (SACK_D if lit < -0.2 else SACK)
				put(a, x, y, c)
		for t in range(0, 360, 4):
			rad = np.deg2rad(t)
			put(a, int(round(cx + rx * np.cos(rad) * 0.98)), int(round(cy + ry * np.sin(rad) * 0.98)), OUTLINE)
		hline(a, cx - 3, cx + 3, cy - ry + 2, SACK_TIE)

	sack(18, 66, 14, 10, 0.05)
	sack(40, 68, 13, 9, -0.05)
	sack(54, 62, 11, 8, 0.0)
	sack(22, 48, 12, 9, 0.1)
	sack(42, 50, 13, 9, 0.0)
	sack(32, 34, 12, 9, 0.08)
	sack(34, 20, 10, 8, 0.12)
	for x, y in ((30, 10), (34, 8), (38, 10), (32, 12), (36, 12)):
		put(a, x, y, STRAW_L)
		put(a, x, y + 1, STRAW_D)
	ys, xs = np.where(a[:, :, 3] > 0)
	return Image.fromarray(a[ys.min() - 1 : ys.max() + 2, xs.min() - 1 : xs.max() + 2], "RGBA")


def make_hay_stack() -> Image.Image:
	a = blank(52, 64)
	lobes = [(26, 52, 22, 12), (18, 42, 16, 11), (34, 40, 15, 10), (26, 30, 16, 11), (22, 20, 13, 9), (30, 14, 11, 8), (26, 8, 8, 6)]
	for cx, cy, rx, ry in lobes:
		for y in range(cy - ry, cy + ry + 1):
			for x in range(cx - rx, cx + rx + 1):
				nx = (x - cx) / max(1.0, rx)
				ny = (y - cy) / max(1.0, ry)
				if nx * nx + ny * ny > 1.0:
					continue
				lit = -nx * 0.3 - ny * 0.5
				c = STRAW_L if lit > 0.3 else (STRAW_D if lit < -0.25 else (STRAW if (x + 3 * y) % 4 else STRAW_D))
				put(a, x, y, c)
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
	return Image.fromarray(a[ys.min() - 1 : ys.max() + 2, xs.min() - 1 : xs.max() + 2], "RGBA")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	# Overwrite ALL pen/stall fence names so Godot cannot keep mixed old V + new H.
	pen_g, pen_n, pen_t = 28, 4, 4
	stall_g, stall_n, stall_t = 36, 6, 4

	items: dict[str, Image.Image] = {
		"pen_fence_00.png": make_fence_h(pen_g, pen_n, pen_t),
		"pen_fence_v_00.png": make_fence_v(pen_g, pen_n, pen_t),
		"pen_corner_nw_00.png": make_corner("nw", pen_g, pen_n, pen_t),
		"pen_corner_ne_00.png": make_corner("ne", pen_g, pen_n, pen_t),
		"pen_corner_sw_00.png": make_corner("sw", pen_g, pen_n, pen_t),
		"pen_corner_se_00.png": make_corner("se", pen_g, pen_n, pen_t),
		"stall_rail_00.png": make_fence_h(stall_g, stall_n, stall_t),
		"stall_rail_v_00.png": make_fence_v(stall_g, stall_n, stall_t),
		"grain_stack_00.png": make_grain_stack(),
		"hay_stack_00.png": make_hay_stack(),
	}
	for name, im in items.items():
		im.save(OUT / name)
		print("wrote", name, im.size)

	# Family diag
	keys = [
		"pen_fence_00", "pen_fence_v_00",
		"pen_corner_nw_00", "pen_corner_ne_00", "pen_corner_sw_00", "pen_corner_se_00",
	]
	imgs = [items[k + ".png"] for k in keys]
	H = max(i.height for i in imgs) + 8
	W = sum(i.width for i in imgs) + 4 * (len(imgs) + 1)
	sheet = Image.new("RGBA", (W, H), (36, 32, 28, 255))
	x = 4
	for im in imgs:
		sheet.paste(im, (x, H - im.height - 4), im)
		x += im.width + 4
	sheet.save(OUT / "_diag_pen_family.png")
	# Seamless H×3
	h = items["pen_fence_00.png"]
	pair = Image.new("RGBA", (TILE * 3, h.height), (30, 28, 24, 255))
	for i in range(3):
		pair.paste(h, (TILE * i, 0), h)
	pair.save(OUT / "_diag_fence_h_seamless.png")
	print("diag ok")


if __name__ == "__main__":
	main()
