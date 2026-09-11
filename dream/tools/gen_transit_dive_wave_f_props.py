#!/usr/bin/env python3
"""Generate Wave F TransitDive signature props (C34–C36, C23).

Outputs under assets/sprites/interior/props/:
  dock_pile_fish_00.png   — netted pile + fish crates (fish dock mass)
  dock_pile_trade_00.png  — tall rope-tied cargo crate stack (trade dock mass)
  wreck_hull_00.png       — broken boat hull cue (half-sunken silhouette)
  seaweed_00.png          — underwater weed clump (≠ herbs)
  sunken_wood_00.png      — sunken timber beam / log
  train_seat_row_00.png   — passenger bench seat row (3/4)

TL light, opaque outline, ≥200 unique colors target — painting-asset-craft.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"

OUTLINE = (36, 28, 22, 255)


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


def outline_opaque(a: np.ndarray, c=OUTLINE) -> None:
	h, w = a.shape[:2]
	mask = a[:, :, 3] > 0
	for y in range(h):
		for x in range(w):
			if not mask[y, x]:
				continue
			for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
				ny, nx = y + dy, x + dx
				if ny < 0 or nx < 0 or ny >= h or nx >= w or not mask[ny, nx]:
					put(a, x, y, c)
					break


def crop_opaque(a: np.ndarray, pad: int = 1) -> np.ndarray:
	ys, xs = np.where(a[:, :, 3] > 0)
	return a[max(0, ys.min() - pad) : ys.max() + pad + 1, max(0, xs.min() - pad) : xs.max() + pad + 1]


def save(a: np.ndarray, name: str) -> None:
	a = crop_opaque(a)
	im = Image.fromarray(a, "RGBA")
	path = OUT / name
	path.parent.mkdir(parents=True, exist_ok=True)
	im.save(path)
	opaque = a[:, :, 3] > 200
	colors = len({tuple(c) for c in a[opaque, :3]}) if opaque.any() else 0
	print(f"wrote {path.relative_to(ROOT)} size={im.size} colors={colors}")


# ── palettes ──────────────────────────────────────────────────────────────
WOOD = (128, 90, 52, 255)
WOOD_DK = (78, 50, 30, 255)
WOOD_LT = (164, 120, 74, 255)
WOOD_HI = (198, 156, 102, 255)
ROPE = (140, 112, 68, 255)
ROPE_DK = (96, 74, 44, 255)
NET = (90, 110, 118, 255)
NET_LT = (130, 150, 158, 255)
NET_DK = (58, 72, 80, 255)
FISH = (170, 150, 120, 255)
FISH_DK = (120, 100, 78, 255)
FISH_SLV = (190, 200, 210, 255)
IRON = (70, 74, 82, 255)
IRON_LT = (118, 122, 130, 255)
SEA_G = (40, 110, 78, 255)
SEA_G2 = (56, 140, 96, 255)
SEA_G3 = (78, 168, 118, 255)
SEA_DK = (28, 72, 54, 255)
SEA_TIP = (120, 190, 150, 255)
MOSS = (62, 98, 70, 255)
RUST = (120, 72, 48, 255)
RUST_DK = (86, 48, 32, 255)
FABRIC = (92, 78, 110, 255)
FABRIC_LT = (128, 112, 148, 255)
FABRIC_DK = (58, 48, 72, 255)
BRASS = (168, 132, 62, 255)
BRASS_LT = (210, 176, 96, 255)


def make_dock_pile_fish() -> None:
	"""Netted dock pile: crates + hanging net mesh + fish silhouette mass."""
	rng = np.random.default_rng(3401)
	a = blank(64, 56)

	# Base plank platform shadow
	def plank(x, y):
		c = WOOD_DK if (x + y) % 5 == 0 else WOOD
		return shade(c, int(rng.integers(-8, 9)))

	fill_rect(a, 8, 40, 54, 50, plank)

	# Lower crate
	def crate_face(x, y):
		lit = (x - 20) / 24 - (y - 30) / 12
		c = WOOD_HI if lit > 0.3 else (WOOD_DK if lit < -0.2 else WOOD_LT)
		return shade(c, int(rng.integers(-10, 11)))

	fill_rect(a, 12, 28, 34, 42, crate_face)
	fill_rect(a, 14, 22, 36, 30, lambda x, y: shade(WOOD_LT if (x + y) % 3 else WOOD_HI, int(rng.integers(-8, 9))))
	# plank seams
	for x in (18, 26):
		for y in range(29, 42):
			put(a, x, y, shade(WOOD_DK, -4))
	for y in (32, 38):
		for x in range(13, 34):
			put(a, x, y, shade(WOOD_DK, -6))

	# Upper crate offset (3/4 stack)
	fill_rect(a, 22, 14, 46, 28, crate_face)
	fill_rect(a, 24, 10, 48, 16, lambda x, y: shade(WOOD_HI if x < 36 else WOOD_LT, int(rng.integers(-8, 9))))
	for x in (28, 36):
		for y in range(15, 28):
			put(a, x, y, shade(WOOD_DK, -4))

	# Fish bodies peeking from upper crate
	for cx, cy in ((28, 12), (34, 11), (40, 13)):
		for dx in range(-4, 5):
			for dy in range(-2, 3):
				if abs(dx) / 4.0 + abs(dy) / 2.5 <= 1.0:
					c = FISH_SLV if dx < -1 else (FISH if dy < 1 else FISH_DK)
					put(a, cx + dx, cy + dy, shade(c, int(rng.integers(-12, 13))))

	# Net mesh draped over pile (readable fishing silhouette)
	for i in range(18):
		x0 = 10 + i * 2
		for t in range(28):
			x = x0 + (t % 3) - 1
			y = 8 + t
			if rng.random() < 0.85:
				c = NET_LT if (i + t) % 3 == 0 else (NET_DK if t > 18 else NET)
				put(a, x, y, shade(c, int(rng.integers(-10, 11))))
	# cross weave
	for j in range(10):
		y0 = 10 + j * 3
		for t in range(22):
			x = 12 + t
			y = y0 + (t // 4)
			put(a, x, y, shade(NET if j % 2 else NET_DK, int(rng.integers(-8, 9))))

	# Rope ties
	for x in range(20, 42):
		put(a, x, 27, shade(ROPE, int(rng.integers(-6, 7))))
		put(a, x, 28, shade(ROPE_DK, int(rng.integers(-4, 5))))

	# Buoy float on side
	for dy in range(-5, 6):
		for dx in range(-3, 4):
			if dx * dx / 9 + dy * dy / 25 <= 1:
				c = (200, 90, 70, 255) if dy < 0 else (170, 60, 50, 255)
				put(a, 50 + dx, 34 + dy, shade(c, int(rng.integers(-10, 11))))

	outline_opaque(a)
	save(a, "dock_pile_fish_00.png")


def make_dock_pile_trade() -> None:
	"""Tall rope-tied cargo crate tower — trade dock mass ≠ fish nets."""
	rng = np.random.default_rng(3402)
	a = blank(56, 64)

	def wood_fn(x, y, bias=0):
		lit = (x - 20) / 30 - (y - 30) / 40 + bias
		c = WOOD_HI if lit > 0.35 else (WOOD_DK if lit < -0.25 else (WOOD_LT if (x + y) % 4 == 0 else WOOD))
		return shade(c, int(rng.integers(-10, 11)))

	# Three stacked crates (tall silhouette)
	# Bottom
	fill_rect(a, 8, 40, 42, 58, lambda x, y: wood_fn(x, y))
	fill_rect(a, 10, 34, 44, 42, lambda x, y: wood_fn(x, y, 0.2))
	# Mid
	fill_rect(a, 10, 22, 40, 38, lambda x, y: wood_fn(x, y, -0.05))
	fill_rect(a, 12, 16, 42, 24, lambda x, y: wood_fn(x, y, 0.25))
	# Top
	fill_rect(a, 14, 6, 38, 20, lambda x, y: wood_fn(x, y, -0.1))
	fill_rect(a, 16, 2, 40, 10, lambda x, y: wood_fn(x, y, 0.3))

	# Seams + stamps
	for y_band, x0, x1 in ((48, 9, 41), (30, 11, 39), (12, 15, 37)):
		for x in range(x0, x1):
			put(a, x, y_band, shade(WOOD_DK, -8))
	for stamp_y, stamp_x in ((50, 18), (32, 20), (14, 22)):
		for dy in range(4):
			for dx in range(6):
				put(a, stamp_x + dx, stamp_y + dy, shade(IRON if dy % 2 else IRON_LT, int(rng.integers(-6, 7))))

	# Vertical rope bindings (trade cue)
	for rx in (16, 28):
		for y in range(4, 56):
			put(a, rx, y, shade(ROPE if y % 3 else ROPE_DK, int(rng.integers(-6, 7))))
			put(a, rx + 1, y, shade(ROPE_DK, -4))
	# Horizontal cinch
	for y in (18, 36):
		for x in range(10, 42):
			put(a, x, y, shade(ROPE, int(rng.integers(-6, 7))))
			put(a, x, y + 1, shade(ROPE_DK, -4))

	# Side sack lean (secondary mass, not fish net)
	for dy in range(-8, 9):
		for dx in range(-6, 7):
			if dx * dx / 36 + dy * dy / 64 <= 1:
				c = (176, 148, 98, 255) if dx < 0 else (128, 102, 64, 255)
				put(a, 44 + dx, 48 + dy, shade(c, int(rng.integers(-12, 13))))

	outline_opaque(a)
	save(a, "dock_pile_trade_00.png")


def make_wreck_hull() -> None:
	"""Broken boat hull cue — tilted ribs, cracked planks, rusted nail line."""
	rng = np.random.default_rng(3501)
	a = blank(72, 48)

	# Hull body (tilted ellipse-ish boat silhouette)
	for y in range(8, 42):
		for x in range(6, 66):
			# asymmetric boat: wider mid, broken right end
			nx = (x - 34) / 30.0
			ny = (y - 26) / 14.0
			# tilt
			nx2 = nx * 0.95 + (y - 26) * 0.012
			if nx2 * nx2 + ny * ny > 1.0:
				continue
			# broken bite on starboard aft
			if x > 52 and y < 22 + (x - 52):
				continue
			if x > 58 and rng.random() < 0.45:
				continue
			lit = -nx2 * 0.4 - ny * 0.5
			if lit > 0.25:
				c = WOOD_HI
			elif lit < -0.2:
				c = WOOD_DK
			else:
				c = WOOD if (x + y) % 3 else WOOD_LT
			# waterline darkening
			if y > 30:
				c = shade(c, -18)
			# moss / barnacle
			if rng.random() < 0.06:
				c = MOSS
			elif rng.random() < 0.04:
				c = RUST
			put(a, x, y, shade(c, int(rng.integers(-10, 11))))

	# Ribs (interior frames readable as wreck)
	for i, rx in enumerate((18, 28, 38, 48)):
		for y in range(14, 36):
			xx = rx + int((y - 14) * 0.15) + (1 if i % 2 else 0)
			put(a, xx, y, shade(WOOD_DK, int(rng.integers(-6, 7))))
			put(a, xx + 1, y, shade(RUST_DK if y > 28 else WOOD, int(rng.integers(-6, 7))))

	# Crack line
	for t in range(20):
		put(a, 40 + t // 2, 18 + t, shade(OUTLINE, 10))
		put(a, 41 + t // 2, 18 + t, shade(WOOD_DK, -20))

	# Nail / iron strip
	for x in range(14, 50):
		if x % 4 == 0:
			put(a, x, 31, shade(IRON, int(rng.integers(-6, 7))))
			put(a, x, 32, shade(IRON_LT, -4))

	outline_opaque(a)
	save(a, "wreck_hull_00.png")


def make_seaweed() -> None:
	"""Underwater weed clump — tall fronds, not herb basket greenery."""
	rng = np.random.default_rng(2301)
	a = blank(48, 56)

	# Rocky base
	for dy in range(-6, 7):
		for dx in range(-12, 13):
			if dx * dx / 144 + dy * dy / 36 <= 1:
				c = (70, 78, 86, 255) if dy > 0 else (98, 106, 114, 255)
				put(a, 24 + dx, 48 + dy, shade(c, int(rng.integers(-12, 13))))

	# Fronds (multiple stems waving up)
	stems = [
		(12, 46, -0.35, 38),
		(18, 47, -0.1, 42),
		(24, 48, 0.05, 44),
		(30, 47, 0.2, 40),
		(36, 46, 0.4, 36),
		(20, 47, 0.15, 34),
		(28, 48, -0.2, 36),
	]
	for sx, sy, curve, length in stems:
		for t in range(length):
			x = int(sx + curve * t + 2.2 * np.sin(t * 0.22 + sx))
			y = sy - t
			w = 2 + (1 if t < length * 0.6 else 0)
			for dx in range(-w, w + 1):
				# tip lighter / mid darker
				frac = t / max(1, length - 1)
				if frac > 0.85:
					c = SEA_TIP
				elif frac > 0.5:
					c = SEA_G3 if dx == 0 else SEA_G2
				elif frac > 0.2:
					c = SEA_G2 if abs(dx) < 2 else SEA_G
				else:
					c = SEA_DK
				put(a, x + dx, y, shade(c, int(rng.integers(-10, 11))))
			# leaflet nubs
			if t % 5 == 0 and t > 4:
				side = 1 if int(sx) % 2 == 0 else -1
				for k in range(4):
					put(a, x + side * (2 + k), y + k // 2, shade(SEA_G3, int(rng.integers(-8, 9))))

	outline_opaque(a)
	save(a, "seaweed_00.png")


def make_sunken_wood() -> None:
	"""Sunken timber — waterlogged beam with moss and broken end."""
	rng = np.random.default_rng(2302)
	a = blank(64, 36)

	# Main beam (3/4 cylinder look)
	for y in range(10, 28):
		for x in range(4, 58):
			ny = (y - 19) / 8.0
			# taper broken right tip
			max_x = 56 - max(0, (x - 48)) * 0.3
			if x > max_x:
				continue
			if abs(ny) > 1.0:
				continue
			lit = -ny * 0.6 + (x - 30) / 80
			if lit > 0.25:
				c = WOOD_LT
			elif lit < -0.3:
				c = WOOD_DK
			else:
				c = WOOD
			# waterlogged blue-green cast
			c = (
				max(0, min(255, c[0] - 18)),
				max(0, min(255, c[1] - 6)),
				max(0, min(255, c[2] + 12)),
				255,
			)
			if rng.random() < 0.08:
				c = MOSS
			elif rng.random() < 0.05:
				c = SEA_DK
			put(a, x, y, shade(c, int(rng.integers(-10, 11))))

	# End grain rings on left
	for r in (2, 4, 6):
		for t in range(0, 360, 8):
			rad = np.deg2rad(t)
			put(a, int(8 + r * np.cos(rad) * 0.5), int(19 + r * np.sin(rad)), shade(WOOD_DK, -8))

	# Broken splinters on right
	for i in range(8):
		for k in range(6):
			put(a, 54 + k, 14 + i + k // 2, shade(WOOD_DK if k % 2 else WOOD, int(rng.integers(-8, 9))))

	# Rope remnant
	for x in range(22, 34):
		put(a, x, 12, shade(ROPE_DK, int(rng.integers(-6, 7))))
		put(a, x, 13, shade(NET_DK, -4))

	outline_opaque(a)
	save(a, "sunken_wood_00.png")


def make_train_seat_row() -> None:
	"""Passenger bench seat row — two seats + shared back + brass rail."""
	rng = np.random.default_rng(3601)
	a = blank(72, 48)

	# Floor shadow
	fill_rect(
		a,
		8,
		38,
		64,
		44,
		lambda x, y: shade(WOOD_DK, int(rng.integers(-6, 7))),
	)

	# Seat cushion bank (two seats)
	def cushion(x, y):
		lit = (x - 36) / 40 - (y - 28) / 10
		c = FABRIC_LT if lit > 0.2 else (FABRIC_DK if lit < -0.25 else FABRIC)
		# seam between seats
		if 34 <= x <= 36:
			c = FABRIC_DK
		return shade(c, int(rng.integers(-10, 11)))

	fill_rect(a, 10, 24, 60, 36, cushion)
	# seat top face (3/4)
	fill_rect(
		a,
		12,
		20,
		62,
		26,
		lambda x, y: shade(FABRIC_LT if y < 22 else FABRIC, int(rng.integers(-8, 9))),
	)

	# Backrest
	def back(x, y):
		lit = (x - 36) / 50 - (y - 12) / 16
		c = FABRIC_LT if lit > 0.3 else (FABRIC_DK if lit < -0.2 else FABRIC)
		if 34 <= x <= 36:
			c = FABRIC_DK
		return shade(c, int(rng.integers(-10, 11)))

	fill_rect(a, 10, 6, 60, 22, back)
	# top rail
	for x in range(10, 61):
		put(a, x, 5, shade(WOOD_HI, int(rng.integers(-6, 7))))
		put(a, x, 4, shade(WOOD, int(rng.integers(-4, 5))))
		put(a, x, 3, OUTLINE)

	# Wooden armrests / legs
	for ax in (10, 34, 58):
		fill_rect(
			a,
			ax,
			28,
			ax + 4,
			42,
			lambda x, y, b=ax: shade(WOOD_DK if y > 36 else WOOD, int(rng.integers(-8, 9))),
		)
		fill_rect(
			a,
			ax - 1,
			20,
			ax + 5,
			28,
			lambda x, y: shade(WOOD_LT, int(rng.integers(-6, 7))),
		)

	# Brass luggage rail above
	for x in range(14, 58):
		put(a, x, 2, shade(BRASS_LT if x % 5 else BRASS, int(rng.integers(-6, 7))))
	for peg in (18, 28, 38, 48):
		for y in range(2, 6):
			put(a, peg, y, shade(BRASS, int(rng.integers(-4, 5))))

	# Button tufts
	for bx, by in ((20, 14), (28, 14), (42, 14), (50, 14), (20, 30), (28, 30), (42, 30), (50, 30)):
		put(a, bx, by, shade(FABRIC_DK, -10))
		put(a, bx + 1, by, shade(FABRIC_LT, 8))

	outline_opaque(a)
	save(a, "train_seat_row_00.png")


def main() -> None:
	make_dock_pile_fish()
	make_dock_pile_trade()
	make_wreck_hull()
	make_seaweed()
	make_sunken_wood()
	make_train_seat_row()


if __name__ == "__main__":
	main()
