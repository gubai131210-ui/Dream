#!/usr/bin/env python3
"""G8 StyleQA + portal façade + fishing FX — richer fixed-canvas Nearest sprites."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
FX = ROOT / "assets" / "sprites" / "fx"
FISH = ROOT / "assets" / "sprites" / "fishing"


def blank(w: int, h: int) -> Image.Image:
	return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def save(im: Image.Image, path: Path) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	im.save(path)
	print("wrote", path.relative_to(ROOT), im.size)


def door_facade() -> None:
	"""48x64 — south-facing cottage door bay (portal façade, not cue)."""
	im = blank(48, 64)
	d = ImageDraw.Draw(im)
	# wall plate
	d.rectangle([4, 8, 43, 60], fill=(168, 140, 105, 255))
	d.rectangle([5, 9, 42, 20], fill=(185, 155, 115, 255))
	# timber frame
	d.rectangle([6, 14, 41, 58], outline=(95, 70, 45, 255), width=2)
	d.rectangle([8, 16, 39, 56], fill=(120, 85, 50, 255))
	# door panels
	d.rectangle([12, 22, 22, 52], fill=(100, 68, 38, 255))
	d.rectangle([25, 22, 35, 52], fill=(100, 68, 38, 255))
	d.rectangle([13, 23, 21, 35], fill=(125, 88, 50, 255))
	d.rectangle([26, 23, 34, 35], fill=(125, 88, 50, 255))
	d.rectangle([13, 38, 21, 50], fill=(110, 75, 42, 255))
	d.rectangle([26, 38, 34, 50], fill=(110, 75, 42, 255))
	# handle + threshold
	d.ellipse([33, 36, 36, 39], fill=(200, 170, 70, 255))
	d.rectangle([10, 54, 37, 57], fill=(80, 60, 40, 255))
	# lintel
	d.rectangle([7, 14, 40, 18], fill=(140, 105, 65, 255))
	save(im, PROPS / "door_facade_00.png")


def doorstep_mat() -> None:
	im = blank(48, 16)
	d = ImageDraw.Draw(im)
	d.rectangle([1, 3, 46, 14], fill=(78, 58, 34, 255))
	d.rectangle([2, 4, 45, 8], fill=(118, 90, 52, 255))
	d.rectangle([3, 9, 44, 12], fill=(95, 72, 42, 255))
	for x in (10, 18, 26, 34, 42):
		d.line([x, 4, x, 13], fill=(60, 42, 24, 200))
	d.rectangle([4, 5, 12, 7], fill=(145, 110, 65, 180))
	save(im, PROPS / "doorstep_mat_00.png")


def door_arch_cue() -> None:
	im = blank(32, 40)
	d = ImageDraw.Draw(im)
	# posts with bevel
	d.rectangle([3, 12, 9, 38], fill=(125, 95, 58, 230))
	d.rectangle([4, 13, 7, 20], fill=(155, 120, 75, 230))
	d.rectangle([22, 12, 28, 38], fill=(125, 95, 58, 230))
	d.rectangle([24, 13, 27, 20], fill=(155, 120, 75, 230))
	# stepped arch
	for y, x0, x1 in ((11, 4, 27), (9, 6, 25), (7, 8, 23), (5, 10, 21), (3, 12, 19)):
		d.rectangle([x0, y, x1, y + 2], fill=(150, 118, 70, 235))
	d.rectangle([11, 15, 20, 36], fill=(255, 220, 140, 35))
	save(im, PROPS / "door_arch_cue_00.png")


def track_sleeper() -> None:
	im = blank(32, 16)
	d = ImageDraw.Draw(im)
	d.rectangle([1, 3, 30, 13], fill=(62, 42, 24, 255))
	d.rectangle([2, 4, 29, 7], fill=(98, 70, 40, 255))
	d.rectangle([3, 8, 28, 11], fill=(55, 38, 20, 255))
	d.line([8, 3, 8, 13], fill=(40, 28, 16, 200))
	d.line([16, 3, 16, 13], fill=(40, 28, 16, 180))
	d.line([24, 3, 24, 13], fill=(40, 28, 16, 200))
	save(im, PROPS / "track_sleeper_00.png")


def track_rail() -> None:
	im = blank(32, 8)
	d = ImageDraw.Draw(im)
	d.rectangle([0, 1, 31, 6], fill=(48, 48, 52, 255))
	d.rectangle([0, 2, 31, 4], fill=(110, 110, 118, 255))
	d.rectangle([0, 4, 31, 5], fill=(70, 70, 76, 255))
	for x in range(2, 32, 6):
		d.point((x, 3), fill=(160, 160, 165, 255))
	save(im, PROPS / "track_rail_00.png")


def fence_post() -> None:
	im = blank(16, 32)
	d = ImageDraw.Draw(im)
	d.rectangle([5, 1, 10, 30], fill=(88, 58, 30, 255))
	d.rectangle([6, 2, 9, 10], fill=(120, 82, 45, 255))
	d.rectangle([4, 12, 11, 15], fill=(105, 72, 38, 255))
	d.rectangle([4, 20, 11, 23], fill=(105, 72, 38, 255))
	d.rectangle([5, 28, 10, 30], fill=(55, 38, 20, 255))
	save(im, PROPS / "fence_post_00.png")


def bridge_plank() -> None:
	im = blank(48, 16)
	d = ImageDraw.Draw(im)
	d.rectangle([1, 2, 46, 14], fill=(105, 72, 38, 255))
	d.rectangle([2, 3, 45, 7], fill=(140, 100, 55, 255))
	d.rectangle([2, 9, 45, 12], fill=(90, 60, 32, 255))
	for x in (12, 24, 36):
		d.line([x, 2, x, 14], fill=(70, 48, 25, 255))
	save(im, PROPS / "bridge_plank_00.png")


def furrow_line() -> None:
	im = blank(64, 4)
	d = ImageDraw.Draw(im)
	d.rectangle([0, 1, 63, 2], fill=(78, 52, 28, 170))
	d.rectangle([0, 0, 63, 1], fill=(110, 78, 42, 100))
	d.rectangle([0, 2, 63, 3], fill=(55, 36, 18, 90))
	save(im, PROPS / "furrow_line_00.png")


def leaf_fall() -> None:
	palette = [(72, 138, 58, 255), (98, 158, 68, 255), (55, 118, 48, 255), (130, 100, 45, 255)]
	positions = [(9, 5), (13, 11), (17, 17), (21, 23)]
	for i, (x, y) in enumerate(positions):
		im = blank(32, 32)
		d = ImageDraw.Draw(im)
		c = palette[i]
		d.ellipse([x, y, x + 9, y + 6], fill=c)
		d.ellipse([x + 1, y + 1, x + 5, y + 4], fill=(c[0] + 20, c[1] + 20, c[2] + 10, 200))
		d.line([x + 4, y + 1, x + 5, y + 7], fill=(40, 70, 30, 255))
		save(im, FX / f"leaf_fall_{i:02d}.png")


def fish_bubble() -> None:
	im = blank(16, 16)
	d = ImageDraw.Draw(im)
	d.ellipse([3, 3, 12, 12], fill=(180, 220, 240, 160), outline=(220, 245, 255, 220))
	d.point((6, 6), fill=(255, 255, 255, 220))
	save(im, FX / "fish_bubble_00.png")


def fish_splash() -> None:
	im = blank(24, 24)
	d = ImageDraw.Draw(im)
	d.ellipse([6, 14, 18, 20], fill=(160, 200, 230, 140))
	d.polygon([(11, 4), (13, 14), (9, 14)], fill=(190, 225, 245, 200))
	d.polygon([(5, 8), (9, 16), (4, 15)], fill=(170, 210, 235, 180))
	d.polygon([(19, 8), (15, 16), (20, 15)], fill=(170, 210, 235, 180))
	save(im, FX / "fish_splash_00.png")


def main() -> None:
	door_facade()
	doorstep_mat()
	door_arch_cue()
	track_sleeper()
	track_rail()
	fence_post()
	bridge_plank()
	furrow_line()
	leaf_fall()
	fish_bubble()
	fish_splash()


if __name__ == "__main__":
	main()
