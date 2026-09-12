#!/usr/bin/env python3
"""Create a miller NPC pack from farmer with flour-dusted recolor."""

from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "sprites" / "npc" / "farmer"
DST = ROOT / "assets" / "sprites" / "npc" / "miller"


def recolor(im: Image.Image) -> Image.Image:
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a < 16:
				continue
			# Green shirt → dusty linen
			if g > r + 15 and g > b + 10 and g > 70:
				nr = min(255, int(r * 0.5 + 170))
				ng = min(255, int(g * 0.45 + 160))
				nb = min(255, int(b * 0.4 + 140))
				px[x, y] = (nr, ng, nb, a)
			# Brown overalls → charcoal apron
			elif r > 50 and r > g + 10 and r > b + 15 and g < 120:
				px[x, y] = (min(255, int(r * 0.45 + 40)), min(255, int(g * 0.4 + 35)), min(255, int(b * 0.4 + 35)), a)
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
				"id": "miller",
				"title": "磨坊主",
				"source": "recolor from farmer (mill interior actor)",
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
