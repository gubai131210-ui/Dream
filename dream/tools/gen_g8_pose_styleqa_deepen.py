#!/usr/bin/env python3
"""StyleQA deepen: work poses matching farmer palette + denser bird/leaf FX."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
POSE = ROOT / "assets/sprites/npc/work_poses"
FX = ROOT / "assets/sprites/fx"

# Farmer walk palette (approx)
SKIN = (232, 198, 168, 255)
HAIR = (92, 62, 40, 255)
HAT = (196, 164, 110, 255)
HAT_BAND = (78, 52, 32, 255)
SHIRT = (72, 128, 78, 255)
OVERALL = (110, 78, 48, 255)
BTN = (220, 185, 70, 255)
SHOE = (40, 32, 28, 255)
OUT = (28, 22, 18, 255)
WOOD = (130, 92, 52, 255)
IRON = (120, 120, 128, 255)


def blank(w: int, h: int) -> Image.Image:
	return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def save(im: Image.Image, path: Path) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	im.save(path)
	print("wrote", path.relative_to(ROOT), im.size)


def _farmer(d, ox: int = 0, arm_r=None) -> None:
	"""Front-ish farmer on 32x48 canvas; feet near y=45."""
	# hat
	d.ellipse([ox + 8, 2, ox + 23, 12], fill=HAT, outline=OUT)
	d.rectangle([ox + 10, 8, ox + 21, 12], fill=HAT)
	d.rectangle([ox + 11, 10, ox + 20, 12], fill=HAT_BAND)
	# head
	d.ellipse([ox + 10, 10, ox + 21, 21], fill=SKIN, outline=OUT)
	d.point((ox + 13, 15), fill=OUT)
	d.point((ox + 18, 15), fill=OUT)
	# hair peek
	d.rectangle([ox + 11, 11, ox + 13, 13], fill=HAIR)
	d.rectangle([ox + 18, 11, ox + 20, 13], fill=HAIR)
	# torso shirt
	d.rectangle([ox + 10, 20, ox + 21, 30], fill=SHIRT, outline=OUT)
	# overalls
	d.rectangle([ox + 10, 26, ox + 21, 38], fill=OVERALL, outline=OUT)
	d.rectangle([ox + 11, 22, ox + 13, 28], fill=OVERALL)
	d.rectangle([ox + 18, 22, ox + 20, 28], fill=OVERALL)
	d.point((ox + 12, 24), fill=BTN)
	d.point((ox + 19, 24), fill=BTN)
	# legs
	d.rectangle([ox + 11, 38, ox + 14, 44], fill=OVERALL, outline=OUT)
	d.rectangle([ox + 17, 38, ox + 20, 44], fill=OVERALL, outline=OUT)
	# shoes
	d.rectangle([ox + 10, 44, ox + 15, 46], fill=SHOE)
	d.rectangle([ox + 16, 44, ox + 21, 46], fill=SHOE)
	# default right arm if not overridden
	if arm_r is None:
		d.rectangle([ox + 21, 22, ox + 24, 30], fill=SKIN, outline=OUT)
	else:
		arm_r(d, ox)


def pose_sow() -> None:
	out = POSE / "sow"
	swings = [(24, 18), (26, 14), (28, 22), (25, 16)]
	for i, (hx, hy) in enumerate(swings):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)

		def arm(d2, ox):
			d2.line([ox + 21, 24, hx, hy], fill=WOOD, width=2)
			d2.rectangle([hx - 1, hy - 1, hx + 4, hy + 2], fill=IRON, outline=OUT)

		_farmer(d, 0, arm)
		# soil chip on strike
		if i == 2:
			d.ellipse([22, 40, 28, 44], fill=(90, 70, 40, 180))
		save(im, out / f"pose_{i:02d}.png")


def pose_smith() -> None:
	out = POSE / "smith"
	hammers = [(22, 10), (20, 6), (24, 18), (22, 12)]
	for i, (hx, hy) in enumerate(hammers):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)

		def arm(d2, ox):
			d2.line([ox + 20, 24, hx, hy], fill=WOOD, width=2)
			d2.rectangle([hx - 2, hy - 2, hx + 4, hy + 2], fill=IRON, outline=OUT)

		_farmer(d, 0, arm)
		# recolor shirt to charcoal for smith
		d.rectangle([10, 20, 21, 26], fill=(88, 90, 98, 255))
		d.rectangle([4, 36, 14, 42], fill=IRON, outline=OUT)  # anvil
		d.rectangle([5, 34, 13, 36], fill=(140, 140, 150, 255))
		if i == 2:
			d.ellipse([18, 32, 22, 36], fill=(255, 180, 80, 200))
		save(im, out / f"pose_{i:02d}.png")


def pose_stall() -> None:
	out = POSE / "stall"
	offers = [(20, 22), (21, 20), (22, 22), (21, 21)]
	for i, (bx, by) in enumerate(offers):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)

		def arm(d2, ox):
			d2.rectangle([ox + 21, 22, ox + 24, by + 4], fill=SKIN, outline=OUT)

		_farmer(d, 0, arm)
		d.rectangle([10, 20, 21, 26], fill=(180, 100, 70, 255))  # merchant shirt
		d.ellipse([bx, by, bx + 10, by + 7], fill=WOOD, outline=OUT)
		d.ellipse([bx + 2, by + 1, bx + 5, by + 4], fill=(200, 70, 60, 255))
		d.ellipse([bx + 5, by + 2, bx + 8, by + 5], fill=(80, 160, 70, 255))
		save(im, out / f"pose_{i:02d}.png")


def pose_cook() -> None:
	out = POSE / "cook"
	stirs = [(22, 24), (23, 26), (24, 28), (23, 25)]
	for i, (lx, ly) in enumerate(stirs):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)

		def arm(d2, ox):
			d2.line([ox + 18, 24, lx, ly], fill=WOOD, width=2)
			d2.ellipse([lx, ly, lx + 5, ly + 4], fill=IRON, outline=OUT)

		_farmer(d, 0, arm)
		d.rectangle([10, 20, 21, 30], fill=(240, 240, 235, 255), outline=OUT)  # apron
		d.rectangle([6, 34, 16, 42], fill=(55, 55, 65, 255), outline=OUT)
		if i % 2 == 0:
			d.ellipse([8, 30, 14, 34], fill=(200, 200, 210, 140))
		save(im, out / f"pose_{i:02d}.png")


def leaf_fall() -> None:
	palette = [
		(72, 138, 58, 255),
		(98, 158, 68, 255),
		(55, 118, 48, 255),
		(150, 110, 45, 255),
	]
	positions = [(8, 4), (12, 10), (16, 16), (20, 22)]
	for i, (x, y) in enumerate(positions):
		im = blank(32, 32)
		d = ImageDraw.Draw(im)
		c = palette[i]
		d.ellipse([x, y, x + 10, y + 6], fill=c, outline=(40, 70, 30, 255))
		d.ellipse([x + 2, y + 1, x + 6, y + 4], fill=(min(255, c[0] + 25), min(255, c[1] + 25), c[2] + 10, 220))
		d.line([x + 5, y + 1, x + 6, y + 8], fill=(40, 70, 30, 255))
		# tip notch
		d.point((x + 9, y + 3), fill=(40, 70, 30, 255))
		save(im, FX / f"leaf_fall_{i:02d}.png")


def bird_peck() -> None:
	for i in range(4):
		im = blank(32, 32)
		d = ImageDraw.Draw(im)
		body_y = 17 if i in (0, 3) else 19
		head_y = body_y - (7 if i == 2 else 5)
		d.ellipse([9, body_y, 22, body_y + 9], fill=(95, 72, 55, 255), outline=OUT)
		d.ellipse([17, head_y, 26, head_y + 7], fill=(85, 62, 48, 255), outline=OUT)
		d.point((23, head_y + 3), fill=(20, 20, 20, 255))
		beak_y = head_y + 3
		if i == 2:
			d.polygon([(26, beak_y), (31, beak_y + 2), (26, beak_y + 4)], fill=(210, 165, 55, 255))
		else:
			d.polygon([(26, beak_y), (30, beak_y + 1), (26, beak_y + 3)], fill=(210, 165, 55, 255))
		# feet
		d.line([12, body_y + 9, 11, 28], fill=OUT)
		d.line([18, body_y + 9, 19, 28], fill=OUT)
		# wing
		wy = body_y + (1 if i % 2 == 0 else 3)
		d.ellipse([8, wy, 14, wy + 5], fill=(70, 50, 38, 255))
		save(im, FX / f"bird_peck_{i:02d}.png")


def main() -> None:
	pose_sow()
	pose_smith()
	pose_stall()
	pose_cook()
	leaf_fall()
	bird_peck()


if __name__ == "__main__":
	main()
