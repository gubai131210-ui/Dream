#!/usr/bin/env python3
"""Promote farmer_v5 (8-frame walk) into production farmer pack."""
from __future__ import annotations

import json
import shutil
from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
NPC = ROOT / "assets" / "sprites" / "npc"
ARCH = NPC / "_misnamed_archive"
THR = 235
TMPL = (NPC / "merchant" / "walk_down_0.png.import").read_text(encoding="utf-8")


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
		r, g, b, a = px[x, y]
		if is_near_white(px[x, y]):
			px[x, y] = (0, 0, 0, 0)
			cleared += 1
			a = 0
		if a == 0:
			for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
				if 0 <= nx < w and 0 <= ny < h and not seen[nx][ny]:
					if px[nx, ny][3] == 0 or is_near_white(px[nx, ny]):
						push(nx, ny)
	im.save(path)
	return cleared


def write_import(folder: Path, name: str) -> None:
	import uuid

	text = TMPL.replace("walk_down_0.png", name)
	# Also replace merchant path fragment if present
	text = text.replace("npc/merchant/", "npc/farmer/")
	uid = "uid://f" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(folder / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def main() -> None:
	src = NPC / "farmer"
	v5 = NPC / "farmer_v5"
	bak = ARCH / "pre_v5_promote_farmer_4frame"
	if not v5.is_dir():
		raise SystemExit("farmer_v5 missing")
	ARCH.mkdir(exist_ok=True)
	if bak.exists():
		shutil.rmtree(bak)
	shutil.copytree(src, bak)
	for old in src.glob("walk_*.png"):
		old.unlink()
	for old in src.glob("walk_*.png.import"):
		old.unlink()
	cleared = 0
	for f in sorted(v5.glob("walk_*.png")):
		dest = src / f.name
		shutil.copy2(f, dest)
		cleared += key_edge_white(dest)
		write_import(src, f.name)
	(src / "meta.json").write_text(
		json.dumps(
			{
				"id": "farmer",
				"title": "农夫",
				"source": "promoted from farmer_v5 (8-frame walk; edge-white keyed)",
				"height_px": 56,
				"canvas_width_px": 48,
				"columns": 8,
				"dirs": ["down", "left", "right", "up"],
			},
			ensure_ascii=False,
			indent=2,
		)
		+ "\n",
		encoding="utf-8",
	)
	# Verify
	bad = 0
	for f in src.glob("walk_*.png"):
		im = Image.open(f).convert("RGBA")
		nw = sum(1 for p in im.getdata() if p[3] > 200 and p[0] >= THR and p[1] >= THR and p[2] >= THR)
		if nw > 15:
			bad += 1
	print(f"promoted farmer_v5 -> farmer; cleared_edge_white={cleared}; frames_with_>15_white={bad}/32")
	print("archived", bak.relative_to(ROOT))


if __name__ == "__main__":
	main()
