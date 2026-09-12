#!/usr/bin/env python3
"""Author minimal fixed-canvas G2 interaction FX frames (Nearest-friendly RGBA)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
FX = ROOT / "assets" / "sprites" / "fx"
PROPS = ROOT / "assets" / "sprites" / "props"


def blank(w: int, h: int) -> Image.Image:
	return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def save(img: Image.Image, path: Path) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	img.save(path)
	print("wrote", path.relative_to(ROOT), img.size)


def leaf_fall() -> None:
	# 32x32 — leaf drifts down-right across 4 frames; pivot ~[16,28]
	palette = [(70, 140, 60, 255), (90, 160, 70, 255), (50, 110, 45, 255)]
	positions = [(10, 6), (14, 12), (18, 18), (20, 24)]
	for i, (x, y) in enumerate(positions):
		im = blank(32, 32)
		d = ImageDraw.Draw(im)
		c = palette[i % len(palette)]
		d.ellipse([x, y, x + 8, y + 5], fill=c)
		d.line([x + 4, y + 2, x + 4, y + 7], fill=(40, 80, 30, 255))
		save(im, FX / f"leaf_fall_{i:02d}.png")


def well_rope() -> None:
	# 32x48 — rope drops from top attach; well body stays separate
	for i in range(4):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)
		length = 10 + i * 6
		d.rectangle([14, 4, 17, 4 + length], fill=(120, 90, 55, 255))
		# bucket at end
		by = 4 + length
		d.rectangle([11, by, 20, by + 7], fill=(90, 110, 140, 255))
		d.rectangle([12, by + 1, 19, by + 3], fill=(160, 190, 210, 200))
		save(im, PROPS / f"well_rope_{i:02d}.png")


def crate_lid() -> None:
	# 48x32 — lid opens upward (hinge near bottom of lid strip)
	for i in range(4):
		im = blank(48, 32)
		d = ImageDraw.Draw(im)
		# lift amount
		lift = i * 3
		y0 = 18 - lift
		d.rectangle([6, y0, 41, y0 + 8], fill=(150, 105, 60, 255))
		d.rectangle([8, y0 + 2, 39, y0 + 5], fill=(170, 125, 75, 255))
		if i >= 2:
			# ajar gap shadow
			d.rectangle([8, y0 + 8, 39, y0 + 10], fill=(40, 25, 15, 120))
		save(im, PROPS / f"crate_lid_{i:02d}.png")


def bird_peck() -> None:
	# 32x32 — small bird peck cycle; feet at bottom
	for i in range(4):
		im = blank(32, 32)
		d = ImageDraw.Draw(im)
		body_y = 18 if i in (0, 3) else 20
		head_y = body_y - (6 if i == 2 else 4)
		d.ellipse([10, body_y, 22, body_y + 8], fill=(90, 70, 55, 255))
		d.ellipse([18, head_y, 26, head_y + 6], fill=(80, 60, 50, 255))
		beak_y = head_y + 3
		if i == 2:
			d.polygon([(26, beak_y), (31, beak_y + 2), (26, beak_y + 4)], fill=(200, 160, 60, 255))
		else:
			d.polygon([(26, beak_y), (30, beak_y + 1), (26, beak_y + 3)], fill=(200, 160, 60, 255))
		# feet
		d.line([14, 28, 14, 30], fill=(40, 30, 20, 255))
		d.line([18, 28, 18, 30], fill=(40, 30, 20, 255))
		save(im, FX / f"bird_peck_{i:02d}.png")


def main() -> None:
	leaf_fall()
	well_rope()
	crate_lid()
	bird_peck()


if __name__ == "__main__":
	main()
