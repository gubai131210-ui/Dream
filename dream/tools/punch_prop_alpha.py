#!/usr/bin/env python3
"""Punch opaque white / near-black / checker leftovers to alpha on prop PNGs."""
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def punch(im: Image.Image, white_thr: int = 245, black_thr: int = 10) -> tuple[Image.Image, int]:
	im = im.convert("RGBA")
	px = im.load()
	w, h = im.size
	cleared = 0
	# Flood from corners if they look like solid bg
	corners = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]
	bg_mode = None
	for cx, cy in corners:
		r, g, b, a = px[cx, cy]
		if a > 200 and r >= white_thr and g >= white_thr and b >= white_thr:
			bg_mode = "white"
			break
		if a > 200 and r <= black_thr and g <= black_thr and b <= black_thr:
			bg_mode = "black"
			break
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			kill = False
			if r >= white_thr and g >= white_thr and b >= white_thr:
				kill = True
			elif bg_mode == "black" and r <= black_thr and g <= black_thr and b <= black_thr:
				kill = True
			# checkerboard mid-grays often 180-210 alternating — only kill if neighbor also midgray fringe
			elif 175 <= r <= 210 and abs(r - g) <= 8 and abs(g - b) <= 8 and a > 200:
				# only clear if near image edge or surrounded by transparency/same gray
				edge = x < 2 or y < 2 or x >= w - 2 or y >= h - 2
				if edge:
					kill = True
			if kill:
				px[x, y] = (0, 0, 0, 0)
				cleared += 1
	return im, cleared


def main() -> int:
	ap = argparse.ArgumentParser()
	ap.add_argument("--path", default="assets/sprites/props/rocks", help="relative to dream/")
	ap.add_argument("--dry", action="store_true")
	args = ap.parse_args()
	root = ROOT / args.path
	files = sorted(root.rglob("*.png")) if root.is_dir() else [root]
	total = 0
	for p in files:
		if not p.is_file():
			continue
		im, n = punch(Image.open(p))
		total += n
		print(f"{p.relative_to(ROOT)}: cleared {n}")
		if not args.dry and n:
			im.save(p)
	print(f"GREEN punch done total_cleared={total}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
