#!/usr/bin/env python3
"""Fail if production NPC walk frames still carry edge-connected white plates."""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
NPC = ROOT / "assets" / "sprites" / "npc"
THR = 235
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
MAX_EDGE_WHITE = 8


def max_edge_white(path: Path) -> int:
	im = Image.open(path).convert("RGBA")
	w, h = im.size
	px = im.load()
	seen = [[False] * h for _ in range(w)]
	q: deque[tuple[int, int]] = deque()

	def push(x: int, y: int) -> None:
		if 0 <= x < w and 0 <= y < h and not seen[x][y]:
			seen[x][y] = True
			q.append((x, y))

	def is_seed(x: int, y: int) -> bool:
		r, g, b, a = px[x, y]
		return a == 0 or (a > 0 and r >= THR and g >= THR and b >= THR)

	for x in range(w):
		for y in (0, h - 1):
			if is_seed(x, y):
				push(x, y)
	for y in range(h):
		for x in (0, w - 1):
			if is_seed(x, y):
				push(x, y)

	edge_w = 0
	while q:
		x, y = q.popleft()
		r, g, b, a = px[x, y]
		if a > 0 and r >= THR and g >= THR and b >= THR:
			edge_w += 1
		if a == 0 or (a > 0 and r >= THR and g >= THR and b >= THR):
			for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
				if 0 <= nx < w and 0 <= ny < h and not seen[nx][ny]:
					if is_seed(nx, ny):
						push(nx, ny)
	return edge_w


def main() -> None:
	failures: list[str] = []
	for pack in PACKS:
		d = NPC / pack
		frames = sorted(d.glob("walk_*.png"))
		if not frames:
			failures.append(f"{pack}: missing walk frames")
			continue
		worst = 0
		worst_name = ""
		for f in frames:
			n = max_edge_white(f)
			if n > worst:
				worst = n
				worst_name = f.name
		if worst > MAX_EDGE_WHITE:
			failures.append(f"{pack}/{worst_name}: edge-white={worst} > {MAX_EDGE_WHITE}")
	if failures:
		raise SystemExit("FAIL npc white-plate QA:\n- " + "\n- ".join(failures))
	print(f"GREEN npc white-plate QA ({len(PACKS)} packs, max_edge_white<={MAX_EDGE_WHITE})")


if __name__ == "__main__":
	main()
