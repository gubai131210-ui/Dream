#!/usr/bin/env python3
"""Import wooden-bridge waterfall (木桥落水) assets."""
from __future__ import annotations

import hashlib
import re
import uuid
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
FX = ROOT / "assets" / "sprites" / "fx"
SRC = Path(r"C:\Users\孤白赟悫\.cursor\projects\d-GoDot-Projects-Dream\assets")
TMPL = (PROPS / "waterfall_tall_00.png.import").read_text(encoding="utf-8")
NEAREST = Image.Resampling.NEAREST


def write_import(folder: Path, name: str) -> None:
	uid = "uid://b" + uuid.uuid4().hex[:13]
	h = hashlib.md5((folder.name + "/" + name).encode()).hexdigest()
	ctex = f"{name}-{h}.ctex"
	text = TMPL.replace("waterfall_tall_00.png", name)
	text = text.replace("res://assets/sprites/props/", f"res://assets/sprites/{folder.name}/")
	text = re.sub(r"waterfall_tall_00\.png-[a-f0-9]+\.ctex", ctex, text)
	text = re.sub(r'uid://[^"\n]+', uid, text, count=1)
	text = re.sub(r"\.godot/imported/[^\"]+", f".godot/imported/{ctex}", text)
	(folder / f"{name}.import").write_text(text, encoding="utf-8")


def key_plate(rgba: np.ndarray) -> np.ndarray:
	r, g, b = rgba[:, :, 0].astype(np.int16), rgba[:, :, 1].astype(np.int16), rgba[:, :, 2].astype(np.int16)
	mx = np.maximum(np.maximum(r, g), b)
	mn = np.minimum(np.minimum(r, g), b)
	chroma = mx - mn
	kill = ((mx >= 210) & (chroma <= 18)) | ((mx <= 12) & (chroma <= 8)) | ((mx >= 200) & (mx <= 245) & (chroma <= 12))
	out = rgba.copy()
	out[kill, 3] = 0
	# Pure white plate
	out[(r >= 248) & (g >= 248) & (b >= 248), 3] = 0
	return out


def trim(im: Image.Image, pad: int = 2) -> Image.Image:
	bbox = im.getbbox()
	if bbox is None:
		return im
	x0, y0, x1, y1 = bbox
	return im.crop((max(0, x0 - pad), max(0, y0 - pad), min(im.width, x1 + pad), min(im.height, y1 + pad)))


def downscale_max(im: Image.Image, max_w: int, max_h: int) -> Image.Image:
	w, h = im.size
	scale = min(max_w / w, max_h / h, 1.0)
	nw, nh = max(1, int(round(w * scale))), max(1, int(round(h * scale)))
	return im if (nw, nh) == (w, h) else im.resize((nw, nh), NEAREST)


def save(im: Image.Image, folder: Path, name: str) -> None:
	folder.mkdir(parents=True, exist_ok=True)
	im.save(folder / name)
	write_import(folder, name)
	print(f"wrote {folder.name}/{name} {im.size}")


def process_deck() -> None:
	src = Image.open(SRC / "bridge_fall_deck_v1.png").convert("RGBA")
	im = trim(Image.fromarray(key_plate(np.array(src)), "RGBA"))
	im = downscale_max(im, 240, 140)
	save(im, PROPS, "bridge_fall_deck_v1.png")


def process_water() -> None:
	src = Image.open(SRC / "bridge_fall_water_sheet_v1.png").convert("RGBA")
	arr = key_plate(np.array(src))
	sheet = Image.fromarray(arr, "RGBA")
	cols = 6
	cw = sheet.width // cols
	crops: list[Image.Image] = []
	max_w = max_h = 0
	for i in range(cols):
		cell = trim(sheet.crop((i * cw, 0, (i + 1) * cw if i < cols - 1 else sheet.width, sheet.height)), 1)
		if cell.getbbox() is None:
			continue
		a = np.array(cell)
		filled = ndimage.binary_fill_holes(a[:, :, 3] > 0)
		hole = filled & (a[:, :, 3] == 0)
		if hole.any():
			cols_rgb = a[a[:, :, 3] > 0][:, :3].mean(axis=0).astype(np.uint8)
			a[hole, 0] = cols_rgb[0]
			a[hole, 1] = min(255, int(cols_rgb[1]) + 15)
			a[hole, 2] = min(255, int(cols_rgb[2]) + 20)
			a[hole, 3] = 220
			cell = Image.fromarray(a, "RGBA")
		# Widen for bridge-span readability (sheet frames are very skinny).
		cell = cell.resize((max(64, int(cell.width * 2.4)), cell.height), NEAREST)
		crops.append(cell)
		max_w = max(max_w, cell.width)
		max_h = max(max_h, cell.height)
	if len(crops) < 4:
		raise SystemExit(f"bridge water frames too few: {len(crops)}")
	for i, cropped in enumerate(crops):
		canvas = Image.new("RGBA", (max_w, max_h), (0, 0, 0, 0))
		canvas.paste(cropped, ((max_w - cropped.width) // 2, max_h - cropped.height), cropped)
		if canvas.height > 170:
			nw = max(56, int(canvas.width * 170 / canvas.height))
			canvas = canvas.resize((nw, 170), NEAREST)
		save(canvas, PROPS, f"waterfall_water_{i:02d}.png")


def process_extras() -> None:
	src = Image.open(SRC / "bridge_fall_extras_v1.png").convert("RGBA")
	sheet = Image.fromarray(key_plate(np.array(src)), "RGBA")
	w, h = sheet.size
	cells = [
		(0.00, 0.00, 0.33, 0.50, "bridge_fall_abutment_00.png", PROPS, (96, 80)),
		(0.33, 0.00, 0.66, 0.50, "bridge_fall_moss_00.png", PROPS, (100, 72)),
		(0.66, 0.00, 1.00, 0.50, "bridge_fall_sign_00.png", PROPS, (48, 72)),
		(0.00, 0.50, 0.33, 1.00, "bridge_fall_mist_00.png", FX, (96, 80)),
		(0.33, 0.50, 0.66, 1.00, "bridge_fall_splash_00.png", FX, (96, 72)),
		(0.66, 0.50, 1.00, 1.00, "bridge_fall_reed_00.png", PROPS, (64, 72)),
	]
	for x0f, y0f, x1f, y1f, name, folder, max_size in cells:
		piece = trim(sheet.crop((int(w * x0f), int(h * y0f), int(w * x1f), int(h * y1f))), 2)
		if piece.getbbox() is None:
			print(f"SKIP {name}")
			continue
		piece = downscale_max(piece, max_size[0], max_size[1])
		save(piece, folder, name)


def main() -> None:
	process_deck()
	process_water()
	process_extras()
	print("DONE bridge-fall import")


if __name__ == "__main__":
	main()
