#!/usr/bin/env python3
"""Paint remaining specialized notice boards (clear generic notice_00 proxies)."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
IPROPS = ROOT / "assets" / "sprites" / "interior" / "props"
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
	text = TMPL.replace("counter_00.png", name)
	uid = "uid://n" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(folder / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def wood_frame(px, w: int, h: int, wood: list, paper: list) -> None:
	for y in range(2, h - 2):
		for x in range(2, w - 2):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 8))
	for y in range(8, h - 8):
		for x in range(8, w - 8):
			put(px, x, y, jitter(paper[(x + y * 2) % len(paper)], x, y, 6))


def paint_cargo_manifest(wood, paper, ink) -> Image.Image:
	w, h = 48, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	# Clip at top
	for x in range(18, 30):
		put(px, x, 6, jitter((70, 70, 75), x, 6, 3), 255)
	for i, y in enumerate(range(14, h - 10, 6)):
		for x in range(12, w - 12):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 230)
		# Checkbox
		put(px, w - 14, y - 1, jitter((90, 90, 80), w - 14, y, 2), 255)
	return im.filter(ImageFilter.SMOOTH)


def paint_shop_price(wood, paper, ink, accent) -> Image.Image:
	w, h = 56, 52
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	for y in range(8, 14):
		for x in range(8, w - 8):
			put(px, x, y, jitter(accent[(x) % len(accent)], x, y, 5), 235)
	for i, y in enumerate(range(18, h - 10, 7)):
		for x in range(12, 28):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 230)
		for x in range(34, w - 12):
			put(px, x, y, jitter((170, 140, 55), x, y, 3), 250)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_house_rules(wood, paper, ink) -> Image.Image:
	w, h = 48, 52
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	# Numbered rules
	for i, y in enumerate(range(14, h - 10, 8)):
		put(px, 12, y, jitter(ink[0], 12, y, 2), 255)
		put(px, 13, y, jitter((180, 150, 70), 13, y, 2), 255)
		for x in range(16, w - 12):
			put(px, x, y, jitter(ink[(i + 1) % len(ink)], x, y, 2), 225)
	return im.filter(ImageFilter.SMOOTH)


def paint_mine_safety(wood, paper, ink, warn) -> Image.Image:
	w, h = 52, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	# Warning triangle header
	for dy in range(0, 10):
		half = dy // 2 + 1
		cx = w // 2
		for x in range(cx - half, cx + half + 1):
			put(px, x, 10 + dy, jitter(warn[dy % len(warn)], x, 10 + dy, 4), 250)
	for i, y in enumerate(range(24, h - 10, 7)):
		for x in range(12, w - 12):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 230)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_catalog_card(wood, paper, ink) -> Image.Image:
	"""Small library index card — distinct from tall notice board."""
	w, h = 44, 36
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	for y in range(2, h - 2):
		for x in range(2, w - 2):
			put(px, x, y, jitter(paper[(x + y) % len(paper)], x, y, 5))
	# Edge
	for x in range(2, w - 2):
		put(px, x, 2, jitter(wood[0], x, 2, 3), 240)
		put(px, x, h - 3, jitter(wood[0], x, h - 3, 3), 240)
	# Tabs
	for tx in (8, 20, 32):
		for y in range(0, 4):
			for x in range(tx, tx + 6):
				put(px, x, y, jitter(wood[(tx) % len(wood)], x, y, 4), 255)
	for y in range(10, h - 8, 5):
		for x in range(8, w - 8):
			put(px, x, y, jitter(ink[y % len(ink)], x, y, 2), 220)
	return im.filter(ImageFilter.SMOOTH)


def paint_trail_marker(wood, bark, ink) -> Image.Image:
	"""Wooden trail/cave marker post with glyph — not a paper notice."""
	w, h = 36, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Post
	for y in range(8, h - 2):
		for x in range(14, 22):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 8))
	# Sign plaque
	for y in range(10, 28):
		for x in range(4, w - 4):
			put(px, x, y, jitter(bark[(x + y) % len(bark)], x, y, 7))
	# Arrow / glyph
	for x in range(10, 26):
		put(px, x, 16, jitter(ink[0], x, 16, 2), 255)
	for d in range(0, 6):
		put(px, 24 - d, 16 - d, jitter(ink[0], 24, 16, 2), 255)
		put(px, 24 - d, 16 + d, jitter(ink[0], 24, 16, 2), 255)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_pipe_schematic(wood, paper, ink, metal) -> Image.Image:
	w, h = 56, 48
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	# Pipe lines
	for x in range(12, w - 12):
		put(px, x, 18, jitter(metal[x % len(metal)], x, 18, 4), 255)
		put(px, x, 19, jitter(metal[(x + 1) % len(metal)], x, 19, 4), 240)
	for y in range(18, 34):
		put(px, 20, y, jitter(metal[y % len(metal)], 20, y, 4), 255)
		put(px, 36, y, jitter(metal[y % len(metal)], 36, y, 4), 255)
	for x in range(20, 37):
		put(px, x, 34, jitter(metal[x % len(metal)], x, 34, 4), 255)
	# Junction dots
	for cx, cy in ((20, 18), (36, 18), (20, 34), (36, 34)):
		put(px, cx, cy, jitter(ink[0], cx, cy, 2), 255)
	return im.filter(ImageFilter.SMOOTH)


def paint_cipher_plaque(wood, paper, ink, accent) -> Image.Image:
	w, h = 44, 48
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	# Glyph grid
	for row in range(3):
		for col in range(3):
			cx = 14 + col * 8
			cy = 14 + row * 8
			put(px, cx, cy, jitter(accent[(row + col) % len(accent)], cx, cy, 3), 255)
			put(px, cx + 1, cy, jitter(ink[0], cx, cy, 2), 240)
			put(px, cx, cy + 1, jitter(ink[1 % len(ink)], cx, cy, 2), 240)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_shift_board(wood, paper, ink, accent) -> Image.Image:
	w, h = 56, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	# Column headers
	for x in range(12, w - 12):
		put(px, x, 12, jitter(accent[x % len(accent)], x, 12, 4), 240)
	for col in (14, 28, 40):
		for y in range(16, h - 10):
			put(px, col, y, jitter(ink[0], col, y, 2), 180)
	for i, y in enumerate(range(18, h - 10, 7)):
		for x in range(16, 26):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 230)
		for x in range(30, 38):
			put(px, x, y, jitter(ink[(i + 1) % len(ink)], x, y, 2), 230)
		for x in range(42, w - 12):
			put(px, x, y, jitter((160, 130, 50), x, y, 3), 240)
	return im.filter(ImageFilter.SMOOTH)


def paint_night_market(wood, paper, ink, lantern) -> Image.Image:
	w, h = 52, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	# Lantern orb header
	for dy in range(-5, 6):
		for dx in range(-5, 6):
			if dx * dx + dy * dy <= 20:
				put(px, w // 2 + dx, 14 + dy, jitter(lantern[(dx + dy) % len(lantern)], dx, dy, 5), 250)
	for i, y in enumerate(range(24, h - 10, 7)):
		for x in range(12, w - 12):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 230)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_charm_list(wood, paper, ink, red) -> Image.Image:
	w, h = 48, 52
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	# Red seal
	for dy in range(-3, 4):
		for dx in range(-3, 4):
			if abs(dx) + abs(dy) < 5:
				put(px, w - 14 + dx, 14 + dy, jitter(red[0], dx, dy, 3), 255)
	for i, y in enumerate(range(20, h - 10, 7)):
		for x in range(12, w - 16):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 230)
		put(px, w - 14, y, jitter(red[i % len(red)], w - 14, y, 3), 250)
	return im.filter(ImageFilter.SMOOTH)


def paint_donation(wood, paper, ink, warm) -> Image.Image:
	w, h = 52, 52
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	# Heart / gift glyph
	for x in range(20, 32):
		put(px, x, 14, jitter(warm[0], x, 14, 3), 255)
	put(px, 22, 13, jitter(warm[1 % len(warm)], 22, 13, 3), 255)
	put(px, 28, 13, jitter(warm[1 % len(warm)], 28, 13, 3), 255)
	put(px, 25, 17, jitter(warm[0], 25, 17, 3), 255)
	for i, y in enumerate(range(22, h - 10, 7)):
		for x in range(12, w - 12):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 225)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_ferry_schedule(wood, paper, ink, blue) -> Image.Image:
	w, h = 56, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood_frame(px, w, h, wood, paper)
	for y in range(8, 14):
		for x in range(8, w - 8):
			put(px, x, y, jitter(blue[(x + y) % len(blue)], x, y, 5), 235)
	# Wave motif
	for x in range(12, w - 12):
		wy = 15 + (1 if (x // 4) % 2 == 0 else 0)
		put(px, x, wy, jitter(blue[0], x, wy, 3), 240)
	for i, y in enumerate(range(20, h - 10, 7)):
		for x in range(12, 30):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 230)
		for x in range(34, w - 12):
			put(px, x, y, jitter(blue[(i + x) % len(blue)], x, y, 4), 240)
	return im.filter(ImageFilter.SMOOTH)


def main() -> None:
	wood = sample_palette(IPROPS / "counter_00.png", 48)
	notice = sample_palette(IPROPS / "notice_00.png", 32)
	frame = [c for c in notice + wood if c[0] > c[2]][:40] or wood
	paper = [(230, 220, 195), (210, 200, 175), (240, 232, 210), (200, 190, 165)]
	ink = [(45, 40, 35), (60, 55, 45), (35, 35, 40), (70, 60, 50)]
	accent = [(140, 100, 50), (160, 120, 60), (120, 85, 45)]
	warn = [(200, 160, 40), (180, 140, 30), (220, 180, 50)]
	bark = frame
	metal = [(90, 95, 100), (70, 75, 80), (110, 115, 120), (60, 65, 70)]
	lantern = [(220, 140, 50), (200, 100, 40), (240, 170, 70), (180, 90, 35)]
	red = [(180, 50, 45), (200, 70, 55), (160, 40, 40)]
	warm = [(200, 90, 80), (180, 70, 65), (220, 110, 95)]
	blue = [(50, 90, 140), (60, 110, 160), (40, 70, 120), (80, 130, 170)]

	jobs = [
		("cargo_manifest_00.png", paint_cargo_manifest(frame, paper, ink)),
		("shop_price_board_00.png", paint_shop_price(frame, paper, ink, accent)),
		("house_rules_00.png", paint_house_rules(frame, paper, ink)),
		("mine_safety_00.png", paint_mine_safety(frame, paper, ink, warn)),
		("catalog_card_00.png", paint_catalog_card(frame, paper, ink)),
		("trail_marker_00.png", paint_trail_marker(frame, bark, ink)),
		("pipe_schematic_00.png", paint_pipe_schematic(frame, paper, ink, metal)),
		("cipher_plaque_00.png", paint_cipher_plaque(frame, paper, ink, accent)),
		("shift_board_00.png", paint_shift_board(frame, paper, ink, accent)),
		("night_market_board_00.png", paint_night_market(frame, paper, ink, lantern)),
		("charm_list_00.png", paint_charm_list(frame, paper, ink, red)),
		("donation_board_00.png", paint_donation(frame, paper, ink, warm)),
		("ferry_schedule_00.png", paint_ferry_schedule(frame, paper, ink, blue)),
	]
	for name, im in jobs:
		im = ImageEnhance.Contrast(im).enhance(1.08)
		im.save(IPROPS / name)
		write_import(IPROPS, name)
		print(f"wrote {name} uniq={uniq_count(im)} size={im.size}")


if __name__ == "__main__":
	main()
