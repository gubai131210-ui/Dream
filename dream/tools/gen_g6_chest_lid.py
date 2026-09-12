#!/usr/bin/env python3
"""G6 chest lid open frames — fixed 48x32 canvas, lid only."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "props"


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	for i in range(4):
		im = Image.new("RGBA", (48, 32), (0, 0, 0, 0))
		d = ImageDraw.Draw(im)
		lift = i * 4
		y0 = 16 - lift
		# lid board
		d.rectangle([6, y0, 41, y0 + 9], fill=(160, 110, 55, 255))
		d.rectangle([8, y0 + 2, 39, y0 + 6], fill=(190, 140, 70, 255))
		# latch
		d.rectangle([22, y0 + 3, 26, y0 + 7], fill=(200, 170, 60, 255))
		if i >= 2:
			d.rectangle([10, y0 + 9, 37, y0 + 12], fill=(30, 20, 10, 100))
		path = OUT / f"chest_lid_{i:02d}.png"
		im.save(path)
		print("wrote", path.name)


if __name__ == "__main__":
	main()
