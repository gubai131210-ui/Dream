#!/usr/bin/env python3
"""Paint dedicated C05 EMPTY / LOCKED stall bay sprites (no furrow/door proxies)."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
MARKET = ROOT / "assets" / "sprites" / "market"
PROPS = ROOT / "assets" / "sprites" / "props"
TMPL = (MARKET / "stall_open_wood_00.png.import").read_text(encoding="utf-8")


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
	old = "stall_open_wood_00.png"
	text = TMPL.replace(old, name)
	uid = "uid://m" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(folder / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def paint_empty_bay(wood: list, dirt: list) -> Image.Image:
	"""Vacant stall pad: plank outline + worn dirt footprint (not a furrow strip)."""
	w, h = 80, 40
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Dirt pad
	for y in range(18, h - 4):
		for x in range(6, w - 6):
			put(px, x, y, jitter(dirt[(x + y) % len(dirt)], x, y, 8), 210)
	# Plank stakes / corner pegs
	for sx in (10, w - 14):
		for y in range(8, 28):
			for dx in range(3):
				put(px, sx + dx, y, jitter(wood[(sx + y) % len(wood)], sx, y, 7))
	# Dashed bay outline
	for x in range(8, w - 8):
		if (x // 4) % 2 == 0:
			put(px, x, 16, jitter(wood[x % len(wood)], x, 16, 5), 230)
			put(px, x, h - 6, jitter(wood[(x + 2) % len(wood)], x, h - 6, 5), 200)
	return im.filter(ImageFilter.SMOOTH)


def paint_locked_board(wood: list, metal: list) -> Image.Image:
	"""Closed/locked stall face board with latch (not door_facade reuse)."""
	w, h = 72, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Board body
	for y in range(8, h - 8):
		for x in range(8, w - 8):
			c = wood[(x * 2 + y) % len(wood)]
			if y % 7 == 0:
				c = wood[(x + 3) % len(wood)]
			put(px, x, y, jitter(c, x, y, 9))
	# Frame
	for y in range(6, h - 6):
		for x in list(range(6, 10)) + list(range(w - 10, w - 6)):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 6))
	for x in range(6, w - 6):
		for y in list(range(6, 10)) + list(range(h - 10, h - 6)):
			put(px, x, y, jitter(wood[(x + y) % len(wood)], x, y, 6))
	# Latch / lock plate
	for y in range(22, 34):
		for x in range(30, 44):
			put(px, x, y, jitter(metal[(x + y) % len(metal)], x, y, 5))
	put(px, 42, 28, (220, 190, 80), 240)
	put(px, 43, 28, (180, 150, 50), 230)
	return im.filter(ImageFilter.SMOOTH_MORE)


def main() -> None:
	stall = sample_palette(MARKET / "stall_open_wood_00.png", 64)
	facade = sample_palette(PROPS / "door_facade_00.png", 48)
	wood = [c for c in stall + facade if c[0] > c[2]][:48] or stall[:32]
	dirt = [c for c in stall if min(c) < 140][:24] or wood[:16]
	metal = [(70, 70, 65), (90, 88, 80), (55, 55, 50), (110, 105, 95)] + [
		(max(40, c[0] // 2), max(40, c[1] // 2), max(35, c[2] // 2)) for c in wood[:8]
	]
	jobs = [
		("stall_empty_bay_00.png", paint_empty_bay(wood, dirt)),
		("stall_locked_board_00.png", paint_locked_board(wood, metal)),
	]
	for name, im in jobs:
		im = ImageEnhance.Contrast(im).enhance(1.1)
		im.save(MARKET / name)
		write_import(MARKET, name)
		print(f"wrote {name} uniq={uniq_count(im)} size={im.size}")


if __name__ == "__main__":
	main()
