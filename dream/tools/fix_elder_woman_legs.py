#!/usr/bin/env python3
"""Synthesize readable leg strides for elder_woman (stronger side-view stride)."""

from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[1]
NPC = ROOT / "assets" / "sprites" / "npc" / "elder_woman"
ARCH = ROOT / "assets" / "sprites" / "npc" / "_misnamed_archive" / "pre_legfix_elder_woman"
DIRS = ("down", "left", "right", "up")
SHOE = (92, 58, 38, 255)
SHOE_DK = (62, 38, 24, 255)
OUTLINE = (28, 16, 12, 255)


def ensure_archive() -> None:
	ARCH.mkdir(parents=True, exist_ok=True)
	if not any(ARCH.glob("walk_*.png")):
		for f in NPC.glob("walk_*.png"):
			shutil.copy2(f, ARCH / f.name)


def clear_ground_band(im: Image.Image) -> Image.Image:
	out = im.copy()
	px = out.load()
	w, h = out.size
	for y in range(h - 12, h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a < 20:
				continue
			# Remove prior shoes / shadow / hem crumbs in plant band.
			if y >= h - 9 and r < 140 and g < 110 and b < 100:
				px[x, y] = (0, 0, 0, 0)
			elif y >= h - 6 and a < 120:
				px[x, y] = (0, 0, 0, 0)
	return out


def stamp_leg(
	px,
	w: int,
	h: int,
	ankle_x: int,
	ankle_y: int,
	toe_dx: int,
	lift: int,
) -> None:
	"""Draw a short shin + shoe so strides read even under a skirt."""
	# Shin column under skirt hem.
	for t in range(lift, 6):
		x, y = ankle_x, ankle_y - 6 + t
		if 0 <= x < w and 0 <= y < h:
			px[x, y] = OUTLINE if t < 2 else (120, 95, 145, 255)
			if 0 <= x + 1 < w:
				px[x + 1, y] = (130, 105, 155, 230)
	# Shoe plant / lift.
	sy = ankle_y - lift
	for dx, dy in [(-1, 0), (0, 0), (1, 0), (2, 0), (0, -1), (1, -1), (toe_dx, 0)]:
		x, y = ankle_x + dx, sy + dy
		if 0 <= x < w and 0 <= y < h:
			px[x, y] = SHOE if dy == 0 else SHOE_DK


def stride_params(direction: str, frame: int) -> tuple:
	# Returns (back_dx, front_dx, back_lift, front_lift, toe_sign)
	phase = frame % 4
	if direction == "left":
		# Facing left: negative X is forward.
		table = [
			(4, -5, 0, 2, -1),
			(2, -7, 1, 0, -1),
			(5, -4, 0, 2, -1),
			(1, -8, 2, 0, -1),
		]
	elif direction == "right":
		table = [
			(-4, 5, 0, 2, 1),
			(-2, 7, 1, 0, 1),
			(-5, 4, 0, 2, 1),
			(-1, 8, 2, 0, 1),
		]
	elif direction == "down":
		table = [
			(-5, 5, 0, 1, 0),
			(-6, 4, 1, 0, 0),
			(-4, 6, 0, 1, 0),
			(-6, 5, 1, 0, 0),
		]
	else:  # up
		table = [
			(-4, 4, 0, 1, 0),
			(-5, 3, 1, 0, 0),
			(-3, 5, 0, 1, 0),
			(-5, 4, 1, 0, 0),
		]
	return table[phase]


def hem_sway(im: Image.Image, frame: int, direction: str) -> Image.Image:
	out = im.copy()
	px = out.load()
	w, h = out.size
	shift = (-2, 0, 2, 0)[frame % 4]
	if direction == "left":
		shift = -2 if frame % 2 else 0
	elif direction == "right":
		shift = 2 if frame % 2 else 0
	buf = {}
	for y in range(h - 18, h - 9):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a < 20 or (r > 200 and g > 200 and b > 200):
				continue
			if b >= g and g < r + 40:
				buf[(x, y)] = (r, g, b, a)
				px[x, y] = (0, 0, 0, 0)
	for (x, y), col in buf.items():
		nx = min(w - 1, max(0, x + shift))
		px[nx, y] = col
	return out


def rebuild(src: Path, direction: str, frame: int) -> Image.Image:
	im = Image.open(src).convert("RGBA")
	im = clear_ground_band(im)
	im = hem_sway(im, frame, direction)
	px = im.load()
	w, h = im.size
	bb = im.getchannel("A").getbbox()
	if bb is None:
		return im
	cx = (bb[0] + bb[2]) // 2
	ankle_y = h - 2
	back_dx, front_dx, back_lift, front_lift, toe = stride_params(direction, frame)
	stamp_leg(px, w, h, cx + back_dx, ankle_y, toe, back_lift)
	stamp_leg(px, w, h, cx + front_dx, ankle_y, toe, front_lift)
	return im


def min_lower_motion(paths: list[Path]) -> int:
	loaded = [Image.open(p).convert("RGBA") for p in paths]
	h, w = loaded[0].height, loaded[0].width
	mid = h // 2
	vals = []
	for i, cur in enumerate(loaded):
		nxt = loaded[(i + 1) % len(loaded)]
		diff = ImageChops.difference(cur, nxt)
		px = diff.load()
		vals.append(sum(1 for y in range(mid, h) for x in range(w) if px[x, y] != (0, 0, 0, 0)))
	return min(vals)


def main() -> None:
	ensure_archive()
	for d in DIRS:
		for i in range(4):
			base = ARCH / f"walk_{d}_{i}.png"
			out = rebuild(base, d, i)
			out.save(NPC / f"walk_{d}_{i}.png")
	fails = []
	for d in DIRS:
		paths = [NPC / f"walk_{d}_{i}.png" for i in range(4)]
		m = min_lower_motion(paths)
		if m < 220:
			fails.append(f"{d}: lower_motion={m} < 220")
	meta_path = NPC / "meta.json"
	meta = json.loads(meta_path.read_text(encoding="utf-8")) if meta_path.exists() else {"id": "elder_woman"}
	meta["leg_fix"] = "v2 shin+shoe stride plants, stronger side step"
	meta_path.write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
	if fails:
		raise SystemExit("FAIL fix_elder_woman_legs:\n- " + "\n- ".join(fails))
	print("GREEN fix_elder_woman_legs v2 (readable shin/shoe stride)")


if __name__ == "__main__":
	main()
