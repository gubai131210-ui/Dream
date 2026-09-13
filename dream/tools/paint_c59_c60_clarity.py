#!/usr/bin/env python3
"""Repaint C59 weed + C60 fallen-log gates to painted-grade density (no soft blur)."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
TMPL = (PROPS / "breakable_stake_00.png.import").read_text(encoding="utf-8")


def jitter(rgb: tuple[int, int, int], x: int, y: int, amp: int = 8) -> tuple[int, int, int]:
	h = (x * 374761393 + y * 668265263) & 0xFFFFFFFF
	dr = ((h & 255) % (amp * 2 + 1)) - amp
	dg = (((h >> 8) & 255) % (amp * 2 + 1)) - amp
	db = (((h >> 16) & 255) % (amp * 2 + 1)) - amp
	return (
		max(0, min(255, rgb[0] + dr)),
		max(0, min(255, rgb[1] + dg)),
		max(0, min(255, rgb[2] + db)),
	)


def write_import(name: str) -> None:
	uid = "uid://" + uuid.uuid4().hex[:13]
	lines: list[str] = []
	for line in TMPL.splitlines():
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"')
		else:
			lines.append(
				line.replace("breakable_stake_00.png", name).replace(
					"breakable_stake_00", name.replace(".png", "")
				)
			)
	(PROPS / f"{name}.import").write_text("\n".join(lines) + "\n", encoding="utf-8")


def paint_weed() -> Image.Image:
	w, h = 40, 36
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	greens = [
		(46, 92, 38),
		(58, 110, 44),
		(72, 128, 52),
		(38, 78, 32),
		(88, 140, 60),
		(52, 100, 48),
		(34, 70, 28),
		(96, 148, 70),
	]
	soil = [(78, 58, 36), (64, 48, 30), (90, 68, 42)]
	# Soil patch
	for y in range(h - 6, h - 2):
		for x in range(4, w - 4):
			if (x + y) % 3 != 0:
				px[x, y] = (*jitter(soil[(x + y) % len(soil)], x, y, 5), 220)
	# Blade clumps
	bases = [7, 11, 15, 19, 23, 27, 31]
	for i, bx in enumerate(bases):
		hgt = 14 + (i * 3) % 10
		for t in range(hgt):
			y = h - 7 - t
			bend = (t // 4) * (1 if i % 2 == 0 else -1)
			x = bx + bend
			col = greens[(i * 2 + t // 2) % len(greens)]
			for dx in (0, 1):
				xx = x + dx
				if 0 <= xx < w and 0 <= y < h:
					px[xx, y] = (*jitter(col, xx, y, 6), 255)
			# leaf tip flare
			if t > hgt - 4:
				for dx in (-1, 0, 1):
					xx = x + dx
					yy = y - 1
					if 0 <= xx < w and 0 <= yy < h:
						px[xx, yy] = (*jitter(greens[(i + 3) % len(greens)], xx, yy, 4), 230)
	# Seed heads
	for sx, sy in ((12, 14), (20, 12), (28, 15)):
		for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
			px[sx + dx, sy + dy] = (*jitter((120, 150, 70), sx, sy, 5), 240)
	return im


def paint_fallen_log() -> Image.Image:
	w, h = 56, 28
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	bark = [
		(92, 62, 36),
		(78, 52, 30),
		(108, 74, 42),
		(64, 44, 26),
		(120, 84, 48),
		(70, 48, 28),
	]
	core = [(140, 110, 70), (160, 128, 82), (120, 95, 60)]
	# Horizontal trunk body
	for y in range(8, 22):
		for x in range(4, 52):
			# elliptical falloff
			cy = abs(y - 15) / 7.0
			if cy > 1.0:
				continue
			edge = cy > 0.75
			col = bark[(x // 3 + y) % len(bark)] if not edge else bark[3]
			if (x + y * 2) % 11 == 0:
				col = bark[0]
			px[x, y] = (*jitter(col, x, y, 7), 255)
	# Cut ends with rings
	for end_x in (4, 51):
		for y in range(9, 21):
			for dx in range(3):
				x = end_x + (dx if end_x < 10 else -dx)
				if 0 <= x < w:
					px[x, y] = (*jitter(core[(y + dx) % len(core)], x, y, 4), 255)
		# ring marks
		for y in (11, 15, 19):
			x = end_x + (1 if end_x < 10 else -1)
			px[x, y] = (*jitter((90, 70, 40), x, y, 3), 255)
	# Moss patch
	for x in range(22, 34):
		for y in range(8, 11):
			px[x, y] = (*jitter((58, 110, 48), x, y, 5), 240)
	# Shadow contact
	for x in range(6, 50):
		px[x, 22] = (*jitter((40, 32, 24), x, 22, 3), 180)
	return im


def main() -> None:
	weed = paint_weed()
	log = paint_fallen_log()
	weed.save(PROPS / "breakable_weed_00.png")
	write_import("breakable_weed_00.png")
	log.save(PROPS / "gate_log_00.png")
	write_import("gate_log_00.png")
	wu = len({c[:3] for c in weed.getdata() if c[3] > 200})
	lu = len({c[:3] for c in log.getdata() if c[3] > 200})
	print("weed", weed.size, "uniq", wu)
	print("log", log.size, "uniq", lu)
	assert wu >= 60, wu
	assert lu >= 60, lu


if __name__ == "__main__":
	main()
