#!/usr/bin/env python3
"""G6 drawer open frames for dresser interact — fixed 48x32 canvas."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "interior" / "props"


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	for i in range(4):
		im = Image.new("RGBA", (48, 32), (0, 0, 0, 0))
		d = ImageDraw.Draw(im)
		pull = i * 3
		# drawer face pulled forward (down on canvas)
		y0 = 10 + pull
		d.rectangle([8, y0, 39, y0 + 12], fill=(120, 80, 45, 255))
		d.rectangle([10, y0 + 2, 37, y0 + 9], fill=(150, 105, 60, 255))
		# knob
		d.ellipse([21, y0 + 4, 27, y0 + 9], fill=(200, 170, 70, 255))
		# gap shadow when open
		if i >= 1:
			d.rectangle([10, y0 - 3, 37, y0], fill=(40, 25, 15, 90))
		path = OUT / f"drawer_open_{i:02d}.png"
		im.save(path)
		print("wrote", path.name)


if __name__ == "__main__":
	main()
