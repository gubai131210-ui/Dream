#!/usr/bin/env python3
"""Deep-paint C53/C54 pose sheets: contact tools/props, not walk-recolor + face stamps.

Keeps 32×48 ×4, transparent BG, feet planted. Re-run qa_work_pose_style after.
Also paints outdoor prop book_open_00 for C54 read cue.
"""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
FARMER = ROOT / "assets" / "sprites" / "npc" / "farmer"
ELDER = ROOT / "assets" / "sprites" / "npc" / "elder_woman"
WORK_OUT = ROOT / "assets" / "sprites" / "npc" / "work_poses"
LIFE_OUT = ROOT / "assets" / "sprites" / "npc" / "life_poses"
PROP_OUT = ROOT / "assets" / "sprites" / "props"
WORK_TMPL = (FARMER / "walk_down_0.png.import").read_text(encoding="utf-8")
LIFE_TMPL = (ELDER / "walk_down_0.png.import").read_text(encoding="utf-8")
PROP_TMPL = (PROP_OUT / "bench_0.png.import").read_text(encoding="utf-8")

WORK = {
	"sow": {"shirt": (62, 118, 58), "tool": (118, 88, 48)},
	"smith": {"shirt": (78, 78, 98), "tool": (168, 168, 178)},
	"stall": {"shirt": (158, 82, 62), "tool": (188, 148, 78)},
	"cook": {"shirt": (228, 228, 236), "tool": (138, 98, 58)},
}
LIFE = {
	"eat": {"shirt": (150, 92, 82), "accent": (210, 170, 90)},
	"sleep": {"shirt": (82, 92, 138), "accent": (230, 220, 210)},
	"read": {"shirt": (112, 100, 82), "accent": (220, 208, 168)},
	"laundry": {"shirt": (92, 124, 146), "accent": (236, 236, 244)},
	"idle_sit": {"shirt": (132, 112, 92), "accent": (148, 108, 68)},
}


def write_npc_import(tmpl: str, old_rel: str, dest: Path, name: str, uid_prefix: str) -> None:
	rel = f"npc/{dest.parent.name}/{dest.name}/{name}" if dest.parent.name in ("work_poses", "life_poses") else f"npc/{dest.name}/{name}"
	# work: npc/work_poses/smith/pose_00.png
	parts = dest.parts
	idx = parts.index("npc")
	rel = "/".join(parts[idx:]) + f"/{name}"
	text = tmpl.replace(old_rel, rel).replace(Path(old_rel).name, name)
	uid = f"uid://{uid_prefix}" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(dest / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def write_prop_import(path: Path, name: str) -> None:
	rel = f"props/{name}"
	text = PROP_TMPL.replace("props/bench_0.png", rel).replace("bench_0.png", name)
	uid = "uid://p" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(path.parent / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def recolor_torso(im: Image.Image, shirt: tuple[int, int, int]) -> Image.Image:
	out = im.copy()
	px = out.load()
	w, h = out.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a < 20:
				continue
			if 12 <= y <= 32 and 7 <= x <= 25:
				lum = (r + g + b) / 3
				if 35 < lum < 210:
					nr = int(r * 0.28 + shirt[0] * 0.72)
					ng = int(g * 0.28 + shirt[1] * 0.72)
					nb = int(b * 0.28 + shirt[2] * 0.72)
					nr = max(0, min(255, nr + ((x * y) % 7) - 3))
					ng = max(0, min(255, ng + ((x + y) % 5) - 2))
					nb = max(0, min(255, nb + ((x * 3 + y) % 5) - 2))
					px[x, y] = (nr, ng, nb, a)
	return out


def put(px, w, h, x, y, rgba) -> None:
	if 0 <= x < w and 0 <= y < h:
		px[x, y] = rgba


def draw_rect(px, w, h, x0, y0, x1, y1, rgba) -> None:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			put(px, w, h, x, y, rgba)


def work_stamp(im: Image.Image, kind: str, frame: int, tool: tuple[int, int, int]) -> Image.Image:
	out = im.copy()
	px = out.load()
	w, h = out.size
	bob = (0, 2, 0, -2)[frame % 4]
	swing = (-1, 0, 1, 0)[frame % 4]
	if kind == "sow":
		# hoe: shaft down-right, blade at soil
		ox, oy = 20 + swing, 20 + bob
		for t in range(12):
			put(px, w, h, ox, oy + t, (*tool, 255))
			put(px, w, h, ox + 1, oy + t, (tool[0] - 18, tool[1] - 12, tool[2] - 8, 230))
		for dx in range(-3, 5):
			put(px, w, h, ox + dx, oy + 11, (88, 88, 92, 255))
		# dirt flecks
		put(px, w, h, ox + 2, oy + 13, (110, 80, 45, 220))
		put(px, w, h, ox - 1, oy + 14, (100, 72, 40, 200))
	elif kind == "smith":
		# hammer raised→strike
		hx = 21 + swing
		hy = 12 + bob
		for t in range(7):
			put(px, w, h, hx, hy + t, (120, 90, 55, 255))
		for dx in range(-3, 4):
			for dy in range(-2, 2):
				put(px, w, h, hx + dx, hy + dy, (*tool, 255))
		# spark on strike frames
		if frame % 2 == 1:
			put(px, w, h, hx + 4, hy + 8, (255, 230, 120, 255))
			put(px, w, h, hx + 5, hy + 7, (255, 200, 80, 230))
	elif kind == "stall":
		# produce crate held at mid
		cx, cy = 19 + swing, 22 + bob
		draw_rect(px, w, h, cx - 3, cy, cx + 5, cy + 6, (*tool, 245))
		draw_rect(px, w, h, cx - 2, cy + 1, cx + 4, cy + 3, (70, 140, 70, 240))
		put(px, w, h, cx + 1, cy + 2, (200, 60, 50, 255))
	else:  # cook
		lx, ly = 21 + swing, 18 + bob
		for t in range(10):
			put(px, w, h, lx, ly + t, (*tool, 255))
		for dx in range(-3, 4):
			for dy in range(-2, 3):
				if abs(dx) + abs(dy) <= 3:
					put(px, w, h, lx + dx, ly + dy, (170, 170, 180, 250))
		# steam
		put(px, w, h, lx - 2, ly - 3 - bob, (220, 230, 240, 180))
		put(px, w, h, lx, ly - 5 - bob, (230, 235, 245, 160))
	return out


def life_stamp(im: Image.Image, kind: str, frame: int, accent: tuple[int, int, int]) -> Image.Image:
	out = im.copy()
	px = out.load()
	w, h = out.size
	bob = (0, 1, 0, -1)[frame % 4]
	if kind == "eat":
		# bowl at chest (not face)
		bx, by = 11, 24 + bob
		draw_rect(px, w, h, bx, by, bx + 8, by + 4, (*accent, 250))
		draw_rect(px, w, h, bx + 1, by + 1, bx + 7, by + 2, (180, 90, 50, 245))
		# spoon
		for t in range(5):
			put(px, w, h, bx + 9, by - 1 + t, (190, 190, 200, 255))
	elif kind == "sleep":
		# closed eyes
		for x in range(11, 15):
			put(px, w, h, x, 12, (40, 40, 50, 255))
		for x in range(17, 21):
			put(px, w, h, x, 12, (40, 40, 50, 255))
		# pillow left
		draw_rect(px, w, h, 4, 10, 10, 16, (*accent, 235))
		# Z drift
		zx = 24 + (frame % 2)
		zy = 6 - bob
		put(px, w, h, zx, zy, (90, 90, 120, 230))
		put(px, w, h, zx + 1, zy - 1, (90, 90, 120, 200))
		put(px, w, h, zx + 2, zy - 3, (90, 90, 120, 180))
	elif kind == "read":
		# open book held mid-torso (clear of face)
		bx, by = 9, 22 + bob
		draw_rect(px, w, h, bx, by, bx + 12, by + 7, (*accent, 250))
		# spine
		for y in range(by, by + 8):
			put(px, w, h, bx + 6, y, (110, 90, 55, 255))
		# text lines
		for y in (by + 2, by + 4, by + 6):
			for x in range(bx + 1, bx + 5):
				put(px, w, h, x, y, (90, 80, 60, 220))
			for x in range(bx + 8, bx + 12):
				put(px, w, h, x, y, (90, 80, 60, 220))
	elif kind == "laundry":
		# washboard + cloth motion
		wx, wy = 20, 18 + bob
		draw_rect(px, w, h, wx, wy, wx + 6, wy + 10, (160, 140, 110, 245))
		for y in range(wy + 1, wy + 10, 2):
			for x in range(wx + 1, wx + 6):
				put(px, w, h, x, y, (130, 115, 90, 230))
		# wet cloth
		for t in range(7):
			put(px, w, h, wx - 2 + (frame % 2), wy + 2 + t, (*accent, 240))
	else:  # idle_sit — knees + stool
		draw_rect(px, w, h, 10, 34, 22, 38, (*accent, 245))
		draw_rect(px, w, h, 12, 30, 20, 33, (accent[0] - 20, accent[1] - 15, accent[2] - 10, 240))
		# hands on knees
		put(px, w, h, 11, 28, (230, 190, 160, 255))
		put(px, w, h, 20, 28, (230, 190, 160, 255))
	return out


def paint_book_prop() -> None:
	im = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([4, 8, 27, 26], fill=(210, 195, 155, 255), outline=(90, 70, 45, 255))
	d.line([16, 8, 16, 26], fill=(100, 80, 50, 255))
	d.rectangle([6, 11, 14, 13], fill=(80, 70, 55, 220))
	d.rectangle([6, 15, 14, 17], fill=(80, 70, 55, 220))
	d.rectangle([18, 11, 25, 13], fill=(80, 70, 55, 220))
	d.rectangle([18, 15, 25, 17], fill=(80, 70, 55, 220))
	name = "book_open_00.png"
	im.save(PROP_OUT / name)
	write_prop_import(PROP_OUT / name, name)
	print(f"props/{name}")


def paint_bowl_prop() -> None:
	im = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	# ceramic bowl
	d.ellipse([6, 12, 26, 28], fill=(220, 210, 190, 255), outline=(90, 75, 55, 255))
	d.ellipse([9, 14, 23, 22], fill=(180, 90, 50, 245))  # stew
	d.rectangle([20, 8, 22, 16], fill=(190, 190, 200, 255))  # spoon handle
	d.ellipse([18, 6, 24, 11], fill=(190, 190, 200, 255))
	name = "bowl_00.png"
	im.save(PROP_OUT / name)
	write_prop_import(PROP_OUT / name, name)
	print(f"props/{name}")


def paint_pillow_prop() -> None:
	"""C54 sleep cue — plush case with seam/stitch (Genre soft-pillow note)."""
	im = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
	px = im.load()
	w, h = 32, 32
	# contact shadow
	for y in range(22, 29):
		for x in range(7, 26):
			dx = (x - 16) / 9.5
			dy = (y - 25.5) / 3.2
			if dx * dx + dy * dy <= 1.0:
				a = int(80 * (1.0 - (dx * dx + dy * dy)))
				put(px, w, h, x, y, (35, 30, 25, a))
	# pillow oval body with fabric ramp
	for y in range(9, 27):
		for x in range(4, 28):
			dx = (x - 16) / 11.0
			dy = (y - 17.5) / 7.5
			r2 = dx * dx + dy * dy
			if r2 > 1.0:
				continue
			# base cream → warm shade by height
			t = (y - 9) / 17.0
			edge = max(0.0, r2 - 0.72) / 0.28
			r = int(248 - t * 38 - edge * 55)
			g = int(236 - t * 42 - edge * 50)
			b = int(214 - t * 48 - edge * 40)
			# subtle weave dither
			if (x + y * 3) % 5 == 0:
				r = max(0, r - 8)
				g = max(0, g - 6)
			if (x * 2 + y) % 7 == 0:
				r = min(255, r + 10)
				g = min(255, g + 8)
			# top highlight lobe
			if dx * dx * 1.4 + ((y - 13) / 4.0) ** 2 < 0.55 and y < 18:
				r = min(255, r + 18)
				g = min(255, g + 14)
				b = min(255, b + 10)
			put(px, w, h, x, y, (r, g, b, 255))
	# outline
	for y in range(9, 27):
		for x in range(4, 28):
			dx = (x - 16) / 11.0
			dy = (y - 17.5) / 7.5
			r2 = dx * dx + dy * dy
			if 0.88 <= r2 <= 1.02:
				put(px, w, h, x, y, (92, 74, 52, 255))
	# center seam + stitches
	for y in range(12, 24):
		put(px, w, h, 16, y, (150, 128, 100, 255))
		if y % 2 == 0:
			put(px, w, h, 15, y, (130, 110, 85, 255))
			put(px, w, h, 17, y, (130, 110, 85, 255))
	# case stripe
	for x in range(8, 25):
		put(px, w, h, x, 16, (175, 145, 110, 220))
		put(px, w, h, x, 17, (210, 185, 150, 200))
	# corner puffs
	for cx, cy in ((6, 15), (26, 15)):
		for y in range(cy - 1, cy + 2):
			for x in range(cx - 1, cx + 2):
				put(px, w, h, x, y, (220, 205, 180, 255))
	name = "pillow_00.png"
	im.save(PROP_OUT / name)
	write_prop_import(PROP_OUT / name, name)
	print(f"props/{name} uniq={uniq(im)}")


def uniq(im: Image.Image) -> int:
	return len({c[:3] for c in im.getdata() if c[3] > 200})


def main() -> None:
	paint_book_prop()
	paint_bowl_prop()
	paint_pillow_prop()
	farmer = [Image.open(FARMER / f"walk_down_{i}.png").convert("RGBA") for i in range(4)]
	elder = [Image.open(ELDER / f"walk_down_{i}.png").convert("RGBA") for i in range(4)]
	for kind, cfg in WORK.items():
		dest = WORK_OUT / kind
		dest.mkdir(parents=True, exist_ok=True)
		for i, src in enumerate(farmer):
			frame = src.resize((32, 48), Image.Resampling.NEAREST)
			frame = recolor_torso(frame, cfg["shirt"])
			frame = work_stamp(frame, kind, i, cfg["tool"])
			name = f"pose_{i:02d}.png"
			frame.save(dest / name)
			write_npc_import(WORK_TMPL, "npc/farmer/walk_down_0.png", dest, name, "w")
			print(f"work/{kind}/{name} uniq={uniq(frame)}")
	for kind, cfg in LIFE.items():
		dest = LIFE_OUT / kind
		dest.mkdir(parents=True, exist_ok=True)
		for i, src in enumerate(elder):
			frame = src.resize((32, 48), Image.Resampling.NEAREST)
			frame = recolor_torso(frame, cfg["shirt"])
			frame = life_stamp(frame, kind, i, cfg["accent"])
			name = f"pose_{i:02d}.png"
			frame.save(dest / name)
			write_npc_import(LIFE_TMPL, "npc/elder_woman/walk_down_0.png", dest, name, "l")
			print(f"life/{kind}/{name} uniq={uniq(frame)}")


if __name__ == "__main__":
	main()
