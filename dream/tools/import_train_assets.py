#!/usr/bin/env python3
"""Import train loco/coach/extras into gameplay props."""
from __future__ import annotations

import hashlib
import re
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
	uid = "uid://t" + uuid.uuid4().hex[:13]
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
	kill = (
		((mx >= 210) & (chroma <= 18))
		| ((mx <= 12) & (chroma <= 8))
		| ((mx >= 200) & (mx <= 245) & (chroma <= 12))
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
	print(f"wrote {folder.name}/{name} {im.size}")


def split_horizontal(sheet: Image.Image, names: list[tuple[str, Path, tuple[int, int]]]) -> None:
	w, h = sheet.size
	n = len(names)
	cw = w // n
	for i, (name, folder, mx) in enumerate(names):
		cell = trim(sheet.crop((i * cw, 0, (i + 1) * cw if i < n - 1 else w, h)), 2)
		if cell.getbbox() is None:
			print(f"SKIP {name}")
			continue
		cell = downscale_max(cell, mx[0], mx[1])
		save(cell, folder, name)


def main() -> None:
	pack = Image.fromarray(key_plate(np.array(Image.open(SRC / "train_loco_coach_pack_v1.png").convert("RGBA"))), "RGBA")
	# Loco left / coach right
	w, h = pack.size
	loco = trim(pack.crop((0, 0, int(w * 0.52), h)), 2)
	coach = trim(pack.crop((int(w * 0.48), 0, w, h)), 2)
	save(downscale_max(loco, 160, 90), PROPS, "train_loco_00.png")
	save(downscale_max(coach, 180, 90), PROPS, "train_coach_00.png")

	ex = Image.fromarray(key_plate(np.array(Image.open(SRC / "train_extras_pack_v1.png").convert("RGBA"))), "RGBA")
	ew, eh = ex.size
	cells = [
		(0.00, 0.00, 0.33, 0.50, "train_steam_00.png", FX, (72, 64)),
		(0.33, 0.00, 0.66, 0.50, "train_water_tower_00.png", PROPS, (72, 110)),
		(0.66, 0.00, 1.00, 0.50, "train_timetable_board_00.png", PROPS, (64, 80)),
		(0.00, 0.50, 0.33, 1.00, "train_ticket_00.png", PROPS, (48, 32)),
		(0.33, 0.50, 0.66, 1.00, "train_window_scenery_00.png", FX, (220, 64)),
		(0.66, 0.50, 1.00, 1.00, "train_buffer_00.png", PROPS, (64, 48)),
	]
	for x0f, y0f, x1f, y1f, name, folder, mx in cells:
		piece = trim(ex.crop((int(ew * x0f), int(eh * y0f), int(ew * x1f), int(eh * y1f))), 2)
		if piece.getbbox() is None:
			print(f"SKIP {name}")
			continue
		save(downscale_max(piece, mx[0], mx[1]), folder, name)
	print("DONE train asset import")


if __name__ == "__main__":
	main()
