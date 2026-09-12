#!/usr/bin/env python3
"""Pixel focus corner L-mark for InteractableHotspot hover (single quadrant)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/sprites/fx/focus_corners_00.png"


def main() -> None:
	im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	gold = (255, 220, 100, 230)
	out = (40, 28, 12, 255)
	# Top-left L
	d.rectangle([1, 1, 10, 3], fill=gold, outline=out)
	d.rectangle([1, 1, 3, 10], fill=gold, outline=out)
	OUT.parent.mkdir(parents=True, exist_ok=True)
	im.save(OUT)
	print("wrote", OUT.relative_to(ROOT), im.size)


if __name__ == "__main__":
	main()
