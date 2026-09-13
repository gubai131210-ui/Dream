#!/usr/bin/env python3
"""Build protagonist 8-frame walk pack from farmer_v5 with hero palette recolor."""

from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "sprites" / "npc" / "farmer_v5"
OUT = ROOT / "assets" / "sprites" / "npc" / "player"
THR = 235


def is_near_white(px: tuple[int, int, int, int]) -> bool:
	r, g, b, a = px
	return a > 0 and r >= THR and g >= THR and b >= THR


def key_edge_white(im: Image.Image) -> Image.Image:
	out = im.convert("RGBA")
	w, h = out.size
	px = out.load()
	q: deque[tuple[int, int]] = deque()
	seen = [[False] * h for _ in range(w)]

	def push(x: int, y: int) -> None:
		if 0 <= x < w and 0 <= y < h and not seen[x][y]:
			seen[x][y] = True
			q.append((x, y))

	for x in range(w):
		for y in (0, h - 1):
			if px[x, y][3] == 0 or is_near_white(px[x, y]):
				push(x, y)
	for y in range(h):
		for x in (0, w - 1):
			if px[x, y][3] == 0 or is_near_white(px[x, y]):
				push(x, y)

	while q:
		x, y = q.popleft()
		if is_near_white(px[x, y]):
			px[x, y] = (0, 0, 0, 0)
		if px[x, y][3] == 0:
			for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
				if 0 <= nx < w and 0 <= ny < h and not seen[nx][ny]:
					if px[nx, ny][3] == 0 or is_near_white(px[nx, ny]):
						push(nx, ny)
	return out


def recolor_hero(im: Image.Image) -> Image.Image:
	"""Shift farmer earth tones to a blue-tunic protagonist while keeping outlines."""
	out = im.convert("RGBA")
	px = out.load()
	w, h = out.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			# Skin stays warm.
			if r > 150 and g > 110 and b > 90 and r >= g >= b:
				continue
			# Straw / hat / pants browns -> navy hero tunic + dark boots.
			if g < 120 and r > 60:
				nr = min(255, int(r * 0.45 + 40))
				ng = min(255, int(g * 0.55 + 55))
				nb = min(255, int(b * 0.65 + 95))
				px[x, y] = (nr, ng, nb, a)
			elif g >= 120 and b < 110:
				nr = min(255, int(r * 0.35 + 35))
				ng = min(255, int(g * 0.45 + 70))
				nb = min(255, int(b * 0.55 + 120))
				px[x, y] = (nr, ng, nb, a)
	return out


def main() -> None:
	if not SRC.exists():
		raise SystemExit(f"missing source pack {SRC}")
	OUT.mkdir(parents=True, exist_ok=True)
	for old in OUT.glob("walk_*.png"):
		old.unlink()
	count = 0
	for src in sorted(SRC.glob("walk_*.png")):
		im = key_edge_white(recolor_hero(Image.open(src)))
		im.save(OUT / src.name)
		count += 1
	meta = {
		"id": "player",
		"title": "主角",
		"source": "farmer_v5 recolor (hero palette)",
		"height_px": 56,
		"canvas_width_px": 48,
		"columns": 8,
		"dirs": ["down", "left", "right", "up"],
	}
	(OUT / "meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
	print(f"GREEN protagonist pack: {count} frames -> {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
	main()
