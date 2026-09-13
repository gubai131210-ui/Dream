#!/usr/bin/env python3
"""Paint C54 life_poses from elder_woman walk frames + life-activity stamps."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "sprites" / "npc" / "elder_woman"
OUT = ROOT / "assets" / "sprites" / "npc" / "life_poses"
TMPL = (SRC / "walk_down_0.png.import").read_text(encoding="utf-8")

KINDS = {
	"eat": {"shirt": (160, 100, 90), "prop": (200, 160, 80)},
	"sleep": {"shirt": (90, 100, 140), "prop": (220, 210, 200)},
	"read": {"shirt": (120, 110, 90), "prop": (210, 200, 160)},
	"laundry": {"shirt": (100, 130, 150), "prop": (230, 230, 240)},
	"idle_sit": {"shirt": (140, 120, 100), "prop": (150, 110, 70)},
}


def write_import(path: Path, name: str) -> None:
	rel = f"npc/life_poses/{path.parent.name}/{name}"
	text = TMPL.replace("npc/elder_woman/walk_down_0.png", rel).replace("walk_down_0.png", name)
	uid = "uid://l" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(path.parent / f"{name}.import").write_text("".join(lines), encoding="utf-8")


def recolor(im: Image.Image, shirt: tuple[int, int, int]) -> Image.Image:
	out = im.copy()
	px = out.load()
	w, h = out.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a < 20:
				continue
			if 12 <= y <= 30 and 8 <= x <= 24:
				lum = (r + g + b) / 3
				if 40 < lum < 200:
					nr = int(r * 0.35 + shirt[0] * 0.65)
					ng = int(g * 0.35 + shirt[1] * 0.65)
					nb = int(b * 0.35 + shirt[2] * 0.65)
					nr = max(0, min(255, nr + ((x * y) % 7) - 3))
					ng = max(0, min(255, ng + ((x + y) % 5) - 2))
					nb = max(0, min(255, nb + ((x * 3 + y) % 5) - 2))
					px[x, y] = (nr, ng, nb, a)
	return out


def stamp_prop(im: Image.Image, kind: str, frame: int, rgb: tuple[int, int, int]) -> Image.Image:
	out = im.copy()
	px = out.load()
	w, h = out.size
	ox = 22 + (frame % 2)
	oy = 16 + (0, 1, 0, -1)[frame % 4]
	if kind == "eat":
		# bowl + spoon bob
		for yy in range(oy + 4, oy + 9):
			for xx in range(ox - 2, ox + 4):
				if 0 <= xx < w and 0 <= yy < h:
					px[xx, yy] = (*rgb, 245)
		for t in range(6):
			x, y = ox + 1, oy + t
			if 0 <= x < w and 0 <= y < h:
				px[x, y] = (180, 180, 190, 255)
	elif kind == "sleep":
		# pillow beside head
		for yy in range(8, 14):
			for xx in range(6, 14):
				if 0 <= xx < w and 0 <= yy < h:
					px[xx, yy] = (*rgb, 230)
	elif kind == "read":
		# open book
		for yy in range(oy + 2, oy + 8):
			for xx in range(ox - 3, ox + 5):
				if 0 <= xx < w and 0 <= yy < h:
					px[xx, yy] = (*rgb, 250)
		px[ox, oy + 3] = (120, 100, 70, 255)
	elif kind == "laundry":
		# hanging cloth
		for t in range(8):
			x, y = ox, oy + t
			if 0 <= x < w and 0 <= y < h:
				px[x, y] = (*rgb, 240)
				if x + 1 < w:
					px[x + 1, y] = (rgb[0] - 10, rgb[1] - 10, rgb[2] - 5, 220)
	else:  # idle_sit — small stool hint
		for yy in range(oy + 8, oy + 12):
			for xx in range(ox - 3, ox + 4):
				if 0 <= xx < w and 0 <= yy < h:
					px[xx, yy] = (*rgb, 245)
	return out


def uniq(im: Image.Image) -> int:
	return len({c[:3] for c in im.getdata() if c[3] > 200})


def main() -> None:
	sources = [Image.open(SRC / f"walk_down_{i}.png").convert("RGBA") for i in range(4)]
	for kind, cfg in KINDS.items():
		dest = OUT / kind
		dest.mkdir(parents=True, exist_ok=True)
		for i, src in enumerate(sources):
			frame = src.resize((32, 48), Image.Resampling.NEAREST)
			frame = recolor(frame, cfg["shirt"])
			frame = stamp_prop(frame, kind, i, cfg["prop"])
			name = f"pose_{i:02d}.png"
			frame.save(dest / name)
			write_import(dest / name, name)
			print(f"{kind}/{name} uniq={uniq(frame)}")


if __name__ == "__main__":
	main()
