#!/usr/bin/env python3
"""Paint stall_pole_00 — crisp 8×32 wooden post for C05 MarketStall poles."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "market" / "stall_pole_00.png"
TMPL = (ROOT / "assets" / "sprites" / "market" / "stall_awning_00.png.import").read_text(encoding="utf-8")


def paint() -> None:
	w, h = 8, 32
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	px = im.load()
	wood = [
		(86, 54, 28),
		(102, 66, 34),
		(118, 78, 42),
		(74, 46, 24),
		(130, 90, 50),
	]
	for y in range(h):
		for x in range(1, w - 1):
			if x == 1 or x == w - 2:
				c = wood[3]
			elif x == 2:
				c = wood[4] if (y // 3) % 2 == 0 else wood[2]
			else:
				c = wood[(x + y // 2) % 3]
			if (x * 3 + y * 5) % 7 == 0:
				c = tuple(max(0, min(255, v - 12)) for v in c)
			px[x, y] = (*c, 255)
	for x in range(1, w - 1):
		px[x, 0] = (140, 96, 54, 255)
		px[x, 1] = (110, 70, 36, 255)
		px[x, h - 2] = (62, 58, 50, 255)
		px[x, h - 1] = (48, 44, 38, 255)
	OUT.parent.mkdir(parents=True, exist_ok=True)
	im.save(OUT)
	uid = "uid://" + uuid.uuid4().hex[:13]
	lines: list[str] = []
	for line in TMPL.splitlines():
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"')
		else:
			lines.append(line.replace("stall_awning_00.png", "stall_pole_00.png"))
	(OUT.with_suffix(".png.import")).write_text("\n".join(lines) + "\n", encoding="utf-8")
	print("wrote", OUT, im.size, "bbox", im.getbbox())


if __name__ == "__main__":
	paint()
