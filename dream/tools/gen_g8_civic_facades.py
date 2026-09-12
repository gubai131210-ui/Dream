#!/usr/bin/env python3
"""Civic façade variants + StyleQA chest/crate/well frames."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets/sprites/props"


def blank(w, h):
	return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def save(im, name):
	path = PROPS / name
	im.save(path)
	print("wrote", name, im.size)


def civic_facade(name: str, wall, timber, door, accent) -> None:
	im = blank(56, 72)
	d = ImageDraw.Draw(im)
	d.rectangle([2, 6, 53, 68], fill=wall)
	d.rectangle([3, 7, 52, 18], fill=(wall[0] + 15, wall[1] + 12, wall[2] + 8, 255))
	d.rectangle([6, 16, 49, 66], outline=timber, width=2)
	d.rectangle([10, 22, 45, 62], fill=door)
	# double door
	d.line([27, 22, 27, 62], fill=timber)
	d.rectangle([12, 24, 25, 40], fill=(door[0] + 18, door[1] + 12, door[2] + 8, 255))
	d.rectangle([29, 24, 42, 40], fill=(door[0] + 18, door[1] + 12, door[2] + 8, 255))
	d.rectangle([12, 44, 25, 58], fill=(door[0] - 8, door[1] - 6, door[2] - 4, 255))
	d.rectangle([29, 44, 42, 58], fill=(door[0] - 8, door[1] - 6, door[2] - 4, 255))
	d.ellipse([40, 40, 44, 44], fill=accent)
	# pediment / sign band
	d.rectangle([8, 10, 47, 16], fill=timber)
	d.rectangle([18, 11, 37, 15], fill=accent)
	d.rectangle([14, 62, 41, 65], fill=(70, 50, 30, 255))
	save(im, name)


def chest_lids() -> None:
	# 32x24 — hinged lid lift over chest body silhouette
	for i in range(4):
		im = blank(32, 24)
		d = ImageDraw.Draw(im)
		# body
		d.rectangle([4, 12, 27, 22], fill=(120, 82, 42, 255))
		d.rectangle([5, 13, 26, 16], fill=(145, 100, 55, 255))
		d.rectangle([14, 16, 17, 19], fill=(200, 170, 70, 255))
		# lid hinge at top of body
		lift = i * 3
		y0 = 10 - lift
		d.rectangle([3, y0, 28, y0 + 6], fill=(135, 92, 48, 255))
		d.rectangle([4, y0 + 1, 27, y0 + 3], fill=(160, 115, 65, 255))
		if i >= 2:
			d.rectangle([6, y0 + 6, 25, y0 + 8], fill=(40, 25, 12, 140))
		save(im, f"chest_lid_{i:02d}.png")


def crate_lids() -> None:
	for i in range(4):
		im = blank(48, 32)
		d = ImageDraw.Draw(im)
		d.rectangle([6, 20, 41, 30], fill=(130, 90, 48, 255))
		d.rectangle([8, 21, 39, 24], fill=(150, 108, 60, 255))
		lift = i * 3
		y0 = 16 - lift
		d.rectangle([5, y0, 42, y0 + 8], fill=(145, 100, 55, 255))
		d.rectangle([7, y0 + 2, 40, y0 + 5], fill=(170, 122, 70, 255))
		d.line([16, y0, 16, y0 + 8], fill=(90, 60, 30, 255))
		d.line([32, y0, 32, y0 + 8], fill=(90, 60, 30, 255))
		if i >= 2:
			d.rectangle([8, y0 + 8, 39, y0 + 10], fill=(35, 22, 12, 120))
		save(im, f"crate_lid_{i:02d}.png")


def well_rope() -> None:
	for i in range(4):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)
		length = 10 + i * 6
		d.rectangle([14, 2, 17, 2 + length], fill=(125, 92, 55, 255))
		d.rectangle([15, 2, 16, 2 + length], fill=(155, 118, 70, 255))
		by = 2 + length
		d.rectangle([10, by, 21, by + 8], fill=(85, 105, 130, 255))
		d.rectangle([11, by + 1, 20, by + 3], fill=(150, 185, 210, 210))
		d.rectangle([12, by + 5, 19, by + 7], fill=(70, 90, 115, 255))
		save(im, f"well_rope_{i:02d}.png")


def main():
	civic_facade(
		"facade_museum_00.png",
		wall=(175, 160, 140, 255),
		timber=(95, 75, 55, 255),
		door=(110, 85, 55, 255),
		accent=(210, 185, 90, 255),
	)
	civic_facade(
		"facade_bath_00.png",
		wall=(150, 170, 175, 255),
		timber=(70, 95, 100, 255),
		door=(90, 120, 125, 255),
		accent=(180, 220, 230, 255),
	)
	chest_lids()
	crate_lids()
	well_rope()


if __name__ == "__main__":
	main()
