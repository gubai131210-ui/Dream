#!/usr/bin/env python3
"""Generate C47 attic unique props: old trunk + cobweb (3/4, TL light, dusty wood)."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"

OUTLINE = (34, 24, 16, 255)
WOOD = (122, 88, 56, 255)
WOOD_DK = (74, 50, 34, 255)
WOOD_LT = (152, 116, 78, 255)
WOOD_HI = (182, 146, 102, 255)
DUST = (176, 162, 136, 255)
LEATHER = (96, 62, 42, 255)
LEATHER_DK = (60, 38, 26, 255)
LEATHER_LT = (132, 92, 64, 255)
BRASS = (172, 136, 60, 255)
BRASS_LT = (214, 180, 94, 255)
BRASS_DK = (112, 84, 38, 255)
WEB = (214, 210, 202, 255)
WEB_DK = (172, 166, 154, 255)
WEB_HI = (238, 234, 226, 255)
WEB_MID = (198, 194, 186, 255)
SHADOW = (32, 26, 20, 200)


def blank(w: int, h: int) -> np.ndarray:
	return np.zeros((h, w, 4), dtype=np.uint8)


def put(a: np.ndarray, x: int, y: int, c: tuple[int, int, int, int]) -> None:
	h, w = a.shape[:2]
	if 0 <= x < w and 0 <= y < h:
		a[y, x] = c


def shade(base: tuple[int, int, int, int], d: int) -> tuple[int, int, int, int]:
	a = base[3] if len(base) > 3 else 255
	return (
		max(0, min(255, base[0] + d)),
		max(0, min(255, base[1] + d)),
		max(0, min(255, base[2] + d)),
		a,
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


def micro_noise(a: np.ndarray, rng: np.random.Generator, chance: int = 3, amp: int = 14) -> None:
	ys, xs = np.where(a[:, :, 3] > 200)
	for i in range(len(xs)):
		if int(rng.integers(0, chance)) != 0:
			continue
		x, y = int(xs[i]), int(ys[i])
		r, g, b, _al = a[y, x]
		a[y, x] = (
			max(0, min(255, int(r) + int(rng.integers(-amp, amp + 1)))),
			max(0, min(255, int(g) + int(rng.integers(-amp + 2, amp - 1)))),
			max(0, min(255, int(b) + int(rng.integers(-amp + 4, amp - 3)))),
			255,
		)


def make_trunk_old() -> Image.Image:
	"""Single dusty steamer trunk — rounded lid, brass latch, TL 3/4."""
	rng = np.random.default_rng(47)
	a = blank(52, 42)

	# --- Lid top (parallelogram-ish 3/4) ---
	def lid_top(x, y):
		lit = (x - 16) / 20 - (y - 7) / 7
		if lit > 0.45:
			c = WOOD_HI
		elif lit < -0.28:
			c = WOOD_DK
		elif (x + y * 2) % 6 == 0:
			c = WOOD_LT
		else:
			c = WOOD
		return shade(c, int(rng.integers(-8, 9)))

	fill_rect(a, 9, 5, 38, 14, lid_top)
	# sparse dust flecks (not noise carpet)
	for fx, fy in ((12, 7), (20, 8), (28, 6), (34, 10), (16, 12), (24, 11)):
		put(a, fx, fy, shade(DUST, int(rng.integers(-6, 7))))

	def lid_front(x, y):
		lit = (x - 24) / 22
		c = WOOD_LT if lit < -0.3 else (WOOD_DK if lit > 0.35 else WOOD)
		return shade(c, int(rng.integers(-7, 8)))

	fill_rect(a, 7, 14, 36, 20, lid_front)

	def lid_side(x, y):
		c = WOOD_DK if (x + y) % 2 == 0 else WOOD
		return shade(c, int(rng.integers(-6, 7)))

	fill_rect(a, 38, 7, 44, 18, lid_side)
	# lid plank seams
	for x in (17, 25, 33):
		for y in range(6, 14):
			put(a, x, y, shade(WOOD_DK, -4))
	for y in (16, 19):
		for x in range(8, 36):
			put(a, x, y, shade(WOOD_DK, -6))
	outline_rect(a, 9, 5, 38, 14)
	outline_rect(a, 7, 14, 36, 20)
	for y in range(7, 19):
		put(a, 44, y, OUTLINE)
	put(a, 38, 5, OUTLINE)
	put(a, 44, 7, OUTLINE)
	put(a, 36, 20, OUTLINE)
	put(a, 44, 18, OUTLINE)

	# --- Body (leather-bound) ---
	def body_front(x, y):
		lit = (x - 22) / 24
		c = LEATHER_LT if lit < -0.28 else (LEATHER_DK if lit > 0.4 else LEATHER)
		if y >= 32:
			c = shade(c, -14)
		return shade(c, int(rng.integers(-8, 9)))

	fill_rect(a, 7, 20, 36, 34, body_front)

	def body_side(x, y):
		c = LEATHER_DK if (x + y) % 3 == 0 else LEATHER
		return shade(c, int(rng.integers(-7, 8)))

	fill_rect(a, 36, 18, 44, 32, body_side)
	# wood straps
	for y in (24, 30):
		for x in range(8, 36):
			base = WOOD_LT if x % 5 == 0 else WOOD
			put(a, x, y, shade(base, int(rng.integers(-6, 7))))
			put(a, x, y + 1, shade(WOOD_DK, -2))
	outline_rect(a, 7, 20, 36, 34)
	for y in range(18, 33):
		put(a, 44, y, OUTLINE)
	put(a, 36, 34, OUTLINE)
	put(a, 44, 32, OUTLINE)

	# Brass latch plate (readable)
	for dy in range(0, 6):
		for dx in range(0, 7):
			lit = -dx * 0.1 - dy * 0.15
			c = BRASS_LT if lit > -0.2 else (BRASS_DK if lit < -0.7 else BRASS)
			put(a, 18 + dx, 16 + dy, shade(c, int(rng.integers(-5, 6))))
	outline_rect(a, 18, 16, 24, 21, BRASS_DK)
	# hasp keyhole
	put(a, 21, 18, OUTLINE)
	put(a, 21, 19, BRASS_DK)
	put(a, 20, 18, BRASS_LT)
	put(a, 22, 18, BRASS)

	# Corner brass rivets
	for rx, ry in ((9, 7), (36, 7), (9, 32), (34, 32), (10, 22), (33, 22), (40, 12), (40, 28)):
		put(a, rx, ry, BRASS_LT)
		put(a, rx + 1, ry, BRASS)
		put(a, rx, ry + 1, BRASS_DK)

	# Lid roundness hint
	put(a, 9, 5, OUTLINE)
	put(a, 10, 5, WOOD_HI)
	put(a, 37, 5, WOOD)
	put(a, 38, 5, OUTLINE)

	# Feet / contact shadow
	for x in range(9, 42):
		put(a, x, 36, shade((28, 22, 16, 220), 0))
	for x in range(12, 38):
		put(a, x, 37, shade((24, 18, 14, 160), 0))

	# Extra dust flecks on body
	for fx, fy in ((11, 26), (27, 28), (14, 31), (30, 25)):
		put(a, fx, fy, shade(DUST, -10))

	micro_noise(a, rng, chance=4, amp=12)
	return Image.fromarray(crop_opaque(a), "RGBA")


def make_cobweb() -> Image.Image:
	"""Corner cobweb — dusty threads from NW anchor, attic signature."""
	rng = np.random.default_rng(147)
	a = blank(44, 40)

	anchor_x, anchor_y = 3, 2
	# Radial strands
	rays = [
		(1.0, 0.08),
		(0.98, 0.22),
		(0.92, 0.38),
		(0.82, 0.55),
		(0.68, 0.72),
		(0.5, 0.88),
		(0.3, 0.98),
		(0.12, 0.92),
		(0.02, 0.75),
	]
	for ui, (ux, uy) in enumerate(rays):
		length = 28 + int(rng.integers(-3, 4))
		for t in range(length):
			x = int(round(anchor_x + ux * t))
			y = int(round(anchor_y + uy * t * 0.88))
			fade = t / max(1, length)
			if fade < 0.15:
				c = WEB_HI
			elif fade < 0.45:
				c = WEB
			elif fade < 0.75:
				c = WEB_MID
			else:
				c = WEB_DK
			if int(rng.integers(0, 10)) == 0 and t > 4:
				continue
			put(a, x, y, shade(c, int(rng.integers(-14, 15))))
			if t % 4 == 0:
				put(a, x + 1, y, shade(WEB_DK, int(rng.integers(-10, 11))))
			# secondary thread offset
			if ui % 2 == 0 and t % 5 == 2:
				put(a, x, y + 1, shade(WEB_MID, int(rng.integers(-8, 9))))

	# Concentric rings
	for ring in (5, 9, 13, 17, 22):
		for i in range(0, 70):
			ang = 0.08 + (i / 70.0) * 1.35
			x = int(round(anchor_x + ring * np.cos(ang)))
			y = int(round(anchor_y + ring * np.sin(ang) * 0.92))
			if int(rng.integers(0, 6)) == 0:
				continue
			phase = (i + ring) % 5
			c = [WEB_HI, WEB, WEB_MID, WEB_DK, DUST][phase]
			put(a, x, y, shade(c, int(rng.integers(-16, 17))))

	# Junction dust / silk clumps
	for cx, cy in ((7, 6), (12, 10), (16, 15), (9, 14), (20, 12), (14, 20), (22, 18), (6, 11)):
		put(a, cx, cy, shade(DUST, int(rng.integers(-10, 11))))
		put(a, cx + 1, cy, shade(WEB_MID, int(rng.integers(-8, 9))))
		put(a, cx, cy + 1, shade(WEB_DK, int(rng.integers(-6, 7))))

	# Tiny spider silhouette
	sx, sy = 15, 13
	put(a, sx, sy, OUTLINE)
	put(a, sx + 1, sy, shade(OUTLINE, 12))
	put(a, sx - 1, sy, WEB_DK)
	put(a, sx + 2, sy, WEB_DK)
	put(a, sx, sy + 1, shade(OUTLINE, 8))
	put(a, sx - 1, sy + 1, WEB_MID)
	put(a, sx + 2, sy + 1, WEB_MID)

	# Anchor mass at corner
	for dx in range(0, 4):
		for dy in range(0, 3):
			put(a, anchor_x + dx, anchor_y + dy, shade(WEB_HI if dx + dy < 2 else WEB, int(rng.integers(-8, 9))))

	micro_noise(a, rng, chance=2, amp=18)
	return Image.fromarray(crop_opaque(a), "RGBA")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	trunk = make_trunk_old()
	trunk.save(OUT / "trunk_old_00.png")
	print("wrote trunk_old_00.png", trunk.size)

	web = make_cobweb()
	web.save(OUT / "cobweb_00.png")
	print("wrote cobweb_00.png", web.size)

	pad = 8
	w = trunk.width + web.width + pad * 3
	h = max(trunk.height, web.height) + pad * 2
	diag = Image.new("RGBA", (w, h), (42, 36, 30, 255))
	diag.paste(trunk, (pad, h - trunk.height - 4), trunk)
	diag.paste(web, (pad * 2 + trunk.width, h - web.height - 4), web)
	diag.save(OUT / "_diag_attic_c47_props.png")
	print("wrote _diag_attic_c47_props.png")


if __name__ == "__main__":
	main()
