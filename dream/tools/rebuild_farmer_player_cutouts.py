#!/usr/bin/env python3
"""Rebuild farmer/player walk packs from gen_npc_farmer_v5 with real plate cutout + full-height normalize.

The prior edge-white key missed light-gray checkerboard plates (RGB ~210–230), so in-game
sprites looked like tiny characters stamped on white cards. This tool:

1. Keys plate bg (near-white + low-chroma light gray) from the raw sheet
2. Slices 4×8 walk islands
3. Scales each silhouette to fill 48×56 (feet on y=55)
4. Rebuilds production farmer + player + work_poses
"""

from __future__ import annotations

import json
import shutil
import uuid
from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "assets" / "raw" / "gen_npc_farmer_v5.png"
NPC = ROOT / "assets" / "sprites" / "npc"
ARCH = NPC / "_misnamed_archive" / "pre_plate_rebuild_farmer"
TARGET_W, TARGET_H = 48, 56
DIRS = ("down", "left", "right", "up")
IMPORT_TMPL = (NPC / "merchant" / "walk_down_0.png.import").read_text(encoding="utf-8")


def is_plate(r: int, g: int, b: int, a: int) -> bool:
	if a < 12:
		return True
	if r >= 238 and g >= 238 and b >= 238:
		return True
	# Checkerboard / soft gray plate (not character ink).
	if abs(r - g) <= 10 and abs(g - b) <= 10 and min(r, g, b) >= 175:
		return True
	return False


def key_plate(im: Image.Image) -> Image.Image:
	out = im.convert("RGBA")
	w, h = out.size
	px = out.load()
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if is_plate(r, g, b, a):
				px[x, y] = (0, 0, 0, 0)
	return out


def find_islands(im: Image.Image, step: int = 3, min_cells: int = 40):
	w, h = im.size
	px = im.load()
	visited = [[False] * w for _ in range(h)]
	boxes: list[dict] = []

	def fg(x: int, y: int) -> bool:
		r, g, b, a = px[x, y]
		return not is_plate(r, g, b, a)

	for y0 in range(0, h, step):
		for x0 in range(0, w, step):
			if visited[y0][x0] or not fg(x0, y0):
				visited[y0][x0] = True
				continue
			q: deque[tuple[int, int]] = deque([(x0, y0)])
			visited[y0][x0] = True
			minx = maxx = x0
			miny = maxy = y0
			count = 0
			while q:
				x, y = q.popleft()
				count += 1
				minx = min(minx, x)
				maxx = max(maxx, x)
				miny = min(miny, y)
				maxy = max(maxy, y)
				for nx, ny in ((x - step, y), (x + step, y), (x, y - step), (x, y + step)):
					if nx < 0 or ny < 0 or nx >= w or ny >= h or visited[ny][nx]:
						continue
					if fg(nx, ny):
						visited[ny][nx] = True
						q.append((nx, ny))
					else:
						visited[ny][nx] = True
			bw = maxx - minx + 1
			bh = maxy - miny + 1
			if count >= min_cells and 40 <= bw <= 280 and 80 <= bh <= 320:
				boxes.append(
					{
						"box": (minx, miny, maxx + 1, maxy + 1),
						"w": bw,
						"h": bh,
						"cx": (minx + maxx) / 2,
						"cy": (miny + maxy) / 2,
					}
				)
	return boxes


def group_rows(boxes: list[dict], y_tol: float = 50.0) -> list[list[dict]]:
	rows: list[list[dict]] = []
	for b in sorted(boxes, key=lambda x: x["cy"]):
		placed = False
		for row in rows:
			if abs(row[0]["cy"] - b["cy"]) <= y_tol:
				row.append(b)
				placed = True
				break
		if not placed:
			rows.append([b])
	for row in rows:
		row.sort(key=lambda x: x["cx"])
	return rows


def normalize_frame(crop: Image.Image) -> Image.Image:
	keyed = key_plate(crop)
	bb = keyed.getchannel("A").getbbox()
	if bb is None:
		return Image.new("RGBA", (TARGET_W, TARGET_H), (0, 0, 0, 0))
	sil = keyed.crop(bb)
	# Scale so silhouette height nearly fills the canvas (match elder_woman fill).
	scale = (TARGET_H - 2) / float(sil.height)
	nw = max(1, int(round(sil.width * scale)))
	nh = max(1, int(round(sil.height * scale)))
	# Cap width so wide hats still fit.
	if nw > TARGET_W - 2:
		scale = (TARGET_W - 2) / float(sil.width)
		nw = max(1, int(round(sil.width * scale)))
		nh = max(1, int(round(sil.height * scale)))
	scaled = sil.resize((nw, nh), Image.Resampling.NEAREST)
	canvas = Image.new("RGBA", (TARGET_W, TARGET_H), (0, 0, 0, 0))
	x = (TARGET_W - nw) // 2
	y = TARGET_H - nh  # feet on bottom
	canvas.alpha_composite(scaled, (x, y))
	return canvas


def write_import(folder: Path, name: str, pack: str) -> None:
	text = IMPORT_TMPL.replace("npc/merchant/", f"npc/{pack}/").replace("walk_down_0.png", name)
	uid = "uid://r" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(folder / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def save_pack(frames: dict[str, list[Image.Image]], pack: str, title: str, source: str) -> None:
	out = NPC / pack
	out.mkdir(parents=True, exist_ok=True)
	for old in out.glob("walk_*.png"):
		old.unlink()
	for old in out.glob("walk_*.png.import"):
		old.unlink()
	meta_frames: dict[str, list[str]] = {}
	for d in DIRS:
		meta_frames[d] = []
		for i, im in enumerate(frames[d]):
			name = f"walk_{d}_{i}.png"
			im.save(out / name)
			write_import(out, name, pack)
			meta_frames[d].append(name)
	(out / "meta.json").write_text(
		json.dumps(
			{
				"id": pack,
				"title": title,
				"source": source,
				"height_px": TARGET_H,
				"canvas_width_px": TARGET_W,
				"columns": 8,
				"dirs": list(DIRS),
				"frames": meta_frames,
				"filter": "NEAREST",
			},
			ensure_ascii=False,
			indent=2,
		)
		+ "\n",
		encoding="utf-8",
	)


def recolor_hero(im: Image.Image) -> Image.Image:
	out = im.copy()
	px = out.load()
	w, h = out.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			if r > 150 and g > 110 and b > 90 and r >= g >= b:
				continue
			if g < 120 and r > 60:
				px[x, y] = (
					min(255, int(r * 0.45 + 40)),
					min(255, int(g * 0.55 + 55)),
					min(255, int(b * 0.65 + 95)),
					a,
				)
			elif g >= 120 and b < 110:
				px[x, y] = (
					min(255, int(r * 0.35 + 35)),
					min(255, int(g * 0.45 + 70)),
					min(255, int(b * 0.55 + 120)),
					a,
				)
	return out


def slice_raw() -> dict[str, list[Image.Image]]:
	if not RAW.exists():
		raise SystemExit(f"missing {RAW}")
	sheet = Image.open(RAW).convert("RGBA")
	boxes = find_islands(sheet)
	rows = group_rows(boxes)
	if len(rows) < 4:
		raise SystemExit(f"expected ≥4 walk rows, got {len(rows)}")
	rows = rows[:4]
	for i, row in enumerate(rows):
		if len(row) < 8:
			raise SystemExit(f"row {i} needs 8 frames, got {len(row)}")
		rows[i] = row[:8]
	out: dict[str, list[Image.Image]] = {d: [] for d in DIRS}
	for di, row in enumerate(rows):
		d = DIRS[di]
		for cell in row:
			crop = sheet.crop(cell["box"])
			out[d].append(normalize_frame(crop))
	return out


def plate_stats(path: Path) -> tuple[int, int]:
	im = Image.open(path).convert("RGBA")
	px = im.load()
	w, h = im.size
	plate = 0
	opaque = 0
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a < 12:
				continue
			opaque += 1
			if is_plate(r, g, b, a):
				plate += 1
	return plate, opaque


def main() -> None:
	frames = slice_raw()
	# Archive previous farmer production pack.
	src = NPC / "farmer"
	ARCH.mkdir(parents=True, exist_ok=True)
	if src.exists():
		if ARCH.exists():
			shutil.rmtree(ARCH)
		shutil.copytree(src, ARCH)

	save_pack(frames, "farmer", "农夫", "gen_npc_farmer_v5 plate-keyed + height-normalized")
	save_pack(frames, "farmer_v5", "农夫", "gen_npc_farmer_v5 plate-keyed + height-normalized")

	hero = {d: [recolor_hero(im) for im in frames[d]] for d in DIRS}
	save_pack(hero, "player", "主角", "farmer_v5 plate-keyed recolor (hero palette)")

	# Rebuild work poses from cleaned farmer (same script contract).
	from paint_work_poses import main as paint_work_main

	paint_work_main()

	# Verify no plate leftovers on production packs.
	bad: list[str] = []
	for pack in ("farmer", "player"):
		for f in sorted((NPC / pack).glob("walk_*.png")):
			plate, opaque = plate_stats(f)
			bb = Image.open(f).convert("RGBA").getchannel("A").getbbox()
			if plate > 8:
				bad.append(f"{pack}/{f.name}: plate={plate}")
			if bb is None or bb[1] > 6:
				bad.append(f"{pack}/{f.name}: top padding too large bbox={bb}")
			# Silhouette should occupy most of the canvas height.
			if bb is not None and (bb[3] - bb[1]) < 46:
				bad.append(f"{pack}/{f.name}: silhouette too short h={bb[3]-bb[1]}")
	if bad:
		raise SystemExit("FAIL rebuild_farmer_player_cutouts:\n- " + "\n- ".join(bad))
	print("GREEN rebuild_farmer_player_cutouts (farmer+player 8×4, work_poses rebuilt, plate cleared)")


if __name__ == "__main__":
	main()
