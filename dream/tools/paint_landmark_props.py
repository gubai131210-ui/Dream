#!/usr/bin/env python3
"""Repaint landmark/utility props to painted-grade color density (sample from rock/bench/stall)."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageEnhance

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
MARKET = ROOT / "assets" / "sprites" / "market"
TMPL = (PROPS / "crate_0.png.import").read_text(encoding="utf-8")


def sample_palette(path: Path, n: int = 48) -> list[tuple[int, int, int]]:
	im = Image.open(path).convert("RGBA")
	counts: dict[tuple[int, int, int], int] = {}
	for r, g, b, a in im.getdata():
		if a < 200:
			continue
		counts[(r, g, b)] = counts.get((r, g, b), 0) + 1
	ordered = [c for c, _ in sorted(counts.items(), key=lambda kv: -kv[1])]
	# Keep mid-spread samples, not only the top flat color.
	step = max(1, len(ordered) // n)
	picked = ordered[::step][:n]
	while len(picked) < 8:
		picked.append(ordered[len(picked) % len(ordered)])
	return picked


def jitter(rgb: tuple[int, int, int], x: int, y: int, amp: int = 10) -> tuple[int, int, int]:
	h = (x * 374761393 + y * 668265263) & 0xFFFFFFFF
	dr = ((h & 255) % (amp * 2 + 1)) - amp
	dg = (((h >> 8) & 255) % (amp * 2 + 1)) - amp
	db = (((h >> 16) & 255) % (amp * 2 + 1)) - amp
	return (
		max(0, min(255, rgb[0] + dr)),
		max(0, min(255, rgb[1] + dg)),
		max(0, min(255, rgb[2] + db)),
	)


def put(px, x: int, y: int, rgb: tuple[int, int, int], a: int = 255) -> None:
	px[x, y] = (*rgb, a)


def paint_reed(greens: list[tuple[int, int, int]], browns: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 64, 72
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	bases = [12, 18, 24, 30, 36, 42, 48, 52]
	for i, bx in enumerate(bases):
		hgt = 34 + (i * 5) % 16
		for t in range(hgt):
			y = h - 6 - t
			bend = (t // 8) * (1 if i % 2 == 0 else -1)
			x = bx + bend
			col = greens[(i * 3 + t // 3) % len(greens)]
			for dx in (0, 1):
				xx = x + dx
				if 0 <= xx < w and 0 <= y < h:
					put(px, xx, y, jitter(col, xx, y, 8))
			if t > hgt - 5:
				tip = greens[(i + 2) % len(greens)]
				for dx in (-1, 0, 1):
					xx = x + dx
					if 0 <= xx < w and y - 1 >= 0:
						put(px, xx, y - 1, jitter(tip, xx, y, 6), 230)
	for x in range(10, 54):
		put(px, x, h - 4, jitter(browns[x % len(browns)], x, h - 4, 6), 210)
		put(px, x, h - 3, jitter(browns[(x + 2) % len(browns)], x, h - 3, 6), 180)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_ruin(stones: list[tuple[int, int, int]], moss: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 80, 64
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for x in list(range(10, 22)) + list(range(58, 70)):
		for y in range(16, h - 6):
			put(px, x, y, jitter(stones[(x + y) % len(stones)], x, y, 9))
	for x in range(10, 70):
		for y in range(12, 22):
			if 30 <= x <= 50 and y > 16:
				continue
			put(px, x, y, jitter(stones[(x * 2 + y) % len(stones)], x, y, 8))
	# Capstones / chips
	for x, y in ((14, 18), (18, 28), (62, 20), (66, 32), (40, 14), (24, 40), (56, 44)):
		put(px, x, y, jitter(moss[0], x, y, 5))
		put(px, x + 1, y, jitter(moss[min(1, len(moss) - 1)], x, y, 5), 200)
	for x in range(8, 72):
		if (x + 2) % 4 == 0:
			continue
		put(px, x, h - 5, jitter(stones[1], x, h - 5, 7), 220)
		put(px, x, h - 4, jitter(stones[0], x, h - 4, 7), 200)
	return im.filter(ImageFilter.SMOOTH)


def paint_grave(stones: list[tuple[int, int, int]], wood: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 40, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for x in range(10, 30):
		for y in range(8, 40):
			if y < 14 and (x < 12 or x > 27):
				continue
			put(px, x, y, jitter(stones[(x + y * 3) % len(stones)], x, y, 7))
	# Carved cross depression
	for x in range(17, 23):
		for y in range(16, 32):
			put(px, x, y, jitter(stones[0], x, y, 4))
	for x in range(14, 26):
		for y in range(19, 23):
			put(px, x, y, jitter(stones[0], x, y, 4))
	for x in range(6, 34):
		put(px, x, 40, jitter(stones[2 % len(stones)], x, 40, 6))
		put(px, x, 41, jitter(wood[x % len(wood)], x, 41, 5), 200)
		put(px, x, 42, jitter(wood[(x + 1) % len(wood)], x, 42, 5), 170)
	return im.filter(ImageFilter.SMOOTH)


def paint_boat(wood: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 72, 36
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for x in range(8, 64):
		depth = 8 + int(4 * (1 - abs((x - 36) / 28)))
		for y in range(h - 5 - depth, h - 5):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 8))
		gun = wood[min(3, len(wood) - 1)]
		put(px, x, h - 6 - depth, jitter(gun, x, h - 6 - depth, 5))
	for x in range(22, 50):
		put(px, x, h - 16, jitter(wood[1], x, h - 16, 5))
		put(px, x, h - 15, jitter(wood[0], x, h - 15, 5))
	for y in range(h - 18, h - 8):
		put(px, 6, y, jitter(wood[2 % len(wood)], 6, y, 5), 230)
		put(px, 7, y, jitter(wood[0], 7, y, 5))
	# Interior shadow wash
	for x in range(16, 56):
		for y in range(h - 14, h - 8):
			r, g, b = wood[(x + y) % len(wood)]
			put(px, x, y, (max(0, r - 25), max(0, g - 20), max(0, b - 15)), 140)
	return im.filter(ImageFilter.SMOOTH)


def paint_awning(reds: list[tuple[int, int, int]], creams: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 72, 24
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	stripe_w = 12
	for x in range(w):
		band = (x // stripe_w) % 2 == 0
		base = reds[x % len(reds)] if band else creams[x % len(creams)]
		for y in range(2, h - 2):
			# scallop bottom
			if y > h - 6 and ((x + y) % 6) < 2:
				continue
			put(px, x, y, jitter(base, x, y, 7), 235)
		put(px, x, 1, jitter(base, x, 1, 4), 200)
	return im.filter(ImageFilter.SMOOTH)


def paint_facade(wood: list[tuple[int, int, int]], stone: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 56, 72
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Door frame
	for x in range(8, 48):
		for y in range(6, 66):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 8))
	# Inner door panel
	for x in range(14, 42):
		for y in range(14, 58):
			put(px, x, y, jitter(wood[(x * 2 + y) % len(wood)], x, y, 6))
	# Stone sill
	for x in range(6, 50):
		for y in range(60, 66):
			put(px, x, y, jitter(stone[(x + y) % len(stone)], x, y, 7))
	# Handle
	for y in range(34, 40):
		put(px, 38, y, jitter((180, 150, 70), 38, y, 4))
	return im.filter(ImageFilter.SMOOTH)


def paint_civic_facade(
	walls: list[tuple[int, int, int]],
	trim: list[tuple[int, int, int]],
	accent: tuple[int, int, int],
) -> Image.Image:
	w, h = 64, 80
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for x in range(4, 60):
		for y in range(8, 70):
			put(px, x, y, jitter(walls[(x + y) % len(walls)], x, y, 7))
	# Pediment
	for x in range(8, 56):
		for y in range(4, 14):
			if abs(x - 32) + (y - 4) < 28:
				put(px, x, y, jitter(trim[(x + y) % len(trim)], x, y, 6))
	# Door recess
	for x in range(22, 42):
		for y in range(28, 66):
			put(px, x, y, jitter(trim[(x * 3 + y) % len(trim)], x, y, 5))
	# Accent tile band
	for x in range(6, 58):
		put(px, x, 24, jitter(accent, x, 24, 4))
		put(px, x, 25, jitter(accent, x, 25, 4), 220)
	# Columns
	for x in (10, 52):
		for y in range(14, 68):
			put(px, x, y, jitter(trim[y % len(trim)], x, y, 5))
			put(px, x + 1, y, jitter(trim[(y + 1) % len(trim)], x, y, 5))
	return im.filter(ImageFilter.SMOOTH)


def paint_stake(wood: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 20, 44
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for y in range(4, 40):
		for x in range(7, 13):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 6))
		# Pointed tip
		if y < 10:
			span = 10 - y
			for x in range(10 - span // 2, 10 + span // 2 + 1):
				if 0 <= x < w:
					put(px, x, y, jitter(wood[0], x, y, 4))
	for x in range(4, 16):
		put(px, x, 40, jitter(wood[1], x, 40, 4), 200)
	return im.filter(ImageFilter.SMOOTH)


def paint_weed(greens: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 36, 28
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for i, bx in enumerate((8, 14, 18, 22, 26)):
		for t in range(10 + i % 5):
			y = h - 4 - t
			x = bx + ((t // 3) * (1 if i % 2 else -1))
			if 0 <= x < w and 0 <= y < h:
				put(px, x, y, jitter(greens[(i + t) % len(greens)], x, y, 7))
				if x + 1 < w:
					put(px, x + 1, y, jitter(greens[(i + 2) % len(greens)], x, y, 5), 210)
	for x in range(6, 30):
		put(px, x, h - 3, jitter(greens[0], x, h - 3, 5), 180)
	return im.filter(ImageFilter.SMOOTH)


def paint_fence(wood: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 20, 36
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for y in range(4, 32):
		for x in range(7, 13):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 6))
	for y in (10, 18, 26):
		for x in range(3, 17):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 5))
			put(px, x, y + 1, jitter(wood[(x + y + 1) % len(wood)], x, y, 5), 220)
	return im.filter(ImageFilter.SMOOTH)


def paint_bridge(wood: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 64, 20
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for y in range(4, 16):
		for x in range(2, 62):
			# plank seams every 8px
			base = wood[(x // 8 + y) % len(wood)]
			if x % 8 == 0:
				base = wood[0]
			put(px, x, y, jitter(base, x, y, 6))
	for x in range(2, 62):
		put(px, x, 3, jitter(wood[1], x, 3, 4), 210)
		put(px, x, 16, jitter(wood[0], x, 16, 4), 210)
	return im.filter(ImageFilter.SMOOTH)


def paint_furrow(soil: list[tuple[int, int, int]]) -> Image.Image:
	w, h = 64, 8
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for x in range(w):
		for y in range(2, 6):
			put(px, x, y, jitter(soil[(x + y) % len(soil)], x, y, 8), 230)
		put(px, x, 1, jitter(soil[0], x, 1, 5), 160)
		put(px, x, 6, jitter(soil[min(2, len(soil) - 1)], x, 6, 5), 160)
	return im


def write_import(folder: Path, name: str) -> None:
	tmpl = TMPL if folder == PROPS else (MARKET / "stall_open_wood_00.png.import").read_text(encoding="utf-8")
	# Replace basename in path lines
	old = "crate_0.png" if folder == PROPS else "stall_open_wood_00.png"
	text = tmpl.replace(old, name)
	uid = "uid://p" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(folder / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def uniq_count(im: Image.Image) -> int:
	return len({c[:3] for c in im.getdata() if c[3] > 200})


def main() -> None:
	rock = sample_palette(PROPS / "rock_02.png", 64)
	bench = sample_palette(PROPS / "bench_0.png", 48)
	stall = sample_palette(MARKET / "stall_open_wood_00.png", 64)
	# Split-ish: darker = stone/wood, greener from rock+bench mix
	greens = [c for c in rock + bench if c[1] >= c[0] - 10 and c[1] > 50] or rock[:16]
	browns = [c for c in stall + bench if c[0] > c[2]] or stall[:16]
	stones = rock[:48]
	moss = greens[:16]
	wood = browns[:48]
	creams = [c for c in stall if min(c) > 140][:16] or [(240, 230, 210)] * 8
	reds = [(180, 60, 50), (160, 45, 40), (200, 80, 70), (140, 40, 35)] + [
		(max(40, c[0]), max(20, c[1] // 2), max(20, c[2] // 2)) for c in stall[:8]
	]
	soil = [c for c in browns + rock if c[0] < 160][:32] or browns[:16]
	bath_walls = [(c[0], min(255, c[1] + 20), min(255, c[2] + 35)) for c in stones[:24]]
	museum_walls = [(min(255, c[0] + 15), c[1], max(0, c[2] - 10)) for c in stones[:24]]
	trim = wood[:24]
	teal = (70, 140, 150)
	gold = (180, 140, 70)

	jobs = [
		(PROPS, "reed_clump_00.png", paint_reed(greens, browns)),
		(PROPS, "ruin_arch_00.png", paint_ruin(stones, moss)),
		(PROPS, "grave_marker_00.png", paint_grave(stones, wood)),
		(PROPS, "boat_skiff_00.png", paint_boat(wood)),
		(PROPS, "door_facade_00.png", paint_facade(wood, stones)),
		(PROPS, "facade_bath_00.png", paint_civic_facade(bath_walls, trim, teal)),
		(PROPS, "facade_museum_00.png", paint_civic_facade(museum_walls, trim, gold)),
		(PROPS, "breakable_stake_00.png", paint_stake(wood)),
		(PROPS, "breakable_weed_00.png", paint_weed(greens)),
		(PROPS, "fence_post_00.png", paint_fence(wood)),
		(PROPS, "bridge_plank_00.png", paint_bridge(wood)),
		(PROPS, "furrow_line_00.png", paint_furrow(soil)),
		(MARKET, "stall_awning_00.png", paint_awning(reds, creams)),
	]
	for folder, name, im in jobs:
		# Mild contrast to keep pixel readable after smooth
		im = ImageEnhance.Contrast(im).enhance(1.08)
		im.save(folder / name)
		write_import(folder, name)
		print(f"wrote {name} uniq={uniq_count(im)} size={im.size}")


if __name__ == "__main__":
	main()
