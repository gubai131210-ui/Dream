#!/usr/bin/env python3
"""Repaint C53 work_poses from farmer walk frames + occupational recolors (painted density)."""
from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
FARMER = ROOT / "assets" / "sprites" / "npc" / "farmer"
OUT = ROOT / "assets" / "sprites" / "npc" / "work_poses"
TMPL = (FARMER / "walk_down_0.png.import").read_text(encoding="utf-8")

# Occupational clothing/tool bias (multiplicative-ish via channel mix).
KINDS = {
	"sow": {"shirt": (70, 130, 70), "tool": (120, 90, 50)},
	"smith": {"shirt": (90, 90, 110), "tool": (160, 160, 170)},
	"stall": {"shirt": (160, 90, 70), "tool": (180, 140, 80)},
	"cook": {"shirt": (220, 220, 230), "tool": (140, 100, 60)},
}


def write_import(path: Path, name: str) -> None:
	rel = f"npc/work_poses/{path.parent.name}/{name}"
	text = TMPL.replace("npc/farmer/walk_down_0.png", rel).replace("walk_down_0.png", name)
	uid = "uid://w" + uuid.uuid4().hex[:12]
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
			# Mid torso greens/browns → shirt bias
			if 12 <= y <= 30 and 8 <= x <= 24:
				lum = (r + g + b) / 3
				if 40 < lum < 200:
					nr = int(r * 0.35 + shirt[0] * 0.65)
					ng = int(g * 0.35 + shirt[1] * 0.65)
					nb = int(b * 0.35 + shirt[2] * 0.65)
					# keep some noise
					nr = max(0, min(255, nr + ((x * y) % 7) - 3))
					ng = max(0, min(255, ng + ((x + y) % 5) - 2))
					nb = max(0, min(255, nb + ((x * 3 + y) % 5) - 2))
					px[x, y] = (nr, ng, nb, a)
	return out


def stamp_tool(im: Image.Image, kind: str, frame: int, tool_rgb: tuple[int, int, int]) -> Image.Image:
	out = im.copy()
	px = out.load()
	w, h = out.size
	# Hand-side tool bob by frame
	ox = 22 + (frame % 2)
	oy = 18 + (0, 1, 0, -1)[frame % 4]
	if kind == "sow":
		# short hoe shaft
		for t in range(10):
			x, y = ox, oy + t
			if 0 <= x < w and 0 <= y < h:
				px[x, y] = (*tool_rgb, 255)
				if x + 1 < w:
					px[x + 1, y] = (tool_rgb[0] - 20, tool_rgb[1] - 15, tool_rgb[2] - 10, 230)
		for dx in range(-2, 4):
			x, y = ox + dx, oy + 10
			if 0 <= x < w and 0 <= y < h:
				px[x, y] = (90, 90, 95, 255)
	elif kind == "smith":
		for t in range(8):
			x, y = ox, oy + t
			if 0 <= x < w and 0 <= y < h:
				px[x, y] = (*tool_rgb, 255)
		for dx in range(-3, 4):
			x, y = ox + dx, oy
			if 0 <= x < w and 0 <= y < h:
				px[x, y] = (170, 170, 180, 255)
	elif kind == "stall":
		for yy in range(oy, oy + 6):
			for xx in range(ox - 2, ox + 4):
				if 0 <= xx < w and 0 <= yy < h:
					px[xx, yy] = (*tool_rgb, 240)
	else:  # cook ladle
		for t in range(9):
			x, y = ox, oy + t
			if 0 <= x < w and 0 <= y < h:
				px[x, y] = (*tool_rgb, 255)
		for dx in range(-2, 3):
			for dy in range(-2, 2):
				x, y = ox + dx, oy + dy
				if 0 <= x < w and 0 <= y < h:
					px[x, y] = (160, 160, 170, 250)
	return out


def uniq(im: Image.Image) -> int:
	return len({c[:3] for c in im.getdata() if c[3] > 200})


def main() -> None:
	sources = [Image.open(FARMER / f"walk_down_{i}.png").convert("RGBA") for i in range(4)]
	for kind, cfg in KINDS.items():
		dest = OUT / kind
		dest.mkdir(parents=True, exist_ok=True)
		for i, src in enumerate(sources):
			# Fit to 32x48 canvas, feet on bottom.
			frame = src.resize((32, 48), Image.Resampling.NEAREST)
			frame = recolor(frame, cfg["shirt"])
			frame = stamp_tool(frame, kind, i, cfg["tool"])
			name = f"pose_{i:02d}.png"
			frame.save(dest / name)
			write_import(dest / name, name)
			print(f"{kind}/{name} uniq={uniq(frame)}")


if __name__ == "__main__":
	main()
