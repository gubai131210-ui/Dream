#!/usr/bin/env python3
"""Generate Wave F CivicTour signature props C40–C45 (3/4 TL light, Name≠pixels)."""
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
STONE = (118, 112, 104, 255)
STONE_DK = (78, 74, 68, 255)
STONE_LT = (148, 142, 132, 255)
STONE_HI = (178, 172, 160, 255)
GLASS = (160, 198, 210, 180)
GLASS_HI = (210, 230, 236, 200)
BONE = (210, 198, 168, 255)
BONE_DK = (160, 148, 118, 255)
WATER = (64, 128, 168, 255)
WATER_DK = (36, 84, 120, 255)
WATER_LT = (110, 178, 210, 255)
WATER_HI = (170, 220, 236, 255)
FISH_O = (210, 120, 70, 255)
FISH_B = (70, 140, 190, 255)
STEAM = (230, 230, 236, 140)
TILE = (188, 196, 204, 255)
TILE_DK = (140, 148, 156, 255)
TILE_BLU = (150, 170, 190, 255)
BRASS = (180, 140, 60, 255)
BRASS_HI = (220, 190, 100, 255)
BRASS_DK = (120, 90, 40, 255)
CLOTH = (96, 64, 88, 255)
CLOTH_LT = (140, 96, 120, 255)
CLOTH_DK = (64, 40, 58, 255)
GOLD = (200, 168, 70, 255)


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


def micro_noise(a: np.ndarray, seed: int) -> None:
	rng = np.random.default_rng(seed)
	ys, xs = np.where(a[:, :, 3] > 200)
	for i in range(len(xs)):
		if int(rng.integers(0, 4)) != 0:
			continue
		x, y = int(xs[i]), int(ys[i])
		r, g, b, al = a[y, x]
		a[y, x] = (
			max(0, min(255, int(r) + int(rng.integers(-18, 19)))),
			max(0, min(255, int(g) + int(rng.integers(-14, 15)))),
			max(0, min(255, int(b) + int(rng.integers(-12, 13)))),
			255,
		)


def save(name: str, img: Image.Image) -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	path = OUT / name
	img.save(path)
	print(f"wrote {name}", img.size)
	diag = Image.new("RGBA", (img.width + 16, img.height + 16), (36, 32, 28, 255))
	diag.paste(img, (8, diag.height - img.height - 4), img)
	dname = f"_diag_{name}"
	diag.save(OUT / dname)
	print(f"wrote {dname}")


# ── C40 museum exhibit case ──────────────────────────────────────────
def make_exhibit_case() -> Image.Image:
	"""Glass-front wood display case with fossil bone + plaque (museum, not shelf)."""
	rng = np.random.default_rng(40)
	a = blank(56, 64)

	def wood_c(x, y):
		lit = (x - 20) / 28 - (y - 30) / 40
		base = WOOD_HI if lit > 0.35 else (WOOD_DK if lit < -0.25 else (WOOD_LT if (x + y) % 5 == 0 else WOOD))
		return shade(base, int(rng.integers(-10, 11)))

	# Cabinet body
	fill_rect(a, 8, 12, 46, 54, wood_c)
	# Right foreshortened side
	fill_rect(a, 47, 14, 52, 54, lambda x, y: shade(WOOD_DK, int(rng.integers(-8, 9))))
	# Top lid face
	fill_rect(a, 10, 8, 48, 14, lambda x, y: shade(WOOD_HI if y < 11 else WOOD_LT, int(rng.integers(-8, 9))))
	outline_rect(a, 8, 12, 46, 54)
	outline_rect(a, 10, 8, 48, 14)
	outline_rect(a, 47, 14, 52, 54)

	# Glass panel (inset)
	def glass_c(x, y):
		lit = (x - 18) / 20 - (y - 28) / 24
		c = GLASS_HI if lit > 0.3 else GLASS
		# diagonal shine
		if abs((x - 14) - (y - 20) * 0.4) < 1.2:
			c = (230, 240, 245, 220)
		return shade(c, int(rng.integers(-6, 7)))[:3] + (c[3],)

	fill_rect(a, 12, 16, 42, 42, glass_c)
	outline_rect(a, 12, 16, 42, 42, IRON_DK)

	# Fossil bone silhouette inside (reads as exhibit, not empty cabinet)
	def bone_c(nx, ny, x, y):
		lit = -nx * 0.3 - ny * 0.4
		return shade(BONE if lit > -0.1 else BONE_DK, int(rng.integers(-8, 9)))

	ellipse_fill(a, 22, 28, 7, 4, bone_c)
	ellipse_fill(a, 30, 30, 5, 3, bone_c)
	ellipse_fill(a, 36, 26, 4, 5, bone_c)
	# knuckle joints
	for cx, cy in ((16, 28), (28, 32), (34, 24)):
		ellipse_fill(a, cx, cy, 2, 2, bone_c)
	outline_ellipse(a, 22, 28, 7, 4)
	outline_ellipse(a, 30, 30, 5, 3)

	# Plaque under glass
	fill_rect(a, 16, 44, 38, 50, lambda x, y: shade(BRASS if y < 47 else BRASS_DK, int(rng.integers(-6, 7))))
	outline_rect(a, 16, 44, 38, 50, BRASS_DK)
	for x in range(18, 37, 3):
		put(a, x, 47, shade(BRASS_HI, -10))

	# Feet
	for fx in (12, 40):
		fill_rect(a, fx, 55, fx + 4, 58, lambda x, y: shade(WOOD_DK, int(rng.integers(-4, 5))))
		outline_rect(a, fx, 55, fx + 4, 58)

	# Contact shadow
	for x in range(10, 50):
		put(a, x, 60, shade(IRON_DK, -12))

	micro_noise(a, 40)
	return Image.fromarray(crop_opaque(a), "RGBA")


# ── C41 aquarium fish tank ───────────────────────────────────────────
def make_fish_tank() -> Image.Image:
	"""Rectangular glass aquarium with water, plants, two fish (not a grocery shelf)."""
	rng = np.random.default_rng(41)
	a = blank(64, 52)

	# Wood stand
	def stand_c(x, y):
		lit = (x - 32) / 30 - (y - 42) / 8
		base = WOOD_HI if lit > 0.3 else (WOOD_DK if lit < -0.2 else WOOD)
		return shade(base, int(rng.integers(-10, 11)))

	fill_rect(a, 6, 38, 56, 48, stand_c)
	outline_rect(a, 6, 38, 56, 48)

	# Tank frame
	fill_rect(a, 8, 6, 54, 38, lambda x, y: shade(IRON_LT if y < 10 else IRON, int(rng.integers(-6, 7))))
	outline_rect(a, 8, 6, 54, 38)

	# Water volume
	def water_c(x, y):
		depth = (y - 10) / 26
		lit = (x - 20) / 30 - depth * 0.4
		if lit > 0.45:
			c = WATER_HI
		elif depth > 0.7:
			c = WATER_DK
		elif lit > 0.1:
			c = WATER_LT
		else:
			c = WATER
		# caustic bands
		if (x + y * 2) % 7 == 0:
			c = shade(c, 18)
		return shade(c, int(rng.integers(-8, 9)))

	fill_rect(a, 11, 10, 51, 35, water_c)

	# Surface highlight strip
	for x in range(12, 51):
		put(a, x, 10, WATER_HI)
		if x % 3 == 0:
			put(a, x, 11, shade(WATER_LT, 10))

	# Kelp / plants (left)
	for i, (bx, top) in enumerate(((16, 18), (20, 14), (24, 20))):
		for y in range(top, 35):
			wx = bx + int(2 * np.sin((y + i) * 0.4))
			put(a, wx, y, shade((40, 110, 70, 255), int(rng.integers(-12, 13))))
			put(a, wx + 1, y, shade((60, 140, 80, 255), int(rng.integers(-10, 11))))

	# Gravel bed
	for x in range(12, 51):
		for y in range(33, 36):
			put(a, x, y, shade(STONE if (x + y) % 3 else STONE_DK, int(rng.integers(-10, 11))))

	# Orange fish
	def fish_body(cx, cy, col, flip=1):
		for dy in range(-3, 4):
			for dx in range(-6, 5):
				if (dx / 6.0) ** 2 + (dy / 3.2) ** 2 <= 1.0:
					lit = -dx * flip * 0.08 - dy * 0.1
					put(a, cx + dx * flip, cy + dy, shade(col if lit > -0.05 else shade(col, -30), int(rng.integers(-6, 7))))
		# tail
		for dy in range(-3, 4):
			put(a, cx - 7 * flip, cy + dy, shade(col, -20 + abs(dy) * 4))
			put(a, cx - 8 * flip, cy + dy // 2, shade(col, -10))
		put(a, cx + 3 * flip, cy - 1, OUTLINE)  # eye

	fish_body(38, 20, FISH_O, 1)
	fish_body(28, 26, FISH_B, -1)

	# Glass shine
	for y in range(12, 34):
		put(a, 14, y, (220, 235, 245, 160))
		if y % 2 == 0:
			put(a, 15, y, (200, 220, 235, 100))

	# Filter box top-right
	fill_rect(a, 44, 4, 52, 10, lambda x, y: shade(IRON_LT, int(rng.integers(-6, 7))))
	outline_rect(a, 44, 4, 52, 10)

	micro_noise(a, 41)
	return Image.fromarray(crop_opaque(a), "RGBA")


# ── C42 hotspring soak pool ──────────────────────────────────────────
def make_soak_pool() -> Image.Image:
	"""Irregular stone hot-spring pool with milky water + steam wisps (mountain soak)."""
	rng = np.random.default_rng(42)
	a = blank(72, 48)

	# Irregular rock rim (ellipse + bumps — not a rectangle bath)
	def rim_c(nx, ny, x, y):
		lit = -nx * 0.5 - ny * 0.35
		base = STONE_HI if lit > 0.35 else (STONE_DK if lit < -0.25 else (STONE_LT if (x + y) % 4 == 0 else STONE))
		return shade(base, int(rng.integers(-12, 13)))

	ellipse_fill(a, 36, 26, 30, 16, rim_c)
	# Extra rock bumps
	for cx, cy, rx, ry in ((12, 22, 6, 5), (58, 28, 7, 5), (28, 12, 8, 4), (44, 38, 7, 4)):
		ellipse_fill(a, cx, cy, rx, ry, rim_c)

	# Inner water (milky mineral tint)
	def soak_c(nx, ny, x, y):
		lit = -nx * 0.4 - ny * 0.3
		# warm mineral aqua
		base = (150, 190, 188, 255) if lit > 0.2 else ((90, 140, 138, 255) if lit < -0.25 else (120, 168, 165, 255))
		if (x + y * 2) % 9 == 0:
			base = shade(base, 20)
		return shade(base, int(rng.integers(-10, 11)))

	ellipse_fill(a, 36, 26, 22, 11, soak_c)
	outline_ellipse(a, 36, 26, 22, 11, STONE_DK)
	outline_ellipse(a, 36, 26, 30, 16)

	# Moss accents on north rim
	for x, y in ((22, 14), (30, 12), (40, 13), (48, 15)):
		put(a, x, y, shade((70, 120, 60, 255), int(rng.integers(-10, 11))))
		put(a, x + 1, y, shade((90, 140, 70, 255), int(rng.integers(-8, 9))))

	# Steam wisps (readable steam without FX system)
	for i, (sx, sy) in enumerate(((28, 8), (36, 5), (44, 7), (32, 3))):
		for t in range(8):
			ox = int(2 * np.sin((t + i) * 0.7))
			put(a, sx + ox, sy - t, (230, 230, 238, max(40, 160 - t * 18)))
			put(a, sx + ox + 1, sy - t, (220, 220, 230, max(30, 120 - t * 15)))

	# Stepping stone south (approach)
	ellipse_fill(a, 36, 40, 5, 3, rim_c)
	outline_ellipse(a, 36, 40, 5, 3)

	micro_noise(a, 42)
	return Image.fromarray(crop_opaque(a), "RGBA")


# ── C43 bathhouse bath pool ──────────────────────────────────────────
def make_bath_pool() -> Image.Image:
	"""Raised rectangular tiled floor bath with water + south entry steps (≠ soak / tank)."""
	rng = np.random.default_rng(431)
	a = blank(80, 56)

	# Outer stone plinth (reads as floor furniture, not wall monitor)
	def plinth(x, y):
		lit = (x - 40) / 36 - (y - 28) / 24
		base = STONE_HI if lit > 0.35 else (STONE_DK if lit < -0.25 else STONE)
		return shade(base, int(rng.integers(-10, 11)))

	fill_rect(a, 8, 14, 70, 44, plinth)
	# Right foreshortened face
	fill_rect(a, 71, 16, 74, 44, lambda x, y: shade(STONE_DK, int(rng.integers(-6, 7))))
	outline_rect(a, 8, 14, 70, 44)
	outline_rect(a, 71, 16, 74, 44)

	# Tile checker rim on top face
	def rim(x, y):
		cell = ((x // 4) + (y // 3)) % 2
		lit = (x - 36) / 30 - (y - 18) / 8
		base = TILE if cell == 0 else TILE_DK
		if lit > 0.3:
			base = shade(base, 14)
		return shade(base, int(rng.integers(-6, 7)))

	fill_rect(a, 10, 16, 68, 22, rim)  # north rim
	fill_rect(a, 10, 36, 68, 42, rim)  # south rim
	fill_rect(a, 10, 16, 16, 42, rim)
	fill_rect(a, 62, 16, 68, 42, rim)

	# Inner water (inset, oval-ish via clipped rect with darker bottom)
	def water(x, y):
		depth = (y - 24) / 12
		lit = (x - 30) / 28
		if lit > 0.45:
			c = WATER_HI
		elif depth > 0.7:
			c = WATER_DK
		else:
			c = WATER_LT if lit > 0 else WATER
		# soft ripple
		if (x + y * 2) % 8 == 0:
			c = shade(c, 18)
		return shade(c, int(rng.integers(-8, 9)))

	fill_rect(a, 18, 23, 60, 35, water)
	for x in range(19, 60):
		put(a, x, 23, WATER_HI)
	outline_rect(a, 18, 23, 60, 35, IRON_DK)

	# South masonry steps (entry into pool — key silhouette cue)
	for i, (y0, inset) in enumerate(((42, 0), (46, 2), (50, 4))):
		x0, x1 = 30 - inset, 48 + inset
		fill_rect(
			a,
			x0,
			y0,
			x1,
			y0 + 3,
			lambda x, y, ii=i: shade(TILE if ii % 2 == 0 else STONE_LT, int(rng.integers(-6, 7))),
		)
		outline_rect(a, x0, y0, x1, y0 + 3)

	# Corner posts (civic bath bollards)
	for cx, cy in ((12, 18), (64, 18), (12, 38), (64, 38)):
		fill_rect(a, cx, cy, cx + 3, cy + 3, lambda x, y: shade(IRON_LT, int(rng.integers(-4, 5))))
		outline_rect(a, cx, cy, cx + 3, cy + 3)

	# Contact shadow under plinth
	for x in range(12, 72):
		put(a, x, 53, shade(IRON_DK, -14))

	micro_noise(a, 431)
	return Image.fromarray(crop_opaque(a), "RGBA")


# ── C44 inn reception desk ───────────────────────────────────────────
def make_inn_desk() -> Image.Image:
	"""Inn front desk with unmistakable brass service bell + key rack (≠ counter / NPC bust)."""
	rng = np.random.default_rng(441)
	a = blank(72, 52)

	def wood_c(x, y):
		lit = (x - 30) / 30 - (y - 26) / 24
		base = WOOD_HI if lit > 0.35 else (WOOD_DK if lit < -0.25 else (WOOD_LT if (x + y) % 5 == 0 else WOOD))
		return shade(base, int(rng.integers(-10, 11)))

	# Desk body
	fill_rect(a, 8, 20, 56, 44, wood_c)
	fill_rect(a, 57, 22, 62, 44, lambda x, y: shade(WOOD_DK, int(rng.integers(-8, 9))))
	fill_rect(a, 10, 14, 58, 22, lambda x, y: shade(WOOD_HI if y < 17 else WOOD_LT, int(rng.integers(-8, 9))))
	outline_rect(a, 8, 20, 56, 44)
	outline_rect(a, 10, 14, 58, 22)
	outline_rect(a, 57, 22, 62, 44)

	# Front panel groove
	for y in (28, 36):
		for x in range(12, 52):
			put(a, x, y, shade(WOOD_DK, int(rng.integers(-4, 5))))

	# === Brass hotel desk bell (classic: wide skirt + short dome + button) ===
	def bell_c(nx, ny, x, y):
		lit = -nx * 0.55 - ny * 0.4
		base = BRASS_HI if lit > 0.25 else (BRASS_DK if lit < -0.3 else BRASS)
		return shade(base, int(rng.integers(-6, 7)))

	# Flat circular base plate (inn signature)
	ellipse_fill(a, 26, 16, 12, 4, lambda nx, ny, x, y: shade(BRASS_DK if ny > 0 else BRASS, int(rng.integers(-4, 5))))
	outline_ellipse(a, 26, 16, 12, 4)
	# Wide skirt
	ellipse_fill(a, 26, 13, 9, 4, bell_c)
	outline_ellipse(a, 26, 13, 9, 4)
	# Short dome
	ellipse_fill(a, 26, 9, 5, 4, bell_c)
	# Dome highlight ring
	for t in range(0, 180, 8):
		rad = np.deg2rad(t)
		put(a, int(26 + 4 * np.cos(rad)), int(9 - 2 * np.sin(rad)), BRASS_HI)
	outline_ellipse(a, 26, 9, 5, 4)
	# Button stem
	fill_rect(a, 25, 4, 27, 6, lambda x, y: shade(BRASS_HI, 0))
	put(a, 26, 3, BRASS_HI)
	put(a, 25, 3, BRASS)
	put(a, 27, 3, BRASS)

	# Key pigeonholes (right back) — reads inn, not shop jars
	for i in range(5):
		x0 = 38 + i * 4
		fill_rect(a, x0, 6, x0 + 3, 13, lambda x, y: shade(WOOD_DK, int(rng.integers(-4, 5))))
		outline_rect(a, x0, 6, x0 + 3, 13)
		# hanging key
		put(a, x0 + 1, 10, GOLD)
		put(a, x0 + 1, 11, GOLD)
		put(a, x0 + 2, 11, BRASS_DK)

	# Open ledger book (not nametag)
	fill_rect(a, 36, 16, 52, 20, lambda x, y: shade((220, 210, 180, 255), int(rng.integers(-6, 7))))
	# spine fold
	for y in range(16, 21):
		put(a, 44, y, shade(WOOD_DK, 10))
	outline_rect(a, 36, 16, 52, 20)
	for x in range(38, 43):
		put(a, x, 18, IRON_DK)
	for x in range(46, 51):
		put(a, x, 18, IRON_DK)

	# Contact shadow
	for x in range(10, 60):
		put(a, x, 46, shade(IRON_DK, -10))

	micro_noise(a, 441)
	return Image.fromarray(crop_opaque(a), "RGBA")


# ── C45 tavern upstairs secret curtain ───────────────────────────────
def make_secret_curtain() -> Image.Image:
	"""Heavy drape alcove curtain for secret meeting (≠ plain notice board)."""
	rng = np.random.default_rng(45)
	a = blank(48, 64)

	# Wood rod
	fill_rect(a, 4, 6, 42, 10, lambda x, y: shade(WOOD_LT if y < 8 else WOOD_DK, int(rng.integers(-8, 9))))
	outline_rect(a, 4, 6, 42, 10)
	# Finials
	for fx in (4, 40):
		ellipse_fill(a, fx + 2, 8, 3, 3, lambda nx, ny, x, y: shade(BRASS if nx < 0 else BRASS_DK, int(rng.integers(-4, 5))))

	# Curtain panels (gathered folds) — TL light: left brighter
	def cloth_c(x, y, fold_phase: float):
		wave = np.sin((x * 0.55) + fold_phase) * 0.5 + np.sin(y * 0.15) * 0.2
		# Smaller x = brighter (top-left light)
		lit = -(x - 24) / 22 - (y - 30) / 50 + wave * 0.25
		base = CLOTH_LT if lit > 0.2 else (CLOTH_DK if lit < -0.25 else CLOTH)
		if (x + int(fold_phase * 3)) % 5 == 0:
			base = shade(base, -18)
		return shade(base, int(rng.integers(-10, 11)))

	# Left panel (lit)
	for y in range(11, 56):
		wobble = int(2 * np.sin(y * 0.2))
		for x in range(6 + wobble, 22 + wobble):
			put(a, x, y, cloth_c(x, y, 0.0))
	# Right panel (slightly open + darker)
	for y in range(11, 56):
		wobble = int(2 * np.cos(y * 0.18))
		for x in range(26 + wobble, 42 + wobble):
			put(a, x, y, cloth_c(x, y, 1.7))

	# Center gap hint (warm candle glow behind)
	for y in range(18, 48):
		for x in range(22, 26):
			glow = max(0, 40 - abs(x - 24) * 12 - abs(y - 32) // 3)
			if glow > 8:
				put(a, x, y, (180 + glow, 120 + glow // 2, 60, min(200, 80 + glow)))

	# Outline soft edges
	for y in range(11, 56):
		put(a, 6 + int(2 * np.sin(y * 0.2)), y, OUTLINE)
		put(a, 41 + int(2 * np.cos(y * 0.18)), y, OUTLINE)

	# Tie-back cords
	for y in range(28, 36):
		put(a, 14, y, GOLD)
		put(a, 34, y, GOLD)

	# Floor puddle / hem shadow
	for x in range(8, 40):
		put(a, x, 57, shade(CLOTH_DK, -10))
		put(a, x, 58, shade(IRON_DK, -15))

	micro_noise(a, 45)
	return Image.fromarray(crop_opaque(a), "RGBA")


def main() -> None:
	pairs = [
		("exhibit_case_00.png", make_exhibit_case),
		("fish_tank_00.png", make_fish_tank),
		("soak_pool_00.png", make_soak_pool),
		("bath_pool_00.png", make_bath_pool),
		("inn_desk_00.png", make_inn_desk),
		("secret_curtain_00.png", make_secret_curtain),
	]
	for name, fn in pairs:
		save(name, fn())


if __name__ == "__main__":
	main()
