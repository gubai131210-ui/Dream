#!/usr/bin/env python3
"""Install scene-fit farm lantern + rembg-slice pen corner sheet."""
from __future__ import annotations

import io
from pathlib import Path

import numpy as np
from PIL import Image
from rembg import new_session, remove

ROOT = Path(__file__).resolve().parents[1]
PROP = ROOT / "assets" / "sprites" / "interior" / "props"
ARCH = PROP / "_misnamed_archive"
ASSETS = Path(r"C:\Users\孤白赟悫\.cursor\projects\d-GoDot-Projects-Dream\assets")

LAMP_SRC = ASSETS / "lamp_farm_lantern_00.png"
CORNER_SRC = ASSETS / "pen_corners_sheet.png"
BLACK_T = 22
TARGET_H_LAMP = 48
TARGET_CORNER = 32


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
	scale = th / float(im.height)
	nw = max(8, int(round(im.width * scale)))
	return im.resize((nw, th), Image.Resampling.NEAREST)


def components(mask: np.ndarray, min_area: int = 800) -> list[tuple[int, int, int, int]]:
	h, w = mask.shape
	visited = np.zeros_like(mask, dtype=bool)
	boxes: list[tuple[int, int, int, int]] = []
	for y in range(h):
		for x in range(w):
			if not mask[y, x] or visited[y, x]:
				continue
			stack = [(y, x)]
			visited[y, x] = True
			ys, xs = [y], [x]
			while stack:
				cy, cx = stack.pop()
				for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
					if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not visited[ny, nx]:
						visited[ny, nx] = True
						stack.append((ny, nx))
						ys.append(ny)
						xs.append(nx)
			y0, y1 = min(ys), max(ys)
			x0, x1 = min(xs), max(xs)
			if (y1 - y0 + 1) * (x1 - x0 + 1) < min_area:
				continue
			boxes.append((x0, y0, x1, y1))
	boxes.sort(key=lambda b: (b[1] // 80, b[0]))
	return boxes


def install_lamp(session) -> None:
	if not LAMP_SRC.exists():
		raise SystemExit(f"missing {LAMP_SRC}")
	im = rembg_rgba(LAMP_SRC, session)
	im = norm_h(im, TARGET_H_LAMP)
	dest = PROP / "lamp_farm_00.png"
	im.save(dest)
	print("wrote", dest.name, im.size)


def install_corners(session) -> None:
	if not CORNER_SRC.exists():
		raise SystemExit(f"missing {CORNER_SRC}")
	im = rembg_rgba(CORNER_SRC, session)
	im.save(PROP / "_diag_pen_corners_rgba.png")
	a = np.array(im)
	boxes = components(a[:, :, 3] > 20)
	print("corner islands", len(boxes))
	names = ["pen_corner_nw_00", "pen_corner_ne_00", "pen_corner_sw_00", "pen_corner_se_00"]
	ARCH.mkdir(parents=True, exist_ok=True)
	for i, box in enumerate(boxes[:4]):
		x0, y0, x1, y1 = box
		crop = trim(im.crop((x0, y0, x1 + 1, y1 + 1)))
		# Fit into 32x32 tile canvas feet-bottom
		scale = min(TARGET_CORNER / crop.width, TARGET_CORNER / crop.height)
		nw = max(8, int(round(crop.width * scale)))
		nh = max(8, int(round(crop.height * scale)))
		resized = crop.resize((nw, nh), Image.Resampling.NEAREST)
		canvas = Image.new("RGBA", (TARGET_CORNER, TARGET_CORNER), (0, 0, 0, 0))
		ox = (TARGET_CORNER - nw) // 2
		oy = TARGET_CORNER - nh
		canvas.paste(resized, (ox, oy), resized)
		name = names[i] if i < len(names) else f"pen_corner_extra_{i}"
		dest = PROP / f"{name}.png"
		bak = ARCH / f"pre_corner_art_{name}.png"
		if dest.exists() and not bak.exists():
			dest.replace(bak)
		elif dest.exists():
			dest.unlink()
		canvas.save(dest)
		print("wrote", dest.name, canvas.size)

	# Also rebuild H/V edge tiles from the SAME board language as NW corner horizontal arm:
	# procedural dense boards matching corner palette sampled from NW
	_regen_edges_from_corner(PROP / "pen_corner_nw_00.png")


def _regen_edges_from_corner(nw_path: Path) -> None:
	"""Make pen_fence H/V share palette sampled from corner art."""
	nw = np.array(Image.open(nw_path).convert("RGBA"))
	opaque = nw[:, :, 3] > 16
	if not opaque.any():
		return
	pixels = nw[opaque][:, :3]
	# pick mid brown
	mid = tuple(int(x) for x in np.median(pixels, axis=0)) + (255,)
	dark = tuple(max(0, c - 40) for c in mid[:3]) + (255,)
	lit = tuple(min(255, c + 35) for c in mid[:3]) + (255,)
	hi = tuple(min(255, c + 55) for c in mid[:3]) + (255,)
	outline = (42, 28, 18, 255)

	def blank(w, h):
		return np.zeros((h, w, 4), dtype=np.uint8)

	def put(a, x, y, c):
		if 0 <= x < a.shape[1] and 0 <= y < a.shape[0]:
			a[y, x] = c

	def fill(a, x0, y0, x1, y1, c):
		for y in range(y0, y1 + 1):
			for x in range(x0, x1 + 1):
				put(a, x, y, c)

	TILE, POST, G = 32, 5, 28
	# H
	a = blank(TILE, G + 2)
	boards = [4, 10, 16, 22]
	for y in boards:
		fill(a, 0, y, TILE - 1, y + 3, mid)
		for x in range(TILE):
			put(a, x, y, hi)
			put(a, x, y + 3, outline)
	fill(a, 0, boards[0] - 2, POST - 1, G, mid)
	for y in range(boards[0] - 2, G + 1):
		put(a, 0, y, outline)
		put(a, 1, y, hi)
		put(a, POST - 1, y, outline)
	Image.fromarray(a, "RGBA").save(PROP / "pen_fence_00.png")
	# V
	b = blank(TILE, G + 2)
	near, far = 4, TILE - POST - 4
	for y in boards:
		for x in range(near + POST - 1, far + 1):
			t = (x - near) / max(1, far - near)
			yy = y + int(round(t * 2))
			put(b, x, yy, hi)
			put(b, x, yy + 1, lit)
			put(b, x, yy + 2, mid)
			put(b, x, yy + 3, outline)
	for px in (near, far):
		fill(b, px, boards[0] - 2, px + POST - 1, G, mid)
		for y in range(boards[0] - 2, G + 1):
			put(b, px, y, outline)
			put(b, px + 1, y, hi)
			put(b, px + POST - 1, y, outline)
	Image.fromarray(b, "RGBA").save(PROP / "pen_fence_v_00.png")
	print("rewrote pen_fence H/V to match corner palette", mid)


def main() -> None:
	PROP.mkdir(parents=True, exist_ok=True)
	session = new_session("birefnet-general")
	install_lamp(session)
	install_corners(session)
	print("OK scene-fit props")


if __name__ == "__main__":
	main()
