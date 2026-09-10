#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Rebuild seamless terrain atlases (wrap-matched procedural tiles from source palettes).

See dream/docs/SEAMLESS.md.
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


def load_palette(atlas_path: Path, n: int = 5, grass_filter: bool = False) -> np.ndarray:
	im = np.array(Image.open(atlas_path).convert("RGBA"))
	rgb = im[:, :, :3][im[:, :, 3] > 200].astype(np.float32)
	if grass_filter:
		keep = (rgb[:, 1] > rgb[:, 0] * 0.9) & (rgb[:, 1] > rgb[:, 2] * 0.9) & (rgb[:, 1] > 40)
		if keep.sum() > 100:
			rgb = rgb[keep]
	rng = np.random.default_rng(1)
	idx = rng.choice(len(rgb), size=min(3000, len(rgb)), replace=False)
	pts = rgb[idx]
	centers = pts[rng.choice(len(pts), size=n, replace=False)]
	for _ in range(10):
		d = ((pts[:, None, :] - centers[None, :, :]) ** 2).sum(2)
		lab = d.argmin(1)
		for k in range(n):
			if (lab == k).any():
				centers[k] = pts[lab == k].mean(0)
	return np.clip(centers, 0, 255).astype(np.uint8)


def tileable_noise(size: int, scale: int, seed: int) -> np.ndarray:
	rng = np.random.default_rng(seed)
	gsize = size // scale + 2
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
	v00 = g[y0, x0]
	v10 = g[y0, x1]
	v01 = g[y1, x0]
	v11 = g[y1, x1]
	return (v00 * (1 - tx) + v10 * tx) * (1 - ty) + (v01 * (1 - tx) + v11 * tx) * ty


def make_soft(pal: np.ndarray, seed: int) -> np.ndarray:
	mix = (
		0.4 * tileable_noise(BASE, 8, seed)
		+ 0.35 * tileable_noise(BASE, 4, seed + 2)
		+ 0.25 * tileable_noise(BASE, 2, seed + 4)
	)
	pal_s = sorted(list(pal), key=lambda c: float(np.mean(c)))
	tile = np.zeros((BASE, BASE, 4), np.uint8)
	for y in range(BASE):
		for x in range(BASE):
			idx = min(len(pal_s) - 1, int(mix[y, x] * len(pal_s)))
			tile[y, x, :3] = pal_s[idx]
			tile[y, x, 3] = 255
	rng = np.random.default_rng(seed + 50)
	for _ in range(40):
		x = int(rng.integers(0, BASE))
		y = int(rng.integers(0, BASE))
		c = pal_s[int(rng.integers(len(pal_s) // 2, len(pal_s)))]
		tile[y, x, :3] = c
		tile[(y - 1) % BASE, x, :3] = c
	tile[:, -1] = tile[:, 0]
	tile[-1] = tile[0]
	return tile


def make_stone(pal: np.ndarray, seed: int) -> np.ndarray:
	mix = 0.65 * tileable_noise(BASE, 8, seed) + 0.35 * tileable_noise(BASE, 3, seed + 1)
	pal_s = sorted(list(pal), key=lambda c: float(np.mean(c)))
	tile = np.zeros((BASE, BASE, 4), np.uint8)
	for y in range(BASE):
		for x in range(BASE):
			v = mix[y, x]
			crack = abs(np.sin((x + 3) * 0.9) + np.cos((y + 5) * 0.9))
			if crack < 0.15:
				v *= 0.75
			idx = min(len(pal_s) - 1, int(v * len(pal_s)))
			tile[y, x, :3] = pal_s[idx]
			tile[y, x, 3] = 255
	tile[:, -1] = tile[:, 0]
	tile[-1] = tile[0]
	return tile


def pack(tiles: list[np.ndarray], path: Path, cols: int = 4) -> None:
	rows = (len(tiles) + cols - 1) // cols
	atlas = Image.new("RGBA", (cols * BASE, rows * BASE))
	for i, t in enumerate(tiles):
		atlas.paste(Image.fromarray(t), ((i % cols) * BASE, (i // cols) * BASE))
	atlas.save(path)
	print("wrote", path.name, len(tiles))


def main() -> None:
	gpal = load_palette(TILESETS / "grass_atlas.png", grass_filter=True)
	spal = load_palette(TILESETS / "stone_atlas.png")
	dpal = load_palette(TILESETS / "dirt_atlas.png")
	grass = [make_soft(gpal, s) for s in range(8)]
	stone = [make_stone(spal, s) for s in range(6)]
	dirt = [make_soft(dpal, s + 30) for s in range(6)]
	(OUT / "grass").mkdir(parents=True, exist_ok=True)
	for i, t in enumerate(grass):
		Image.fromarray(t).save(OUT / "grass" / f"tile_{i:02d}.png")
	pack(grass, TILESETS / "grass_seamless_atlas.png")
	pack(stone, TILESETS / "stone_seamless_atlas.png")
	pack(dirt, TILESETS / "dirt_seamless_atlas.png")
	preview = Image.new("RGBA", (BASE * 6, BASE * 4))
	tile0 = Image.fromarray(grass[0])
	for y in range(4):
		for x in range(6):
			preview.paste(tile0, (x * BASE, y * BASE))
	preview.save(TILESETS / "grass_seamless_preview_field.png")
	assert np.array_equal(grass[0][:, 0], grass[0][:, -1])
	assert np.array_equal(grass[0][0], grass[0][-1])
	print("edge wrap OK")


if __name__ == "__main__":
	main()
