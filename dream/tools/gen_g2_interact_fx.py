#!/usr/bin/env python3
"""Author minimal fixed-canvas G2 interaction FX frames (Nearest-friendly RGBA)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
FX = ROOT / "assets" / "sprites" / "fx"
PROPS = ROOT / "assets" / "sprites" / "props"


def blank(w: int, h: int) -> Image.Image:
	return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def save(img: Image.Image, path: Path) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	img.save(path)
	print("wrote", path.relative_to(ROOT), img.size)


def leaf_fall() -> None:
	# 32x32 — leaf drifts down-right across 4 frames; pivot ~[16,28]
	palette = [(70, 140, 60, 255), (90, 160, 70, 255), (50, 110, 45, 255)]
	positions = [(10, 6), (14, 12), (18, 18), (20, 24)]
	for i, (x, y) in enumerate(positions):
		im = blank(32, 32)
		d = ImageDraw.Draw(im)
		c = palette[i % len(palette)]
		d.ellipse([x, y, x + 8, y + 5], fill=c)
		d.line([x + 4, y + 2, x + 4, y + 7], fill=(40, 80, 30, 255))
		save(im, FX / f"leaf_fall_{i:02d}.png")


def well_rope() -> None:
	# 32x48 — rope drops from top attach; well body stays separate
	for i in range(4):
		im = blank(32, 48)
		d = ImageDraw.Draw(im)
		length = 10 + i * 6
		d.rectangle([14, 4, 17, 4 + length], fill=(120, 90, 55, 255))
		# bucket at end
		by = 4 + length
		d.rectangle([11, by, 20, by + 7], fill=(90, 110, 140, 255))
		d.rectangle([12, by + 1, 19, by + 3], fill=(160, 190, 210, 200))
		save(im, PROPS / f"well_rope_{i:02d}.png")


def crate_lid() -> None:
	# 48x32 — lid opens upward (hinge near bottom of lid strip)
	for i in range(4):
		im = blank(48, 32)
		d = ImageDraw.Draw(im)
		# lift amount
		lift = i * 3
		y0 = 18 - lift
		d.rectangle([6, y0, 41, y0 + 8], fill=(150, 105, 60, 255))
		d.rectangle([8, y0 + 2, 39, y0 + 5], fill=(170, 125, 75, 255))
		if i >= 2:
			# ajar gap shadow
			d.rectangle([8, y0 + 8, 39, y0 + 10], fill=(40, 25, 15, 120))
		save(im, PROPS / f"crate_lid_{i:02d}.png")


def bird_peck() -> None:
	# 32x32 — small bird peck cycle; feet at bottom
	for i in range(4):
		im = blank(32, 32)
		d = ImageDraw.Draw(im)
		body_y = 18 if i in (0, 3) else 20
		head_y = body_y - (6 if i == 2 else 4)
		d.ellipse([10, body_y, 22, body_y + 8], fill=(90, 70, 55, 255))
		d.ellipse([18, head_y, 26, head_y + 6], fill=(80, 60, 50, 255))
		beak_y = head_y + 3
		if i == 2:
			d.polygon([(26, beak_y), (31, beak_y + 2), (26, beak_y + 4)], fill=(200, 160, 60, 255))
		else:
			d.polygon([(26, beak_y), (30, beak_y + 1), (26, beak_y + 3)], fill=(200, 160, 60, 255))
		# feet
		d.line([14, 28, 14, 30], fill=(40, 30, 20, 255))
		d.line([18, 28, 18, 30], fill=(40, 30, 20, 255))
		save(im, FX / f"bird_peck_{i:02d}.png")


def board_rustle() -> None:
	# 32x32 — paper corner lifts on notice/sign; fixed canvas, pivot ~center.
	for i in range(4):
		im = blank(32, 32)
		d = ImageDraw.Draw(im)
		# board plate (static anchor — not part of motion body beyond slight shade)
		d.rectangle([6, 8, 25, 26], fill=(150, 118, 70, 255))
		d.rectangle([8, 10, 23, 24], fill=(210, 200, 165, 255))
		# paper flap lifts up-right
		lift = i * 2
		d.polygon(
			[
				(18, 12 - lift // 2),
				(26, 10 - lift),
				(26, 18 - lift // 2),
				(20, 18),
			],
			fill=(235, 225, 190, 255),
		)
		if i >= 2:
			d.line([20, 14, 25, 12 - lift // 2], fill=(120, 100, 70, 200))
		save(im, FX / f"board_rustle_{i:02d}.png")


def bench_dust() -> None:
	# 32x24 — soft dust puff under seat; bottoms aligned.
	for i in range(4):
		im = blank(32, 24)
		d = ImageDraw.Draw(im)
		# rising motes
		base = [
			(10, 18 - i),
			(16, 16 - i * 2),
			(22, 18 - i),
			(13, 14 - i),
		]
		for j, (x, y) in enumerate(base):
			r = 1 + (i + j) % 2
			a = 180 - i * 30
			d.ellipse([x, y, x + r * 2, y + r * 2], fill=(190, 175, 140, max(40, a)))
		save(im, FX / f"bench_dust_{i:02d}.png")


def fish_splash() -> None:
	# 32x24 — shore splash expands then thins; bottom waterline fixed ~y=20.
	# Replaces single fish_splash_00 with a 4-frame oneshot for C22 cage / bite FX.
	water = (120, 175, 210, 230)
	foam = (220, 235, 245, 255)
	shadow = (70, 120, 150, 160)
	for i in range(4):
		im = blank(32, 24)
		d = ImageDraw.Draw(im)
		spread = 6 + i * 3
		cy = 18
		# ellipse ripple
		d.ellipse(
			[16 - spread, cy - 3 - i // 2, 16 + spread, cy + 2],
			outline=water,
			width=1 + (0 if i > 1 else 1),
		)
		# crown jets
		jet_h = 4 + i
		d.rectangle([15, cy - jet_h, 17, cy], fill=foam)
		if i >= 1:
			d.rectangle([11, cy - jet_h + 2, 12, cy - 1], fill=water)
			d.rectangle([20, cy - jet_h + 2, 21, cy - 1], fill=water)
		if i >= 2:
			d.point((9, cy - 2), fill=foam)
			d.point((23, cy - 2), fill=foam)
		if i == 3:
			# thinning outer ring
			d.ellipse([16 - spread - 1, cy - 2, 16 + spread + 1, cy + 1], outline=shadow, width=1)
		# fixed bottom waterline pixels (anchor)
		d.rectangle([10, 20, 22, 21], fill=water)
		save(im, FX / f"fish_splash_{i:02d}.png")


def lamp_spark() -> None:
	# 24x32 — lamp flame/spark pop at top; foot of spark near y=28 (post attach).
	core = (255, 230, 140, 255)
	glow = (255, 180, 70, 220)
	ember = (220, 90, 40, 200)
	for i in range(4):
		im = blank(24, 32)
		d = ImageDraw.Draw(im)
		# post tip hint (static anchor, not moving)
		d.rectangle([11, 26, 13, 30], fill=(90, 75, 55, 255))
		h = 6 + i * 2
		cx, cy = 12, 24 - h
		d.ellipse([cx - 2 - i // 2, cy, cx + 2 + i // 2, cy + 5 + i // 2], fill=glow)
		d.ellipse([cx - 1, cy + 1, cx + 1, cy + 4], fill=core)
		if i >= 1:
			d.point((cx - 3 - i, cy + 1), fill=ember)
			d.point((cx + 3 + i, cy + 2), fill=ember)
		if i >= 2:
			d.point((cx, cy - 1), fill=core)
		if i == 3:
			# fade sparks outward
			d.point((cx - 5, cy + 3), fill=(255, 200, 100, 120))
			d.point((cx + 5, cy + 3), fill=(255, 200, 100, 120))
		save(im, FX / f"lamp_spark_{i:02d}.png")


def main() -> None:
	# Append-only helpers: do not rewrite shipped leaf/well/crate/bird by default.
	lamp_spark()


if __name__ == "__main__":
	main()
