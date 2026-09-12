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


def doorstep_mat() -> None:
	im = Image.new("RGBA", (48, 16), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([2, 4, 45, 14], fill=(88, 70, 42, 230))
	d.rectangle([3, 5, 44, 8], fill=(118, 92, 55, 240))
	d.rectangle([4, 10, 43, 12], fill=(70, 55, 32, 220))
	for x in (12, 24, 36):
		d.line([x, 4, x, 14], fill=(60, 45, 28, 180))
	im.save(OUT / "doorstep_mat_00.png")
	print("wrote doorstep_mat_00.png")


def door_arch_cue() -> None:
	im = Image.new("RGBA", (32, 40), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([4, 14, 8, 38], fill=(140, 110, 70, 200))
	d.rectangle([23, 14, 27, 38], fill=(140, 110, 70, 200))
	for y, x0, x1 in ((12, 5, 26), (10, 7, 24), (8, 9, 22), (6, 11, 20), (4, 13, 18)):
		d.rectangle([x0, y, x1, y + 2], fill=(160, 128, 78, 210))
	d.rectangle([10, 16, 21, 36], fill=(255, 230, 150, 40))
	im.save(OUT / "door_arch_cue_00.png")
	print("wrote door_arch_cue_00.png")


def furrow_line() -> None:
	im = Image.new("RGBA", (64, 4), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([0, 1, 63, 2], fill=(78, 52, 28, 160))
	d.rectangle([0, 0, 63, 1], fill=(95, 68, 38, 90))
	im.save(OUT / "furrow_line_00.png")
	print("wrote furrow_line_00.png")


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	sleeper()
	rail()
	fence_post()
	bridge_plank()
	doorstep_mat()
	door_arch_cue()
	furrow_line()


if __name__ == "__main__":
	main()
