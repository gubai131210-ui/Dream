#!/usr/bin/env python3
"""Import redrawn cascade cliff + water frames + scenic props into gameplay assets."""
from __future__ import annotations

import uuid
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
FX = ROOT / "assets" / "sprites" / "fx"
SRC = Path(r"C:\Users\孤白赟悫\.cursor\projects\d-GoDot-Projects-Dream\assets")
TMPL = (PROPS / "waterfall_tall_00.png.import").read_text(encoding="utf-8")
NEAREST = Image.Resampling.NEAREST


def write_import(folder: Path, name: str) -> None:
	old = "waterfall_tall_00.png"
	text = TMPL.replace(old, name).replace(
		"res://assets/sprites/props/",
		f"res://assets/sprites/{folder.name}/",
	)
	# Keep props path if folder is props; for fx adjust both source and dest.
	if folder.name == "fx":
		text = TMPL.replace(old, name)
		text = text.replace("res://assets/sprites/props/", "res://assets/sprites/fx/")
		text = text.replace(
			f".godot/imported/{old}",
			f".godot/imported/{name}",
		)
	uid = "uid://c" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		elif ".godot/imported/" in line and old in line:
			lines.append(line.replace(old, name))
		else:
			lines.append(line)
	(folder / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def key_plate(rgba: np.ndarray) -> np.ndarray:
	"""Remove checkerboard / near-white / near-black plates."""
	r, g, b = rgba[:, :, 0].astype(np.int16), rgba[:, :, 1].astype(np.int16), rgba[:, :, 2].astype(np.int16)
	mx = np.maximum(np.maximum(r, g), b)
	mn = np.minimum(np.minimum(r, g), b)
	chroma = mx - mn
	# Light gray / white checker (low chroma, high luminance)
	light = (mx >= 210) & (chroma <= 18)
	# Near-black void
	dark = (mx <= 12) & (chroma <= 8)
	# Mid gray checker cells (~220-230)
	mid_checker = (mx >= 200) & (mx <= 245) & (chroma <= 12)
	kill = light | dark | mid_checker
	out = rgba.copy()
	out[kill, 3] = 0
	return out


def trim(im: Image.Image, pad: int = 2) -> Image.Image:
	bbox = im.getbbox()
	if bbox is None:
		return im
	x0, y0, x1, y1 = bbox
	x0 = max(0, x0 - pad)
	y0 = max(0, y0 - pad)
	x1 = min(im.width, x1 + pad)
	y1 = min(im.height, y1 + pad)
	return im.crop((x0, y0, x1, y1))


def downscale_max(im: Image.Image, max_w: int, max_h: int) -> Image.Image:
	w, h = im.size
	scale = min(max_w / w, max_h / h, 1.0)
	nw, nh = max(1, int(round(w * scale))), max(1, int(round(h * scale)))
	if (nw, nh) == (w, h):
		return im
	return im.resize((nw, nh), NEAREST)


def save_prop(im: Image.Image, folder: Path, name: str) -> None:
	folder.mkdir(parents=True, exist_ok=True)
	path = folder / name
	im.save(path)
	write_import(folder, name)
	print(f"wrote {path.relative_to(ROOT)} {im.size}")


def process_cliff() -> None:
	src = Image.open(SRC / "cascade_cliff_mouth_v1.png").convert("RGBA")
	arr = key_plate(np.array(src))
	im = trim(Image.fromarray(arr, "RGBA"))
	# Gameplay landmark size — tall silhouette, readable in 1280 view.
	im = downscale_max(im, 220, 300)
	save_prop(im, PROPS, "cascade_cliff_mouth_v1.png")


def process_water() -> None:
	src = Image.open(SRC / "cascade_water_anim_sheet_v1.png").convert("RGBA")
	arr = key_plate(np.array(src))
	# Also kill pure white seams between frames
	r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
	white = (r >= 248) & (g >= 248) & (b >= 248)
	arr[white, 3] = 0
	sheet = Image.fromarray(arr, "RGBA")
	# Equal 6 columns
	cols = 6
	cw = sheet.width // cols
	crops: list[Image.Image] = []
	max_w = max_h = 0
	for i in range(cols):
		cell = sheet.crop((i * cw, 0, (i + 1) * cw if i < cols - 1 else sheet.width, sheet.height))
		cell = trim(cell, 1)
		if cell.getbbox() is None:
			continue
		crops.append(cell)
		max_w = max(max_w, cell.width)
		max_h = max(max_h, cell.height)
	if len(crops) < 4:
		raise SystemExit(f"water frames too few: {len(crops)}")
	print(f"water frames={len(crops)} canvas=({max_w},{max_h})")
	for i, cropped in enumerate(crops):
		canvas = Image.new("RGBA", (max_w, max_h), (0, 0, 0, 0))
		ox = (max_w - cropped.width) // 2
		oy = max_h - cropped.height
		canvas.paste(cropped, (ox, oy), cropped)
		# Slightly shrink for pixel readability if huge
		canvas = downscale_max(canvas, 96, 220)
		name = f"waterfall_water_{i:02d}.png"
		save_prop(canvas, PROPS, name)


def process_extras() -> None:
	src = Image.open(SRC / "cascade_extra_props_v1.png").convert("RGBA")
	arr = key_plate(np.array(src))
	sheet = Image.fromarray(arr, "RGBA")
	# Generated pack is 2 rows × 3 columns with clear gutters.
	cells = [
		(0.00, 0.00, 0.33, 0.50, "cascade_vines_00.png", PROPS, (72, 96)),
		(0.33, 0.00, 0.66, 0.50, "cascade_fern_00.png", PROPS, (64, 56)),
		(0.66, 0.00, 1.00, 0.50, "cascade_moss_rock_00.png", PROPS, (72, 64)),
		(0.00, 0.50, 0.33, 1.00, "cascade_bench_00.png", PROPS, (80, 56)),
		(0.33, 0.50, 0.66, 1.00, "cascade_mist_00.png", FX, (96, 120)),
		(0.66, 0.50, 1.00, 1.00, "cascade_splash_ring_00.png", FX, (96, 72)),
	]
	w, h = sheet.size
	for x0f, y0f, x1f, y1f, name, folder, max_size in cells:
		cell = sheet.crop((int(w * x0f), int(h * y0f), int(w * x1f), int(h * y1f)))
		piece = trim(cell, 2)
		if piece.getbbox() is None:
			print(f"SKIP empty {name}")
			continue
		piece = downscale_max(piece, max_size[0], max_size[1])
		save_prop(piece, folder, name)


def main() -> None:
	process_cliff()
	process_water()
	process_extras()
	print("DONE cascade asset import")


if __name__ == "__main__":
	main()
