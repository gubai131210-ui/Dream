#!/usr/bin/env python3
"""Edge-key white plates on all production NPC walk packs for style-consistent cutouts."""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
NPC = ROOT / "assets" / "sprites" / "npc"
PACKS = (
	"farmer",
	"blacksmith",
	"elder_woman",
	"merchant",
	"station_master",
	"mayor",
	"miller",
	"player",
)
THR = 235


def is_near_white(px: tuple[int, int, int, int]) -> bool:
	r, g, b, a = px
	return a > 0 and r >= THR and g >= THR and b >= THR


def key_edge_white(path: Path) -> int:
	im = Image.open(path).convert("RGBA")
	w, h = im.size
	px = im.load()
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

	cleared = 0
	while q:
		x, y = q.popleft()
		if is_near_white(px[x, y]):
			px[x, y] = (0, 0, 0, 0)
			cleared += 1
		if px[x, y][3] == 0:
			for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
				if 0 <= nx < w and 0 <= ny < h and not seen[nx][ny]:
					if px[nx, ny][3] == 0 or is_near_white(px[nx, ny]):
						push(nx, ny)
	im.save(path)
	return cleared


def main() -> None:
	total = 0
	for pack in PACKS:
		d = NPC / pack
		if not d.exists():
			print(f"[skip] missing {pack}")
			continue
		cleared = 0
		for f in sorted(d.glob("walk_*.png")):
			cleared += key_edge_white(f)
		total += cleared
		print(f"[ok] {pack}: keyed {cleared} edge-white px")
	print(f"GREEN regenerate_npc_packs ({len(PACKS)} packs, {total} px cleared)")


if __name__ == "__main__":
	main()
