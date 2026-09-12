#!/usr/bin/env python3
"""Generate fish_ring_00.png — soft elliptical water ring under bobber (no Polygon2D)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/sprites/fx/fish_ring_00.png"


def main() -> None:
	im = Image.new("RGBA", (48, 24), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	# Outer soft ring
	d.ellipse([2, 4, 45, 20], outline=(90, 150, 190, 160), width=2)
	d.ellipse([6, 7, 41, 17], outline=(140, 200, 230, 110), width=1)
	# Soft fill hint
	d.ellipse([10, 9, 37, 15], fill=(120, 180, 210, 40))
	OUT.parent.mkdir(parents=True, exist_ok=True)
	im.save(OUT)
	print("wrote", OUT.relative_to(ROOT), im.size)


if __name__ == "__main__":
	main()
