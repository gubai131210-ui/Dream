#!/usr/bin/env python3
"""Fail if production NPC walk frames still carry edge-connected white plates."""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
NPC = ROOT / "assets" / "sprites" / "npc"
THR = 235
GRAY_MIN = 175
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
# Packs known to ship AI checkerboard plates — require gray-plate clearance too.
STRICT_PLATE_PACKS = ("farmer", "player")
MAX_EDGE_WHITE = 8
MAX_STRICT_PLATE = 8


def is_near_white(px: tuple[int, int, int, int]) -> bool:
	r, g, b, a = px
	return a > 0 and r >= THR and g >= THR and b >= THR


def is_plate_pixel(px: tuple[int, int, int, int]) -> bool:
	r, g, b, a = px
	if a < 12:
		return False
	if r >= 238 and g >= 238 and b >= 238:
		return True
	return abs(r - g) <= 10 and abs(g - b) <= 10 and min(r, g, b) >= GRAY_MIN


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


def count_plate(path: Path) -> int:
	im = Image.open(path).convert("RGBA")
	return sum(1 for p in im.getdata() if is_plate_pixel(p))


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
		worst_plate = 0
		worst_plate_name = ""
		for f in frames:
			n = max_edge_white(f)
			if n > worst:
				worst = n
				worst_name = f.name
			if pack in STRICT_PLATE_PACKS:
				p = count_plate(f)
				if p > worst_plate:
					worst_plate = p
					worst_plate_name = f.name
		if worst > MAX_EDGE_WHITE:
			failures.append(f"{pack}/{worst_name}: edge-white={worst} > {MAX_EDGE_WHITE}")
		if pack in STRICT_PLATE_PACKS and worst_plate > MAX_STRICT_PLATE:
			failures.append(
				f"{pack}/{worst_plate_name}: gray/white plate={worst_plate} > {MAX_STRICT_PLATE}"
			)
		if pack in STRICT_PLATE_PACKS:
			bb = Image.open(frames[0]).convert("RGBA").getchannel("A").getbbox()
			if bb is None or (bb[3] - bb[1]) < 46:
				failures.append(f"{pack}: silhouette too short bbox={bb}")
	if failures:
		raise SystemExit("FAIL npc white-plate QA:\n- " + "\n- ".join(failures))
	print(
		f"GREEN npc white-plate QA ({len(PACKS)} packs, "
		f"max_edge_white<={MAX_EDGE_WHITE}, farmer/player plate+height gate)"
	)


if __name__ == "__main__":
	main()
