#!/usr/bin/env python3
"""Install cohesive furniture family — preserve relative heights from atlas."""
from __future__ import annotations

import io
import shutil
from pathlib import Path

import numpy as np
from PIL import Image
from rembg import new_session, remove

ROOT = Path(__file__).resolve().parents[1]
PROP = ROOT / "assets" / "sprites" / "interior" / "props"
ARCH = PROP / "_misnamed_archive"
SRC_DIR = PROP / "_source_atlases"
GEN_CANDIDATES = [
	SRC_DIR / "furniture_family_cozy.png",
	Path(r"C:\Users\孤白赟悫\.cursor\projects\d-GoDot-Projects-Dream\assets\interior_furniture_family_cozy.png"),
]
# Dining table target height; others scale by atlas-relative height.
DINING_H = 64
PAD = 2
BLACK_T = 18
MIN_AREA = 350

# Assigned by reading-order bands after rembg (TL→BR within y-bands).
# Bottom row: round table, then taller 4-leg bar stool, then short pedestal tea stool
# (atlas reading order after rembg often puts bar before tea by x; heights confirm).
OUT_NAMES = [
	"table_dining_00",
	"stool_00",
	"_archive_stool_twin",
	"table_round_00",
	"stool_bar_00",
	"stool_tea_00",
]


def components(mask: np.ndarray) -> list[tuple[int, int, int, int]]:
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
			if (y1 - y0 + 1) * (x1 - x0 + 1) < MIN_AREA:
				continue
			boxes.append((x0, y0, x1, y1))
	# Band by median height of top row (~y0 of first pieces).
	ys0 = sorted(b[1] for b in boxes)
	band = max(40, int((ys0[-1] - ys0[0]) * 0.35)) if len(ys0) >= 2 else 80
	boxes.sort(key=lambda b: (b[1] // band, b[0]))
	return boxes


def crop_rgba(im: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
	x0, y0, x1, y1 = box
	a = np.array(im.crop((x0, y0, x1 + 1, y1 + 1)).convert("RGBA"))
	ys, xs = np.where(a[:, :, 3] > 16)
	if len(xs) == 0:
		return Image.fromarray(a, "RGBA")
	y_a, y_b = max(0, ys.min() - PAD), min(a.shape[0], ys.max() + 1 + PAD)
	x_a, x_b = max(0, xs.min() - PAD), min(a.shape[1], xs.max() + 1 + PAD)
	return Image.fromarray(a[y_a:y_b, x_a:x_b], "RGBA")


def scale_to(im: Image.Image, target_h: int) -> Image.Image:
	target_h = max(12, int(target_h))
	scale = target_h / float(im.height)
	nw = max(8, int(round(im.width * scale)))
	return im.resize((nw, target_h), Image.Resampling.NEAREST)


def backup(dest: Path) -> None:
	if not dest.exists():
		return
	ARCH.mkdir(parents=True, exist_ok=True)
	bak = ARCH / f"pre_cohesion_v2_{dest.name}"
	if not bak.exists():
		shutil.copy2(dest, bak)


def main() -> None:
	gen = next((p for p in GEN_CANDIDATES if p.exists()), None)
	if gen is None:
		raise SystemExit("missing furniture_family_cozy atlas")
	SRC_DIR.mkdir(parents=True, exist_ok=True)
	archived = SRC_DIR / "furniture_family_cozy.png"
	if gen.resolve() != archived.resolve():
		shutil.copy2(gen, archived)

	session = new_session("birefnet-general")
	cut = remove(archived.read_bytes(), session=session)
	im = Image.open(io.BytesIO(cut)).convert("RGBA")
	a = np.array(im)
	m = (a[:, :, 0] < BLACK_T) & (a[:, :, 1] < BLACK_T) & (a[:, :, 2] < BLACK_T)
	a[m, 3] = 0
	im = Image.fromarray(a, "RGBA")
	im.save(PROP / "_diag_furniture_family_rgba.png")
	boxes = components(a[:, :, 3] > 20)
	print(f"islands={len(boxes)} expect={len(OUT_NAMES)}")
	if len(boxes) < 6:
		raise SystemExit(f"too few islands: {len(boxes)}")

	crops = [crop_rgba(im, b) for b in boxes[:6]]
	dining_h_src = crops[0].height
	scale = DINING_H / float(dining_h_src)

	for i, crop in enumerate(crops):
		name = OUT_NAMES[i]
		th = max(12, int(round(crop.height * scale)))
		out = scale_to(crop, th)
		print(f"  [{i}] {name}: src={crop.size} -> {out.size} (h_ratio={crop.height/dining_h_src:.2f})")
		if name.startswith("_archive_"):
			ARCH.mkdir(parents=True, exist_ok=True)
			out.save(ARCH / f"{name[9:]}.png")
			continue
		dest = PROP / f"{name}.png"
		backup(dest)
		out.save(dest)

	# Side-by-side QA row (natural heights).
	pieces = ["table_dining_00", "stool_00", "table_round_00", "stool_tea_00", "stool_bar_00"]
	imgs = [Image.open(PROP / f"{n}.png").convert("RGBA") for n in pieces]
	H = max(i.height for i in imgs) + 10
	W = sum(i.width for i in imgs) + 8 * (len(imgs) + 1)
	canvas = Image.new("RGBA", (W, H), (36, 32, 28, 255))
	x = 8
	for img in imgs:
		canvas.paste(img, (x, H - img.height - 4), img)
		x += img.width + 8
	canvas.save(PROP / "_diag_furniture_cohesion_row.png")
	print("OK cohesion v2", canvas.size)


if __name__ == "__main__":
	main()
