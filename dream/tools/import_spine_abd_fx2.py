#!/usr/bin/env python3
"""Slice water/harvest FX + ruin urn + moss clear from farm_encounter_fx_urn_sheet."""
from __future__ import annotations

import hashlib
import re
import uuid
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets/sprites/props"
FX = ROOT / "assets/sprites/fx"
SRC = Path(
	r"C:\Users\孤白赟悫\.cursor\projects\d-GoDot-Projects-Dream\assets\farm_encounter_fx_urn_sheet.png"
)
TMPL = (PROPS / "waterfall_tall_00.png.import").read_text(encoding="utf-8")
NEAREST = Image.Resampling.NEAREST

CELLS = [
	(0.00, 0.05, 0.25, 0.95, "crop_water_splash_00.png", (40, 40), FX, "fx"),
	(0.25, 0.05, 0.50, 0.95, "crop_harvest_spark_00.png", (40, 40), FX, "fx"),
	(0.50, 0.05, 0.75, 0.95, "ruin_cache_urn_00.png", (48, 56), PROPS, "props"),
	(0.75, 0.05, 1.00, 0.95, "moss_clear_fx_00.png", (64, 48), FX, "fx"),
]


def key_plate(rgba: np.ndarray) -> np.ndarray:
	r, g, b = rgba[:, :, 0].astype(np.int16), rgba[:, :, 1].astype(np.int16), rgba[:, :, 2].astype(np.int16)
	mx = np.maximum(np.maximum(r, g), b)
	mn = np.minimum(np.minimum(r, g), b)
	chroma = mx - mn
	kill = (
		((mx >= 200) & (chroma <= 40))
		| ((np.abs(r - 128) < 30) & (np.abs(g - 128) < 30) & (np.abs(b - 128) < 30) & (chroma <= 25))
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


def ds(im: Image.Image, mw: int, mh: int) -> Image.Image:
	s = min(mw / im.width, mh / im.height, 1.0)
	if s >= 1.0:
		return im
	return im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))), NEAREST)


def write_import(folder: Path, name: str, rel: str) -> None:
	uid = "uid://r" + uuid.uuid4().hex[:13]
	h = hashlib.md5((rel + "/" + name).encode()).hexdigest()
	ctex = f"{name}-{h}.ctex"
	text = TMPL.replace("waterfall_tall_00.png", name)
	text = text.replace("res://assets/sprites/props/", f"res://assets/sprites/{rel}/")
	text = re.sub(r"waterfall_tall_00\.png-[a-f0-9]+\.ctex", ctex, text)
	text = re.sub(r'uid://[^\n"]+', uid, text, count=1)
	text = re.sub(r'\.godot/imported/[^"]+', f".godot/imported/{ctex}", text)
	(folder / f"{name}.import").write_text(text, encoding="utf-8")


def main() -> None:
	sheet = Image.fromarray(key_plate(np.array(Image.open(SRC).convert("RGBA"))), "RGBA")
	w, h = sheet.size
	print("sheet", sheet.size)
	for x0f, y0f, x1f, y1f, name, mx, folder, rel in CELLS:
		piece = trim(sheet.crop((int(w * x0f), int(h * y0f), int(w * x1f), int(h * y1f))), 2)
		if piece.getbbox() is None:
			print("SKIP", name)
			continue
		out = ds(piece, mx[0], mx[1])
		folder.mkdir(parents=True, exist_ok=True)
		out.save(folder / name)
		write_import(folder, name, rel)
		if name == "moss_clear_fx_00.png":
			out.save(PROPS / name)
			write_import(PROPS, name, "props")
		print("wrote", rel, name, out.size)


if __name__ == "__main__":
	main()
