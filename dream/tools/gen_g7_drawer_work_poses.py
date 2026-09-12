#!/usr/bin/env python3
"""StyleQA drawer frames + C53 work-pose sheets + C60 gate log sprite."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
INTERIOR = ROOT / "assets/sprites/interior/props"
PROPS = ROOT / "assets/sprites/props"
POSE = ROOT / "assets/sprites/npc/work_poses"


def blank(w: int, h: int) -> Image.Image:
	return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def save(im: Image.Image, path: Path) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	im.save(path)
	print("wrote", path.relative_to(ROOT), im.size)


def drawer_open() -> None:
	"""48x40 — dresser body + drawer sliding forward (feet at bottom)."""
	for i in range(4):
		im = blank(48, 40)
		d = ImageDraw.Draw(im)
		# cabinet body
		d.rectangle([6, 4, 41, 36], fill=(118, 82, 48, 255))
		d.rectangle([7, 5, 40, 12], fill=(140, 100, 58, 255))
		d.rectangle([7, 30, 40, 35], fill=(95, 65, 38, 255))
		# closed slots behind
		d.rectangle([10, 14, 37, 20], fill=(90, 60, 35, 255))
		d.rectangle([10, 22, 37, 28], fill=(90, 60, 35, 255))
		# sliding drawer (top slot)
		pull = 2 + i * 4
		x0, y0 = 10, 14
		d.rectangle([x0, y0, 37, 21], fill=(70, 48, 28, 255))  # cavity
		d.rectangle([x0, y0 + 1, 37 - pull, y0 + 6], fill=(150, 108, 62, 255))
		d.rectangle([x0 + 1, y0 + 2, 36 - pull, y0 + 4], fill=(170, 125, 75, 255))
		# knob
		kx = 37 - pull - 3
		d.ellipse([kx, y0 + 2, kx + 3, y0 + 5], fill=(210, 175, 80, 255))
		if i >= 2:
			# contents peek
			d.rectangle([x0 + 4, y0 + 2, x0 + 10, y0 + 5], fill=(200, 180, 140, 200))
		save(im, INTERIOR / f"drawer_open_{i:02d}.png")


def gate_log() -> None:
	im = blank(48, 24)
	d = ImageDraw.Draw(im)
	d.ellipse([2, 6, 45, 20], fill=(95, 65, 35, 255))
	d.ellipse([4, 8, 43, 18], fill=(125, 88, 48, 255))
	d.ellipse([38, 8, 45, 18], fill=(80, 55, 30, 255))
	d.line([12, 9, 12, 17], fill=(70, 48, 25, 200))
	d.line([24, 8, 24, 18], fill=(70, 48, 25, 180))
	d.line([34, 9, 34, 17], fill=(70, 48, 25, 200))
	save(im, PROPS / "gate_log_00.png")


def _body(d, x: int, y: int, shirt, pants) -> None:
	# simple front-facing 3/4 body, feet near bottom of 32x48
	d.ellipse([x + 10, y + 2, x + 21, y + 13], fill=(220, 185, 150, 255))  # head
	d.rectangle([x + 11, y + 12, x + 20, y + 28], fill=shirt)  # torso
	d.rectangle([x + 11, y + 28, x + 15, y + 42], fill=pants)
	d.rectangle([x + 16, y + 28, x + 20, y + 42], fill=pants)
	d.rectangle([x + 10, y + 42, x + 15, y + 45], fill=(50, 40, 30, 255))
	d.rectangle([x + 16, y + 42, x + 21, y + 45], fill=(50, 40, 30, 255))


def pose_sow() -> None:
	out = POSE / "sow"
	for i in range(4):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)
		_body(d, 0, 0, (70, 130, 80, 255), (90, 70, 45, 255))
		# hoe swing
		angle_y = 18 + (0, 4, 8, 2)[i]
		d.line([22, 20, 28, angle_y], fill=(120, 85, 50, 255), width=2)
		d.rectangle([26, angle_y - 1, 31, angle_y + 3], fill=(80, 80, 85, 255))
		save(im, out / f"pose_{i:02d}.png")


def pose_smith() -> None:
	out = POSE / "smith"
	for i in range(4):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)
		_body(d, 0, 0, (90, 90, 100, 255), (50, 50, 55, 255))
		# hammer raise/strike
		hy = (8, 4, 14, 10)[i]
		d.line([22, 18, 24, hy], fill=(100, 70, 40, 255), width=2)
		d.rectangle([21, hy - 2, 28, hy + 2], fill=(120, 120, 130, 255))
		# anvil cue
		d.rectangle([4, 36, 14, 42], fill=(70, 70, 75, 255))
		save(im, out / f"pose_{i:02d}.png")


def pose_stall() -> None:
	out = POSE / "stall"
	for i in range(4):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)
		_body(d, 0, 0, (180, 100, 70, 255), (60, 50, 80, 255))
		# basket offer
		bx = 20 + (0, 1, 2, 1)[i]
		by = 22 - (0, 2, 0, 2)[i]
		d.ellipse([bx, by, bx + 10, by + 8], fill=(160, 120, 60, 255))
		d.ellipse([bx + 2, by + 1, bx + 8, by + 4], fill=(200, 80, 60, 255))
		save(im, out / f"pose_{i:02d}.png")


def pose_cook() -> None:
	out = POSE / "cook"
	for i in range(4):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)
		_body(d, 0, 0, (240, 240, 235, 255), (80, 60, 50, 255))
		# ladle stir
		lx = 22
		ly = 20 + (0, 2, 4, 2)[i]
		d.line([18, 22, lx, ly], fill=(110, 80, 45, 255), width=2)
		d.ellipse([lx - 1, ly - 1, lx + 5, ly + 4], fill=(90, 90, 95, 255))
		# pot
		d.rectangle([6, 34, 16, 42], fill=(60, 60, 70, 255))
		if i % 2 == 0:
			d.ellipse([8, 30, 14, 34], fill=(200, 200, 210, 120))
		save(im, out / f"pose_{i:02d}.png")


def main() -> None:
	drawer_open()
	gate_log()
	pose_sow()
	pose_smith()
	pose_stall()
	pose_cook()


if __name__ == "__main__":
	main()
