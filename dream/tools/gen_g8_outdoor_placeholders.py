#!/usr/bin/env python3
"""G8 track sleeper + rail sprites (fixed canvases, Nearest-friendly)."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "props"


def sleeper() -> None:
	im = Image.new("RGBA", (32, 16), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([2, 4, 29, 12], fill=(70, 48, 28, 255))
	d.rectangle([3, 5, 28, 8], fill=(95, 68, 40, 255))
	d.rectangle([4, 9, 27, 11], fill=(55, 38, 22, 255))
	im.save(OUT / "track_sleeper_00.png")
	print("wrote track_sleeper_00.png")


def rail() -> None:
	im = Image.new("RGBA", (32, 8), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([0, 2, 31, 5], fill=(55, 55, 60, 255))
	d.rectangle([0, 3, 31, 4], fill=(90, 90, 95, 255))
	im.save(OUT / "track_rail_00.png")
	print("wrote track_rail_00.png")


def fence_post() -> None:
	im = Image.new("RGBA", (16, 32), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([5, 2, 10, 30], fill=(95, 62, 32, 255))
	d.rectangle([6, 3, 9, 12], fill=(120, 82, 45, 255))
	d.rectangle([4, 14, 11, 17], fill=(110, 75, 40, 255))
	d.rectangle([4, 22, 11, 25], fill=(110, 75, 40, 255))
	im.save(OUT / "fence_post_00.png")
	print("wrote fence_post_00.png")


def bridge_plank() -> None:
	im = Image.new("RGBA", (48, 16), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([2, 3, 45, 13], fill=(120, 85, 45, 255))
	d.rectangle([3, 4, 44, 7], fill=(145, 105, 60, 255))
	d.line([12, 3, 12, 13], fill=(90, 60, 30, 255))
	d.line([24, 3, 24, 13], fill=(90, 60, 30, 255))
	d.line([36, 3, 36, 13], fill=(90, 60, 30, 255))
	im.save(OUT / "bridge_plank_00.png")
	print("wrote bridge_plank_00.png")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	sleeper()
	rail()
	fence_post()
	bridge_plank()


if __name__ == "__main__":
	main()
