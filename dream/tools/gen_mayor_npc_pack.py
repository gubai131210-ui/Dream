#!/usr/bin/env python3
"""Create a mayor NPC pack from station_master with a formal recolor."""

from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "sprites" / "npc" / "station_master"
DST = ROOT / "assets" / "sprites" / "npc" / "mayor"


def recolor(im: Image.Image) -> Image.Image:
	"""Shift cool uniform blues toward deep burgundy for a mayor look."""
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a < 16:
				continue
			# Blue-ish coat / hat band → burgundy
			if b > r + 12 and b > g + 8 and b > 60:
				nr = min(255, int(r * 0.55 + 110))
				ng = min(255, int(g * 0.35 + 20))
				nb = min(255, int(b * 0.25 + 30))
				px[x, y] = (nr, ng, nb, a)
			# Light gray trim → soft gold
			elif abs(r - g) < 12 and abs(g - b) < 12 and 140 < r < 220 and a > 200:
				px[x, y] = (min(255, r + 30), min(255, int(g * 0.85 + 40)), max(0, b - 40), a)
	return im


def main() -> None:
	if not SRC.exists():
		raise SystemExit(f"missing source {SRC}")
	if DST.exists():
		shutil.rmtree(DST)
	DST.mkdir(parents=True)
	n = 0
	for f in sorted(SRC.glob("walk_*.png")):
		im = Image.open(f).convert("RGBA")
		recolor(im).save(DST / f.name)
		n += 1
	(DST / "meta.json").write_text(
		json.dumps(
			{
				"id": "mayor",
				"title": "镇长",
				"source": "recolor from station_master (C06 formal pack)",
				"height_px": 56,
				"canvas_width_px": 48,
				"columns": 4,
				"dirs": ["down", "left", "right", "up"],
			},
			ensure_ascii=False,
			indent=2,
		)
		+ "\n",
		encoding="utf-8",
	)
	print(f"wrote {n} frames to {DST.relative_to(ROOT)}")


if __name__ == "__main__":
	main()
