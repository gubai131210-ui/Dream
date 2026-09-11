#!/usr/bin/env python3
"""Install scene-fit lamps (shop/smith/tavern) + stall corners for barn."""
from __future__ import annotations

import io
from pathlib import Path

import numpy as np
from PIL import Image
from rembg import new_session, remove

ROOT = Path(__file__).resolve().parents[1]
PROP = ROOT / "assets" / "sprites" / "interior" / "props"
ASSETS = Path(r"C:\Users\孤白赟悫\.cursor\projects\d-GoDot-Projects-Dream\assets")
BLACK_T = 22
TARGET_H = 48

LAMPS = {
	"lamp_shop_00.png": ASSETS / "lamp_shop_00.png",
	"lamp_smith_00.png": ASSETS / "lamp_smith_00.png",
	"lamp_tavern_00.png": ASSETS / "lamp_tavern_00.png",
}

OUTLINE = (42, 28, 18, 255)
DARK = (78, 48, 28, 255)
MID = (128, 82, 48, 255)
LIT = (168, 118, 72, 255)
HI = (198, 156, 102, 255)
TILE = 32
POST = 5


def rembg_rgba(path: Path, session) -> Image.Image:
	cut = remove(path.read_bytes(), session=session)
	im = Image.open(io.BytesIO(cut)).convert("RGBA")
	a = np.array(im)
	m = (a[:, :, 0] < BLACK_T) & (a[:, :, 1] < BLACK_T) & (a[:, :, 2] < BLACK_T)
	a[m, 3] = 0
	return Image.fromarray(a, "RGBA")


def trim(im: Image.Image, pad: int = 1) -> Image.Image:
	a = np.array(im)
	ys, xs = np.where(a[:, :, 3] > 16)
	if len(xs) == 0:
		return im
	y0, y1 = max(0, ys.min() - pad), min(a.shape[0], ys.max() + 1 + pad)
	x0, x1 = max(0, xs.min() - pad), min(a.shape[1], xs.max() + 1 + pad)
	return Image.fromarray(a[y0:y1, x0:x1], "RGBA")


def norm_h(im: Image.Image, th: int) -> Image.Image:
	im = trim(im)
	scale = th / float(max(1, im.height))
	nw = max(8, int(round(im.width * scale)))
	return im.resize((nw, th), Image.Resampling.NEAREST)


def blank(w: int, h: int) -> np.ndarray:
	return np.zeros((h, w, 4), dtype=np.uint8)


def put(a: np.ndarray, x: int, y: int, c: tuple) -> None:
	if 0 <= x < a.shape[1] and 0 <= y < a.shape[0]:
		a[y, x] = c


def fill(a: np.ndarray, x0: int, y0: int, x1: int, y1: int, c: tuple) -> None:
	for y in range(min(y0, y1), max(y0, y1) + 1):
		for x in range(min(x0, x1), max(x0, x1) + 1):
			put(a, x, y, c)


def board_h(a: np.ndarray, x0: int, x1: int, y: int) -> None:
	fill(a, x0, y, x1, y + 4, MID)
	for x in range(x0, x1 + 1):
		put(a, x, y, HI)
		put(a, x, y + 1, LIT)
		put(a, x, y + 4, OUTLINE)


def post(a: np.ndarray, px: int, y0: int, y1: int) -> None:
	fill(a, px, y0, px + POST - 1, y1, MID)
	for y in range(y0, y1 + 1):
		put(a, px, y, OUTLINE)
		put(a, px + 1, y, HI)
		put(a, px + POST - 1, y, OUTLINE)


def make_stall_corner(kind: str) -> Image.Image:
	"""Taller stall L-corner (6 boards) matching stall rails."""
	G = 36
	boards = [3, 8, 13, 18, 23, 28]
	a = blank(TILE, G + 2)
	if kind == "nw":
		post(a, 2, 1, G)
		for y in boards:
			board_h(a, 2 + POST - 1, TILE - 1, y)
		fill(a, 2 + POST, boards[0], 2 + POST + 6, G, MID)
		for y in range(boards[0], G + 1):
			put(a, 2 + POST, y, HI)
			put(a, 2 + POST + 6, y, OUTLINE)
		for y in boards:
			for x in range(2 + POST, 2 + POST + 7):
				put(a, x, y, DARK)
	elif kind == "ne":
		px = TILE - POST - 2
		post(a, px, 1, G)
		for y in boards:
			board_h(a, 0, px + 1, y)
		fill(a, px - 7, boards[0], px - 1, G, MID)
		for y in range(boards[0], G + 1):
			put(a, px - 7, y, OUTLINE)
			put(a, px - 1, y, HI)
		for y in boards:
			for x in range(px - 7, px):
				put(a, x, y, DARK)
	elif kind == "sw":
		post(a, 2, 1, G)
		for y in boards:
			board_h(a, 2 + POST - 1, TILE - 1, y)
		fill(a, 2 + POST, 2, 2 + POST + 6, boards[-1] + 4, MID)
		for y in range(2, boards[-1] + 5):
			put(a, 2 + POST, y, HI)
			put(a, 2 + POST + 6, y, OUTLINE)
		for y in boards:
			for x in range(2 + POST, 2 + POST + 7):
				put(a, x, y, DARK)
	else:
		px = TILE - POST - 2
		post(a, px, 1, G)
		for y in boards:
			board_h(a, 0, px + 1, y)
		fill(a, px - 7, 2, px - 1, boards[-1] + 4, MID)
		for y in range(2, boards[-1] + 5):
			put(a, px - 7, y, OUTLINE)
			put(a, px - 1, y, HI)
		for y in boards:
			for x in range(px - 7, px):
				put(a, x, y, DARK)
	return Image.fromarray(a, "RGBA")


def install_lamps(session) -> None:
	for name, src in LAMPS.items():
		if not src.exists():
			print("SKIP missing", src)
			continue
		im = norm_h(rembg_rgba(src, session), TARGET_H)
		im.save(PROP / name)
		print("wrote", name, im.size)


def install_stall_corners() -> None:
	for k in ("nw", "ne", "sw", "se"):
		im = make_stall_corner(k)
		name = f"stall_corner_{k}_00.png"
		im.save(PROP / name)
		print("wrote", name, im.size)


def main() -> None:
	PROP.mkdir(parents=True, exist_ok=True)
	session = new_session("birefnet-general")
	install_lamps(session)
	install_stall_corners()
	print("OK wave-c scene-fit")


if __name__ == "__main__":
	main()
