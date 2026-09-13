#!/usr/bin/env python3
"""Slice coach prop family sheet into interior props (painting-asset-craft)."""
from __future__ import annotations

import hashlib
import re
import uuid
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
INTER = ROOT / "assets/sprites/interior/props"
SRC = Path(
	r"C:\Users\孤白赟悫\.cursor\projects\d-GoDot-Projects-Dream\assets\train_coach_prop_family_v3.png"
)
TMPL = (ROOT / "assets/sprites/props/waterfall_tall_00.png.import").read_text(encoding="utf-8")
NEAREST = Image.Resampling.NEAREST

# Grid cells as fractions of the sheet (row-major, 3 rows × flexible cols).
# Tuned to the v3 sheet layout description.
CELLS = [
	# row 0
	(0.00, 0.00, 0.34, 0.36, "train_seat_row_00.png", (96, 72)),
	(0.34, 0.00, 0.70, 0.36, "train_window_wall_00.png", (140, 72)),
	(0.70, 0.00, 1.00, 0.36, "train_luggage_rack_00.png", (100, 56)),
	# row 1
	(0.00, 0.36, 0.22, 0.68, "train_passenger_a_00.png", (56, 64)),
	(0.22, 0.36, 0.44, 0.68, "train_passenger_b_00.png", (56, 64)),
	(0.44, 0.36, 0.66, 0.68, "train_passenger_c_00.png", (52, 60)),
	(0.66, 0.36, 0.82, 0.68, "train_brass_lamp_00.png", (40, 48)),
	# row 2
	(0.00, 0.68, 0.28, 1.00, "train_aisle_runner_00.png", (120, 40)),
	(0.28, 0.68, 0.48, 1.00, "train_vestibule_00.png", (72, 80)),
	(0.48, 0.68, 0.70, 1.00, "train_suitcase_00.png", (56, 48)),
	(0.70, 0.68, 1.00, 1.00, "train_mail_pouch_00.png", (48, 48)),
]


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
	if scale >= 1.0:
		return im
	return im.resize((max(1, int(round(w * scale))), max(1, int(round(h * scale)))), NEAREST)


def write_import(name: str) -> None:
	uid = "uid://r" + uuid.uuid4().hex[:13]
	h = hashlib.md5(("interior/props/" + name).encode()).hexdigest()
	ctex = f"{name}-{h}.ctex"
	text = TMPL.replace("waterfall_tall_00.png", name)
	text = text.replace("res://assets/sprites/props/", "res://assets/sprites/interior/props/")
	text = re.sub(r"waterfall_tall_00\.png-[a-f0-9]+\.ctex", ctex, text)
	text = re.sub(r'uid://[^\n"]+', uid, text, count=1)
	text = re.sub(r'\.godot/imported/[^"]+', f".godot/imported/{ctex}", text)
	(INTER / f"{name}.import").write_text(text, encoding="utf-8")


def main() -> None:
	INTER.mkdir(parents=True, exist_ok=True)
	sheet = Image.fromarray(key_plate(np.array(Image.open(SRC).convert("RGBA"))), "RGBA")
	w, h = sheet.size
	print("sheet", sheet.size)
	for x0f, y0f, x1f, y1f, name, mx in CELLS:
		piece = trim(sheet.crop((int(w * x0f), int(h * y0f), int(w * x1f), int(h * y1f))), 2)
		if piece.getbbox() is None:
			print("SKIP empty", name)
			continue
		out = downscale_max(piece, mx[0], mx[1])
		out.save(INTER / name)
		write_import(name)
		print("wrote", name, out.size)


if __name__ == "__main__":
	main()
