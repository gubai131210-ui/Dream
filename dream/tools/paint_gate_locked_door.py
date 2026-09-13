#!/usr/bin/env python3
"""Paint gate_locked_door_00 — C60 locked-door gate (not generic door_facade)."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "props" / "gate_locked_door_00.png"
TMPL = (ROOT / "assets" / "sprites" / "props" / "door_facade_00.png.import").read_text(encoding="utf-8")


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


def paint() -> None:
	w, h = 40, 56
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	# Frame (stone/wood jamb)
	frame = (72, 58, 44)
	plank_a = (118, 78, 42)
	plank_b = (96, 62, 34)
	plank_c = (140, 94, 52)
	iron = (58, 62, 70)
	iron_hi = (92, 98, 108)
	lock = (196, 164, 64)
	lock_dk = (140, 110, 36)

	# Outer frame
	for y in range(4, h - 2):
		for x in range(6, w - 6):
			edge = x <= 8 or x >= w - 9 or y <= 6 or y >= h - 5
			if edge:
				px[x, y] = (*jitter(frame, x, y, 6), 255)

	# Door planks (vertical)
	for y in range(7, h - 5):
		for x in range(9, w - 9):
			band = (x - 9) // 5
			base = plank_a if band % 2 == 0 else plank_b
			if (x + y // 3) % 7 == 0:
				base = plank_c
			px[x, y] = (*jitter(base, x, y, 7), 255)

	# Horizontal rails
	for y in (14, 28, 42):
		for x in range(9, w - 9):
			px[x, y] = (*jitter(frame, x, y, 5), 255)
			if y + 1 < h - 5:
				px[x, y + 1] = (*jitter(plank_b, x, y + 1, 4), 255)

	# Iron bar across mid
	for y in range(26, 30):
		for x in range(10, w - 10):
			c = iron_hi if y == 27 else iron
			px[x, y] = (*jitter(c, x, y, 4), 255)

	# Padlock body (right-center)
	for y in range(24, 34):
		for x in range(24, 32):
			inside = 25 <= x <= 30 and 26 <= y <= 32
			if inside:
				c = lock if (x + y) % 3 else lock_dk
				px[x, y] = (*jitter(c, x, y, 3), 255)
	# Lock shackle
	for x in range(26, 30):
		px[x, 23] = (*iron_hi, 255)
		px[x, 24] = (*iron, 255)
	px[25, 24] = (*iron, 255)
	px[30, 24] = (*iron, 255)
	px[25, 25] = (*iron_hi, 255)
	px[30, 25] = (*iron_hi, 255)
	# Keyhole
	px[27, 29] = (28, 24, 18, 255)
	px[28, 29] = (28, 24, 18, 255)
	px[27, 30] = (28, 24, 18, 255)

	# Threshold stone
	for y in range(h - 4, h - 1):
		for x in range(8, w - 8):
			px[x, y] = (*jitter((88, 84, 78), x, y, 5), 255)

	OUT.parent.mkdir(parents=True, exist_ok=True)
	im.save(OUT)
	uid = "uid://" + uuid.uuid4().hex[:13]
	lines: list[str] = []
	for line in TMPL.splitlines():
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"')
		else:
			lines.append(line.replace("door_facade_00.png", "gate_locked_door_00.png"))
	(OUT.with_suffix(".png.import")).write_text("\n".join(lines) + "\n", encoding="utf-8")
	print("wrote", OUT, im.size, "bbox", im.getbbox())


if __name__ == "__main__":
	paint()
