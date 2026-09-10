#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build seamless multi-type grass + stone/dirt/water atlases.

Grass types (scientific / village maintenance logic):
  0-1 mowed   — near paths & plaza (trampled / kept short)
  2-3 meadow  — open yards
  4-5 tall    — edges, behind buildings, less foot traffic
  6   weed    — disturbed soil / fence corners
  7   damp    — riverbank moisture (cooler, darker green)

All tiles are wrap-seamless (L==R, T==B).
"""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image

if hasattr(sys.stdout, "reconfigure"):
	try:
		sys.stdout.reconfigure(encoding="utf-8")
	except Exception:
		pass

BASE = 32
REPO = Path(__file__).resolve().parents[2]
TILESETS = REPO / "dream" / "assets" / "tilesets"
OUT = REPO / "dream" / "assets" / "sliced" / "terrain_seamless"


def load_palette(atlas_path: Path, n: int = 6, grass_filter: bool = False) -> np.ndarray:
	im = np.array(Image.open(atlas_path).convert("RGBA"))
	rgb = im[:, :, :3][im[:, :, 3] > 200].astype(np.float32)
	if grass_filter:
		keep = (rgb[:, 1] > rgb[:, 0] * 0.85) & (rgb[:, 1] > rgb[:, 2] * 0.85) & (rgb[:, 1] > 35)
		if keep.sum() > 100:
			rgb = rgb[keep]
	rng = np.random.default_rng(2)
	idx = rng.choice(len(rgb), size=min(4000, len(rgb)), replace=False)
	pts = rgb[idx]
	centers = pts[rng.choice(len(pts), size=n, replace=False)]
	for _ in range(12):
		d = ((pts[:, None, :] - centers[None, :, :]) ** 2).sum(2)
		lab = d.argmin(1)
		for k in range(n):
			if (lab == k).any():
				centers[k] = pts[lab == k].mean(0)
	return np.clip(centers, 0, 255).astype(np.uint8)


def tileable_noise(size: int, scale: float, seed: int) -> np.ndarray:
	rng = np.random.default_rng(seed)
	gsize = int(size / scale) + 3
	g = rng.random((gsize, gsize))
	g[-1] = g[0]
	g[:, -1] = g[:, 0]
	ys = np.arange(size)[:, None] / scale
	xs = np.arange(size)[None, :] / scale
	x0 = np.floor(xs).astype(int) % (gsize - 1)
	y0 = np.floor(ys).astype(int) % (gsize - 1)
	x1 = (x0 + 1) % (gsize - 1)
	y1 = (y0 + 1) % (gsize - 1)
	tx = xs - np.floor(xs)
	ty = ys - np.floor(ys)
	return (g[y0, x0] * (1 - tx) + g[y0, x1] * tx) * (1 - ty) + (
		g[y1, x0] * (1 - tx) + g[y1, x1] * tx
	) * ty


def enforce_wrap(tile: np.ndarray) -> np.ndarray:
	tile = tile.copy()
	tile[:, -1] = tile[:, 0]
	tile[-1] = tile[0]
	tile[:, :, 3] = 255
	return tile


def shade_pal(pal: np.ndarray, brightness: float, cool: float = 0.0) -> list[np.ndarray]:
	out = []
	for c in sorted(list(pal), key=lambda x: float(np.mean(x))):
		v = c.astype(np.float32) * brightness
		v[2] = np.clip(v[2] + cool * 20.0, 0, 255)  # push blue for damp
		v[0] = np.clip(v[0] - cool * 10.0, 0, 255)
		out.append(np.clip(v, 0, 255).astype(np.uint8))
	return out


def fill_from_noise(mix: np.ndarray, pal: list[np.ndarray]) -> np.ndarray:
	tile = np.zeros((BASE, BASE, 4), np.uint8)
	for y in range(BASE):
		for x in range(BASE):
			idx = min(len(pal) - 1, int(mix[y, x] * len(pal)))
			tile[y, x, :3] = pal[idx]
			tile[y, x, 3] = 255
	return tile


def add_blades(tile: np.ndarray, pal: list[np.ndarray], count: int, height: int, seed: int) -> np.ndarray:
	rng = np.random.default_rng(seed)
	out = tile.copy()
	hi = pal[min(len(pal) - 1, len(pal) * 3 // 4) :]
	for _ in range(count):
		x = int(rng.integers(0, BASE))
		y = int(rng.integers(0, BASE))
		c = hi[int(rng.integers(0, len(hi)))]
		for dy in range(height):
			yy = (y - dy) % BASE
			out[yy, x, :3] = c
			if height > 2 and dy > 0 and rng.random() < 0.35:
				out[yy, (x + 1) % BASE, :3] = c
	return out


def add_weeds(tile: np.ndarray, seed: int) -> np.ndarray:
	rng = np.random.default_rng(seed)
	out = tile.copy()
	browns = [
		np.array([110, 95, 45], np.uint8),
		np.array([90, 70, 35], np.uint8),
		np.array([140, 120, 55], np.uint8),
	]
	for _ in range(22):
		x = int(rng.integers(0, BASE))
		y = int(rng.integers(0, BASE))
		c = browns[int(rng.integers(0, 3))]
		out[y, x, :3] = c
		out[(y + 1) % BASE, x, :3] = c
	return out


def make_grass_set(base_pal: np.ndarray) -> list[np.ndarray]:
	tiles: list[np.ndarray] = []
	# mowed x2 — fine noise, brighter, short blades
	for s in (0, 1):
		mix = 0.55 * tileable_noise(BASE, 6, 10 + s) + 0.45 * tileable_noise(BASE, 3, 20 + s)
		pal = shade_pal(base_pal, 1.08, cool=0.0)
		t = fill_from_noise(mix, pal)
		t = add_blades(t, pal, count=18, height=1, seed=100 + s)
		tiles.append(enforce_wrap(t))
	# meadow x2
	for s in (0, 1):
		mix = 0.4 * tileable_noise(BASE, 8, 30 + s) + 0.35 * tileable_noise(BASE, 4, 40 + s) + 0.25 * tileable_noise(BASE, 2, 50 + s)
		pal = shade_pal(base_pal, 1.0, cool=0.0)
		t = fill_from_noise(mix, pal)
		t = add_blades(t, pal, count=28, height=2, seed=200 + s)
		tiles.append(enforce_wrap(t))
	# tall / wild x2
	for s in (0, 1):
		mix = 0.35 * tileable_noise(BASE, 10, 60 + s) + 0.4 * tileable_noise(BASE, 4, 70 + s) + 0.25 * tileable_noise(BASE, 2, 80 + s)
		pal = shade_pal(base_pal, 0.92, cool=0.05)
		t = fill_from_noise(mix, pal)
		t = add_blades(t, pal, count=55, height=4, seed=300 + s)
		tiles.append(enforce_wrap(t))
	# weed
	mix = 0.5 * tileable_noise(BASE, 7, 90) + 0.5 * tileable_noise(BASE, 3, 91)
	pal = shade_pal(base_pal, 0.95, cool=0.0)
	t = add_weeds(add_blades(fill_from_noise(mix, pal), pal, 30, 2, 400), 401)
	tiles.append(enforce_wrap(t))
	# damp riverside — cooler mud + reed-like tall blades (bank-specific)
	mix = 0.35 * tileable_noise(BASE, 8, 110) + 0.35 * tileable_noise(BASE, 3, 111) + 0.3 * tileable_noise(BASE, 2, 112)
	pal = shade_pal(base_pal, 0.82, cool=0.75)
	# muddy darker base
	mud = [
		np.array([48, 72, 52], np.uint8),
		np.array([58, 78, 48], np.uint8),
		np.array([40, 58, 44], np.uint8),
	]
	t = fill_from_noise(mix, pal)
	rng = np.random.default_rng(503)
	for _ in range(40):
		x = int(rng.integers(0, BASE))
		y = int(rng.integers(0, BASE))
		c = mud[int(rng.integers(0, 3))]
		t[y, x, :3] = c
		t[(y + 1) % BASE, x, :3] = c
		t[y, (x + 1) % BASE, :3] = c
	t = add_blades(t, pal, 48, 4, 500)
	# sparse reed tips (olive)
	reed = np.array([70, 95, 40], np.uint8)
	for _ in range(12):
		x = int(rng.integers(0, BASE))
		y = int(rng.integers(0, BASE))
		for dy in range(5):
			t[(y - dy) % BASE, x, :3] = reed
	tiles.append(enforce_wrap(t))
	return tiles


def make_stone_set(pal: np.ndarray) -> list[np.ndarray]:
	tiles = []
	base = sorted(list(pal), key=lambda c: float(np.mean(c)))
	for s in range(6):
		mix = 0.65 * tileable_noise(BASE, 8, 200 + s) + 0.35 * tileable_noise(BASE, 3, 210 + s)
		t = np.zeros((BASE, BASE, 4), np.uint8)
		for y in range(BASE):
			for x in range(BASE):
				v = mix[y, x]
				crack = abs(np.sin((x + 3 + s) * 0.85) + np.cos((y + 5 - s) * 0.85))
				if crack < 0.12:
					v *= 0.72
				idx = min(len(base) - 1, int(v * len(base)))
				t[y, x, :3] = base[idx]
				t[y, x, 3] = 255
		tiles.append(enforce_wrap(t))
	return tiles


def make_water_set() -> list[np.ndarray]:
	pal = [
		np.array([28, 85, 155], np.uint8),
		np.array([36, 105, 175], np.uint8),
		np.array([48, 125, 195], np.uint8),
		np.array([60, 145, 210], np.uint8),
		np.array([22, 65, 125], np.uint8),
	]
	tiles = []
	for s in range(4):
		mix = 0.55 * tileable_noise(BASE, 8, 300 + s) + 0.45 * tileable_noise(BASE, 3, 310 + s)
		tiles.append(enforce_wrap(fill_from_noise(mix, pal)))
	return tiles


def pack(tiles: list[np.ndarray], path: Path, cols: int = 4) -> None:
	rows = (len(tiles) + cols - 1) // cols
	atlas = Image.new("RGBA", (cols * BASE, rows * BASE), (0, 0, 0, 0))
	for i, t in enumerate(tiles):
		atlas.paste(Image.fromarray(t), ((i % cols) * BASE, (i // cols) * BASE))
	atlas.save(path)
	print("wrote", path.name, "n=", len(tiles), "size=", atlas.size)
	assert np.array_equal(tiles[0][:, 0], tiles[0][:, -1])


def main() -> None:
	gpal = load_palette(TILESETS / "grass_atlas.png", grass_filter=True)
	spal = load_palette(TILESETS / "stone_atlas.png")
	dpal = load_palette(TILESETS / "dirt_atlas.png")
	grass = make_grass_set(gpal)
	stone = make_stone_set(spal)
	dirt = make_grass_set(dpal)[:6]
	water = make_water_set()
	(OUT / "grass").mkdir(parents=True, exist_ok=True)
	for i, t in enumerate(grass):
		Image.fromarray(t).save(OUT / "grass" / f"tile_{i:02d}.png")
	pack(grass, TILESETS / "grass_seamless_atlas.png", cols=4)
	pack(stone, TILESETS / "stone_seamless_atlas.png", cols=4)
	pack(dirt, TILESETS / "dirt_seamless_atlas.png", cols=4)
	pack(water, TILESETS / "water_seamless_atlas.png", cols=4)
	# labeled preview strip
	preview = Image.new("RGBA", (BASE * 8, BASE))
	labels = ["mow0", "mow1", "mead0", "mead1", "tall0", "tall1", "weed", "damp"]
	for i, t in enumerate(grass):
		preview.paste(Image.fromarray(t), (i * BASE, 0))
	preview.save(TILESETS / "grass_types_preview.png")
	print("types", labels)


if __name__ == "__main__":
	main()
