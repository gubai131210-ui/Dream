#!/usr/bin/env python3
"""Soft window light shaft sprite — replaces interior Polygon2D shaft."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/sprites/fx/window_light_shaft_00.png"


def main() -> None:
	im = Image.new("RGBA", (64, 96), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	# Warm shaft tapering downward
	d.polygon([(28, 4), (36, 4), (52, 92), (12, 92)], fill=(255, 230, 160, 55))
	d.polygon([(30, 8), (34, 8), (44, 88), (20, 88)], fill=(255, 240, 190, 70))
	im = im.filter(ImageFilter.GaussianBlur(radius=1.2))
	# Keep soft alpha, re-boost core
	core = Image.new("RGBA", (64, 96), (0, 0, 0, 0))
	cd = ImageDraw.Draw(core)
	cd.polygon([(30, 10), (34, 10), (42, 86), (22, 86)], fill=(255, 236, 180, 40))
	im = Image.alpha_composite(im, core)
	OUT.parent.mkdir(parents=True, exist_ok=True)
	im.save(OUT)
	print("wrote", OUT.relative_to(ROOT), im.size)


if __name__ == "__main__":
	main()
