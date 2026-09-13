#!/usr/bin/env python3
"""StyleQA: work pose sheets — canvas, frame count, edge-white, foot plant."""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
POSE_ROOT = ROOT / "assets" / "sprites" / "npc" / "work_poses"
LIFE_ROOT = ROOT / "assets" / "sprites" / "npc" / "life_poses"
KINDS = ("sow", "smith", "stall", "cook")
LIFE_KINDS = ("eat", "sleep", "read", "laundry", "idle_sit")
EXPECT_W, EXPECT_H = 48, 40  # drawer used 48x40; poses may differ — record actual
THR = 235
MAX_EDGE_WHITE = 12


def edge_white(path: Path) -> int:
	im = Image.open(path).convert("RGBA")
	w, h = im.size
	px = im.load()
	seen = [[False] * h for _ in range(w)]
	q: deque[tuple[int, int]] = deque()

	def push(x: int, y: int) -> None:
		if 0 <= x < w and 0 <= y < h and not seen[x][y]:
			seen[x][y] = True
			q.append((x, y))

	def seed(x: int, y: int) -> bool:
		r, g, b, a = px[x, y]
		return a == 0 or (a > 0 and r >= THR and g >= THR and b >= THR)

	for x in range(w):
		for y in (0, h - 1):
			if seed(x, y):
				push(x, y)
	for y in range(h):
		for x in (0, w - 1):
			if seed(x, y):
				push(x, y)
	n = 0
	while q:
		x, y = q.popleft()
		r, g, b, a = px[x, y]
		if a > 0 and r >= THR and g >= THR and b >= THR:
			n += 1
		if a == 0 or (a > 0 and r >= THR and g >= THR and b >= THR):
			for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
				if 0 <= nx < w and 0 <= ny < h and not seen[nx][ny] and seed(nx, ny):
					push(nx, ny)
	return n


def check_kinds(root: Path, kinds: tuple[str, ...], label: str, failures: list[str], sizes: set[tuple[int, int]]) -> None:
	for kind in kinds:
		d = root / kind
		frames = sorted(d.glob("pose_*.png"))
		if len(frames) < 4:
			failures.append(f"{label}/{kind}: need ≥4 frames, got {len(frames)}")
			continue
		for f in frames[:4]:
			im = Image.open(f).convert("RGBA")
			sizes.add(im.size)
			ew = edge_white(f)
			if ew > MAX_EDGE_WHITE:
				failures.append(f"{label}/{kind}/{f.name}: edge-white={ew}")
			uniq = len({c[:3] for c in im.getdata() if c[3] > 200})
			if uniq < 80:
				failures.append(f"{label}/{kind}/{f.name}: uniq={uniq} < 80 (need painted density)")
			bb = im.getchannel("A").getbbox()
			if bb is None:
				failures.append(f"{label}/{kind}/{f.name}: empty alpha")
			else:
				foot = bb[3]
				if foot < im.height - 4:
					gap = im.height - foot
					if gap > 8:
						failures.append(f"{label}/{kind}/{f.name}: foot gap={gap}px from canvas bottom")


def main() -> None:
	failures: list[str] = []
	sizes: set[tuple[int, int]] = set()
	check_kinds(POSE_ROOT, KINDS, "work", failures, sizes)
	check_kinds(LIFE_ROOT, LIFE_KINDS, "life", failures, sizes)
	if len(sizes) > 1:
		failures.append(f"inconsistent canvas sizes across poses: {sorted(sizes)}")
	if failures:
		raise SystemExit("FAIL work/life-pose StyleQA:\n- " + "\n- ".join(failures))
	print(
		f"GREEN work/life-pose StyleQA "
		f"(work {len(KINDS)} + life {len(LIFE_KINDS)} kinds ×4, sizes={sorted(sizes)}, edge-white≤{MAX_EDGE_WHITE})"
	)


if __name__ == "__main__":
	main()
