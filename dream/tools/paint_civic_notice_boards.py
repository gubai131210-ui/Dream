#!/usr/bin/env python3
"""Paint dedicated civic notice boards that outgrew generic notice_00 proxies."""
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
	old = "counter_00.png"
	text = TMPL.replace(old, name)
	uid = "uid://c" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(folder / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def _frame(px, w: int, h: int, wood: list, paper: list, ink: list) -> None:
	for y in range(2, h - 2):
		for x in range(2, w - 2):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 8))
	for y in range(8, h - 8):
		for x in range(8, w - 8):
			put(px, x, y, jitter(paper[(x + y * 2) % len(paper)], x, y, 6))
	# Header bar
	for x in range(10, w - 10):
		put(px, x, 10, jitter(ink[0], x, 10, 3), 240)
		put(px, x, 11, jitter(ink[1 % len(ink)], x, 11, 3), 220)


def paint_clinic_fee(wood: list, paper: list, ink: list, accent: list) -> Image.Image:
	"""Tall fee schedule with green medical stripe — not cork notice collage."""
	w, h = 52, 60
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	_frame(px, w, h, wood, paper, ink)
	# Left teal stripe (clinic cue)
	for y in range(12, h - 8):
		for x in range(8, 12):
			put(px, x, y, jitter(accent[(y) % len(accent)], x, y, 5))
	# Fee rows + coin dots
	for i, y in enumerate(range(16, h - 12, 7)):
		for x in range(14, w - 12):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 230)
		put(px, w - 14, y - 1, jitter((180, 150, 60), w - 14, y, 3), 255)
	# Cross mark top-right
	for d in range(-3, 4):
		put(px, w - 16 + d, 14, (200, 70, 70), 255)
		put(px, w - 16, 14 + d, (200, 70, 70), 255)
	return im.filter(ImageFilter.SMOOTH)


def paint_exhibit_guide(wood: list, paper: list, ink: list, gold: list) -> Image.Image:
	"""Floor-plan style guide plaque with gallery grid."""
	w, h = 60, 52
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	_frame(px, w, h, wood, paper, ink)
	# Gold trim corners
	for cx, cy in ((10, 10), (w - 12, 10), (10, h - 12), (w - 12, h - 12)):
		put(px, cx, cy, jitter(gold[0], cx, cy, 2), 255)
		put(px, cx + 1, cy, jitter(gold[1 % len(gold)], cx, cy, 2), 240)
	# Mini room grid (2x2)
	cells = [(14, 16), (32, 16), (14, 30), (32, 30)]
	for i, (ox, oy) in enumerate(cells):
		for y in range(oy, oy + 10):
			for x in range(ox, ox + 14):
				c = paper[(x + y) % len(paper)] if (x + y) % 4 else ink[i % len(ink)]
				put(px, x, y, jitter(c, x, y, 4), 235)
		# Frame lines
		for x in range(ox, ox + 14):
			put(px, x, oy, jitter(ink[0], x, oy, 2), 250)
			put(px, x, oy + 9, jitter(ink[0], x, oy, 2), 250)
		for y in range(oy, oy + 10):
			put(px, ox, y, jitter(ink[0], ox, y, 2), 250)
			put(px, ox + 13, y, jitter(ink[0], ox, y, 2), 250)
	# You-are-here dot
	put(px, 20, 20, (200, 60, 55), 255)
	put(px, 21, 20, (200, 60, 55), 255)
	return im.filter(ImageFilter.SMOOTH_MORE)


def paint_bath_rules(wood: list, paper: list, ink: list, teal: list) -> Image.Image:
	"""Steam-teal rules plaque for bath / soak change rooms."""
	w, h = 52, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	_frame(px, w, h, wood, paper, ink)
	# Teal header wash
	for y in range(8, 16):
		for x in range(8, w - 8):
			put(px, x, y, jitter(teal[(x + y) % len(teal)], x, y, 6), 230)
	# Wave underline
	for x in range(12, w - 12):
		wy = 17 + (1 if (x // 3) % 2 == 0 else 0)
		put(px, x, wy, jitter(teal[0], x, wy, 3), 240)
	# Numbered rule rows
	for i, y in enumerate(range(22, h - 10, 8)):
		put(px, 12, y, jitter(teal[i % len(teal)], 12, y, 3), 255)
		for x in range(16, w - 12):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 225)
	return im.filter(ImageFilter.SMOOTH)


def paint_inn_rate(wood: list, paper: list, ink: list, warm: list) -> Image.Image:
	"""Warm inn rate board with bed-key glyph and price rows."""
	w, h = 56, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	_frame(px, w, h, wood, paper, ink)
	# Warm header
	for y in range(8, 15):
		for x in range(8, w - 8):
			put(px, x, y, jitter(warm[(x + y) % len(warm)], x, y, 5), 235)
	# Key glyph
	for x in range(14, 22):
		put(px, x, 18, jitter(ink[0], x, 18, 2), 255)
	put(px, 21, 19, jitter(ink[0], 21, 19, 2), 255)
	put(px, 21, 20, jitter(ink[0], 21, 20, 2), 255)
	put(px, 22, 20, jitter((180, 150, 60), 22, 20, 2), 255)
	# Rate rows
	for i, y in enumerate(range(24, h - 10, 8)):
		for x in range(12, w - 18):
			put(px, x, y, jitter(ink[i % len(ink)], x, y, 2), 230)
		for x in range(w - 16, w - 10):
			put(px, x, y, jitter((170, 140, 55), x, y, 3), 250)
	return im.filter(ImageFilter.SMOOTH_MORE)


def main() -> None:
	wood = sample_palette(IPROPS / "counter_00.png", 48)
	notice = sample_palette(IPROPS / "notice_00.png", 32)
	paper = [(230, 220, 195), (210, 200, 175), (240, 232, 210), (200, 190, 165)]
	ink = [(45, 40, 35), (60, 55, 45), (35, 35, 40), (70, 60, 50)]
	accent = [(40, 120, 110), (55, 140, 125), (30, 100, 95), (70, 150, 140)]
	gold = [(180, 150, 70), (200, 170, 90), (160, 130, 55)]
	teal = accent
	warm = [(160, 100, 60), (180, 120, 70), (140, 85, 50), (200, 140, 90)]
	# Prefer notice wood grain when available
	frame_wood = [c for c in notice + wood if c[0] > c[2]][:40] or wood

	jobs = [
		("clinic_fee_board_00.png", paint_clinic_fee(frame_wood, paper, ink, accent)),
		("exhibit_guide_00.png", paint_exhibit_guide(frame_wood, paper, ink, gold)),
		("bath_rules_00.png", paint_bath_rules(frame_wood, paper, ink, teal)),
		("inn_rate_board_00.png", paint_inn_rate(frame_wood, paper, ink, warm)),
	]
	for name, im in jobs:
		im = ImageEnhance.Contrast(im).enhance(1.08)
		im.save(IPROPS / name)
		write_import(IPROPS, name)
		print(f"wrote {name} uniq={uniq_count(im)} size={im.size}")


if __name__ == "__main__":
	main()
