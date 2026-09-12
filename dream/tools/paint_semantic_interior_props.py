#!/usr/bin/env python3
"""Paint semantic interior signature props that were proxy-reused (altar/bench/board/desk/pipe)."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
IPROPS = ROOT / "assets" / "sprites" / "interior" / "props"
OPROPS = ROOT / "assets" / "sprites" / "props"
TMPL = (IPROPS / "counter_00.png.import").read_text(encoding="utf-8")


def sample_palette(path: Path, n: int = 48) -> list[tuple[int, int, int]]:
	im = Image.open(path).convert("RGBA")
	counts: dict[tuple[int, int, int], int] = {}
	for r, g, b, a in im.getdata():
		if a < 200:
			continue
		counts[(r, g, b)] = counts.get((r, g, b), 0) + 1
	ordered = [c for c, _ in sorted(counts.items(), key=lambda kv: -kv[1])]
	step = max(1, len(ordered) // n)
	picked = ordered[::step][:n]
	while len(picked) < 8:
		picked.append(ordered[len(picked) % max(1, len(ordered))])
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


def uniq_count(im: Image.Image) -> int:
	return len({c[:3] for c in im.getdata() if c[3] > 200})


def write_import(folder: Path, name: str) -> None:
	old = "counter_00.png"
	text = TMPL.replace(old, name)
	uid = "uid://s" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(folder / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def paint_altar(wood: list, cloth: list, stone: list, gold: list) -> Image.Image:
	w, h = 120, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Stone plinth
	for y in range(h - 14, h - 4):
		for x in range(10, w - 10):
			put(px, x, y, jitter(stone[(x + y) % len(stone)], x, y, 8))
	# Wood body
	for y in range(18, h - 14):
		for x in range(14, w - 14):
			put(px, x, y, jitter(wood[(x * 2 + y) % len(wood)], x, y, 9))
	# Cloth drape
	for y in range(12, 28):
		for x in range(18, w - 18):
			c = cloth[(x + y * 3) % len(cloth)]
			put(px, x, y, jitter(c, x, y, 7))
	# Candles + gold trim
	for cx in (36, 60, 84):
		for y in range(6, 14):
			put(px, cx, y, jitter(gold[y % len(gold)], cx, y, 5))
			put(px, cx + 1, y, jitter(gold[(y + 1) % len(gold)], cx, y, 5))
		put(px, cx, 5, (255, 220, 120), 240)
		put(px, cx + 1, 4, (255, 200, 80), 200)
	for x in range(16, w - 16):
		put(px, x, 17, jitter(gold[x % len(gold)], x, 17, 4), 220)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_waiting_bench(wood: list, seat: list) -> Image.Image:
	w, h = 104, 44
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Legs
	for lx in (10, 48, 86):
		for y in range(26, h - 2):
			for dx in range(4):
				put(px, lx + dx, y, jitter(wood[(lx + y) % len(wood)], lx, y, 7))
	# Seat plank
	for y in range(20, 28):
		for x in range(6, w - 6):
			put(px, x, y, jitter(seat[(x + y) % len(seat)], x, y, 8))
	# Backrest
	for y in range(6, 20):
		for x in range(8, w - 8):
			if y < 10 and (x // 6) % 2 == 0:
				continue
			put(px, x, y, jitter(wood[(x * 3 + y) % len(wood)], x, y, 8))
	# Rail highlight
	for x in range(8, w - 8):
		put(px, x, 8, jitter(seat[x % len(seat)], x, 8, 5), 210)
	return im.filter(ImageFilter.SMOOTH)


def paint_blackboard(frame: list, chalk: list) -> Image.Image:
	w, h = 88, 60
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Frame
	for y in range(4, h - 4):
		for x in range(4, w - 4):
			edge = x < 8 or x >= w - 8 or y < 8 or y >= h - 8
			if edge:
				put(px, x, y, jitter(frame[(x + y) % len(frame)], x, y, 7))
			else:
				base = (28 + (x + y) % 10, 36 + (x * 2) % 12, 34 + y % 8)
				put(px, x, y, jitter(base, x, y, 6))
	# Chalk lines / dust
	for i, (x0, y0, x1) in enumerate(((14, 18, 70), (16, 28, 62), (18, 38, 66))):
		for x in range(x0, x1):
			c = chalk[i % len(chalk)]
			put(px, x, y0, jitter(c, x, y0, 4), 180)
	# Chalk ledge
	for x in range(10, w - 10):
		put(px, x, h - 10, jitter(frame[x % len(frame)], x, h - 10, 5))
		put(px, x, h - 9, (220, 220, 210), 200)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_school_desk(wood: list, top: list) -> Image.Image:
	w, h = 72, 48
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Legs
	for lx in (10, 56):
		for y in range(22, h - 2):
			for dx in range(5):
				put(px, lx + dx, y, jitter(wood[(lx + y + dx) % len(wood)], lx, y, 9))
	# Desktop with grain noise
	for y in range(12, 24):
		for x in range(6, w - 6):
			c = top[(x + y * 2) % len(top)]
			if (x + y) % 5 == 0:
				c = wood[(x * 3) % len(wood)]
			put(px, x, y, jitter(c, x, y, 10))
	# Front apron + side panels
	for y in range(24, 32):
		for x in range(10, w - 10):
			put(px, x, y, jitter(wood[(x + y * 2) % len(wood)], x, y, 9))
	for y in range(14, 30):
		for x in (8, 9, 62, 63):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 8))
	# Inkwell + book stack
	for y in range(14, 18):
		for x in range(18, 22):
			put(px, x, y, jitter((40, 40, 50), x, y, 4), 240)
	for y in range(13, 17):
		for x in range(48, 58):
			put(px, x, y, jitter((120, 90, 60), x, y, 6))
	put(px, 50, 12, (200, 180, 120), 220)
	put(px, 54, 12, (90, 110, 140), 220)
	return im.filter(ImageFilter.SMOOTH)


def paint_reed_dense(greens: list, browns: list) -> Image.Image:
	w, h = 64, 72
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	bases = list(range(8, 56, 3))
	for i, bx in enumerate(bases):
		hgt = 30 + (i * 7) % 22
		for t in range(hgt):
			y = h - 6 - t
			bend = (t // 7) * (1 if i % 2 == 0 else -1)
			x = bx + bend
			col = greens[(i * 5 + t // 2) % len(greens)]
			for dx in (0, 1):
				xx = x + dx
				if 0 <= xx < w and 0 <= y < h:
					put(px, xx, y, jitter(col, xx, y, 10))
			if t > hgt - 6:
				tip = greens[(i + 3) % len(greens)]
				for dx in (-1, 0, 1):
					xx = x + dx
					if 0 <= xx < w and y - 1 >= 0:
						put(px, xx, y - 1, jitter(tip, xx, y, 8), 230)
	for x in range(6, 58):
		put(px, x, h - 4, jitter(browns[x % len(browns)], x, h - 4, 8), 220)
		put(px, x, h - 3, jitter(browns[(x + 2) % len(browns)], x, h - 3, 8), 190)
		if x % 3 == 0:
			put(px, x, h - 5, jitter(greens[x % len(greens)], x, h - 5, 6), 180)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_sewer_pipe(metal: list, rust: list) -> Image.Image:
	w, h = 96, 36
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	cy = h // 2
	for x in range(4, w - 4):
		for dy in range(-10, 11):
			y = cy + dy
			# Cylinder shading
			t = abs(dy) / 10.0
			base = metal[int(t * (len(metal) - 1))]
			if abs(dy) > 8:
				base = rust[x % len(rust)]
			put(px, x, y, jitter(base, x, y, 6))
	# Flange rings
	for fx in (8, 48, 86):
		for dy in range(-11, 12):
			put(px, fx, cy + dy, jitter(rust[(fx + dy) % len(rust)], fx, cy + dy, 5))
			put(px, fx + 1, cy + dy, jitter(metal[0], fx, cy + dy, 4), 220)
	# Bolt heads
	for bx, by in ((9, cy - 6), (9, cy + 6), (87, cy - 6), (87, cy + 6)):
		put(px, bx, by, (70, 70, 60), 255)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_lectern(wood: list, top: list, ink: list) -> Image.Image:
	"""Raised teacher lectern — taller apron + slanted book shelf, distinct from school_desk."""
	w, h = 64, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Pedestal / legs
	for lx in (14, 44):
		for y in range(28, h - 2):
			for dx in range(6):
				put(px, lx + dx, y, jitter(wood[(lx + y + dx) % len(wood)], lx, y, 9))
	# Cross brace
	for y in range(40, 44):
		for x in range(16, 48):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 8))
	# Raised desk top (slanted read: thicker front)
	for y in range(10, 22):
		for x in range(8, w - 8):
			c = top[(x + y * 3) % len(top)]
			if (x + y * 2) % 6 == 0:
				c = wood[(x * 2) % len(wood)]
			put(px, x, y, jitter(c, x, y, 10))
	# Front apron taller than desk
	for y in range(22, 34):
		for x in range(10, w - 10):
			put(px, x, y, jitter(wood[(x + y * 2) % len(wood)], x, y, 9))
	# Side panels
	for y in range(12, 34):
		for x in (8, 9, 54, 55):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 8))
	# Open book on top
	for y in range(8, 14):
		for x in range(22, 42):
			put(px, x, y, jitter((220, 210, 190), x, y, 6), 245)
	for y in range(9, 13):
		put(px, 31, y, jitter((90, 70, 50), 31, y, 3), 230)
	# Ink pot
	for y in range(12, 17):
		for x in range(14, 18):
			put(px, x, y, jitter(ink[y % len(ink)], x, y, 4), 250)
	# Quill tip
	put(px, 18, 11, (40, 40, 45), 255)
	put(px, 19, 10, (200, 190, 160), 255)
	return im.filter(ImageFilter.SMOOTH_MORE)


def main() -> None:
	counter = sample_palette(IPROPS / "counter_00.png", 64)
	pew = sample_palette(IPROPS / "pew_00.png", 48)
	notice = sample_palette(IPROPS / "notice_00.png", 48)
	barrel = sample_palette(OPROPS / "barrel_1.png", 48)
	wood = [c for c in counter + pew if c[0] > c[2]][:48] or counter[:32]
	stone = [c for c in counter if abs(c[0] - c[1]) < 25][:32] or counter[:24]
	cloth = [(max(40, c[0] - 40), max(40, c[1] - 20), min(255, c[2] + 40)) for c in notice[:16]]
	gold = [(180, 150, 70), (200, 170, 90), (160, 130, 55), (220, 190, 110)]
	seat = pew[:32] or wood
	frame = wood[:24]
	chalk = [(210, 210, 200), (190, 195, 185), (230, 230, 220), (170, 175, 165)]
	top = [c for c in wood if min(c) > 60][:24] or wood
	metal = sorted(barrel[:32] or counter[:32], key=lambda c: c[0] + c[1] + c[2])
	rust = [(min(255, c[0] + 30), max(20, c[1] - 10), max(10, c[2] - 20)) for c in metal[:16]]

	# Reed: denser interior clump (outdoor copy was too sparse for indoor read).
	reed = sample_palette(OPROPS / "reed_clump_00.png", 32)
	greens = [c for c in reed + counter if c[1] >= c[0] - 15 and c[1] > 40][:40] or reed
	browns = [c for c in wood if c[0] > c[2]][:24] or wood
	reed_im = ImageEnhance.Contrast(paint_reed_dense(greens, browns)).enhance(1.08)
	reed_im.save(IPROPS / "reed_clump_00.png")
	write_import(IPROPS, "reed_clump_00.png")
	print(f"wrote reed_clump_00.png uniq={uniq_count(reed_im)} size={reed_im.size}")

	jobs = [
		("altar_00.png", paint_altar(wood, cloth, stone, gold)),
		("waiting_bench_00.png", paint_waiting_bench(wood, seat)),
		("blackboard_00.png", paint_blackboard(frame, chalk)),
		("school_desk_00.png", paint_school_desk(wood, top)),
		("sewer_pipe_00.png", paint_sewer_pipe(metal, rust)),
		("lectern_00.png", paint_lectern(wood, top, [(35, 35, 45), (50, 45, 40), (25, 25, 30)])),
	]
	for name, im in jobs:
		im = ImageEnhance.Contrast(im).enhance(1.1)
		im.save(IPROPS / name)
		write_import(IPROPS, name)
		print(f"wrote {name} uniq={uniq_count(im)} size={im.size}")


if __name__ == "__main__":
	main()
