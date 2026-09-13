#!/usr/bin/env python3
"""Import A11-matched train, seamless tracks, and coach interior props."""
from __future__ import annotations

import hashlib
import re
import uuid
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
INTERIOR = ROOT / "assets" / "sprites" / "interior" / "props"
SRC = Path(r"C:\Users\孤白赟悫\.cursor\projects\d-GoDot-Projects-Dream\assets")
TMPL = (PROPS / "waterfall_tall_00.png.import").read_text(encoding="utf-8")
NEAREST = Image.Resampling.NEAREST


def write_import(folder: Path, name: str) -> None:
	uid = "uid://r" + uuid.uuid4().hex[:13]
	h = hashlib.md5((folder.as_posix() + "/" + name).encode()).hexdigest()
	ctex = f"{name}-{h}.ctex"
	# Pick a template near the destination folder if possible.
	tmpl_path = folder / "train_seat_row_00.png.import"
	if not tmpl_path.is_file():
		tmpl_path = PROPS / "waterfall_tall_00.png.import"
	text = tmpl_path.read_text(encoding="utf-8") if tmpl_path.is_file() else TMPL
	# Replace any existing basename in source_file lines generically.
	text = re.sub(r'(source_file="res://assets/sprites/)[^"]+(")', rf'\1{folder.relative_to(ROOT / "assets/sprites").as_posix()}/{name}\2', text)
	if 'source_file="' not in text:
		text = TMPL.replace("waterfall_tall_00.png", name)
		text = text.replace("res://assets/sprites/props/", f'res://assets/sprites/{folder.relative_to(ROOT / "assets/sprites").as_posix()}/')
	text = re.sub(r'uid://[^"\n]+', uid, text, count=1)
	text = re.sub(r"\.godot/imported/[^\"]+", f".godot/imported/{ctex}", text)
	# Also fix path= line under remap
	text = re.sub(r'(path="res://\.godot/imported/)[^"]+(\.ctex")', rf"\1{ctex}\2", text)
	(folder / f"{name}.import").write_text(text, encoding="utf-8")


def key_plate(rgba: np.ndarray) -> np.ndarray:
	r, g, b = rgba[:, :, 0].astype(np.int16), rgba[:, :, 1].astype(np.int16), rgba[:, :, 2].astype(np.int16)
	mx = np.maximum(np.maximum(r, g), b)
	mn = np.minimum(np.minimum(r, g), b)
	chroma = mx - mn
	kill = (
		((mx >= 210) & (chroma <= 18))
		| ((mx <= 14) & (chroma <= 10))
		| ((mx >= 200) & (mx <= 245) & (chroma <= 14))
		| ((r >= 248) & (g >= 248) & (b >= 248))
	)
	out = rgba.copy()
	out[kill, 3] = 0
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
	print(f"wrote {folder.relative_to(ROOT)}/{name} {im.size}")


def process_train() -> None:
	sheet = Image.fromarray(key_plate(np.array(Image.open(SRC / "train_from_a11_v2.png").convert("RGBA"))), "RGBA")
	w, h = sheet.size
	# Loco left ~45%, coach right
	loco = trim(sheet.crop((0, 0, int(w * 0.48), h)), 2)
	coach = trim(sheet.crop((int(w * 0.45), 0, w, h)), 2)
	save(downscale_max(loco, 180, 100), PROPS, "train_loco_00.png")
	save(downscale_max(coach, 200, 100), PROPS, "train_coach_00.png")
	# Combined consist for docking silhouette
	combo = trim(sheet, 2)
	save(downscale_max(combo, 320, 110), PROPS, "train_consist_00.png")


def process_tracks() -> None:
	sheet = Image.fromarray(key_plate(np.array(Image.open(SRC / "track_seamless_pack_v2.png").convert("RGBA"))), "RGBA")
	w, h = sheet.size
	# Top big strip = seamless track
	band = trim(sheet.crop((0, 0, w, int(h * 0.55))), 2)
	# Prefer wide seamless piece
	band = downscale_max(band, 256, 48)
	save(band, PROPS, "track_band_seamless_00.png")
	# Bottom-left sleeper-ish, bottom-right rail stub — split lower half into 2
	low = sheet.crop((0, int(h * 0.5), w, h))
	lw, lh = low.size
	sleeper = trim(low.crop((0, 0, int(lw * 0.45), lh)), 2)
	rail = trim(low.crop((int(lw * 0.45), 0, lw, lh)), 2)
	save(downscale_max(sleeper, 48, 28), PROPS, "track_sleeper_00.png")
	save(downscale_max(rail, 96, 24), PROPS, "track_rail_00.png")


def process_interior() -> None:
	sheet = Image.fromarray(key_plate(np.array(Image.open(SRC / "train_interior_props_v2.png").convert("RGBA"))), "RGBA")
	w, h = sheet.size
	cells = [
		(0.00, 0.00, 0.33, 0.50, "train_seat_row_00.png", (90, 70)),
		(0.33, 0.00, 0.72, 0.50, "train_window_wall_00.png", (160, 72)),
		(0.72, 0.00, 1.00, 0.55, "train_luggage_rack_00.png", (100, 56)),
		(0.00, 0.50, 0.40, 1.00, "train_aisle_runner_00.png", (120, 36)),
		(0.40, 0.50, 0.70, 1.00, "train_vestibule_00.png", (72, 90)),
		(0.70, 0.50, 1.00, 1.00, "train_brass_lamp_00.png", (40, 48)),
	]
	for x0f, y0f, x1f, y1f, name, mx in cells:
		piece = trim(sheet.crop((int(w * x0f), int(h * y0f), int(w * x1f), int(h * y1f))), 2)
		if piece.getbbox() is None:
			print("SKIP", name)
			continue
		save(downscale_max(piece, mx[0], mx[1]), INTERIOR, name)


def main() -> None:
	process_train()
	process_tracks()
	process_interior()
	print("DONE train/track/interior v2 import")


if __name__ == "__main__":
	main()
