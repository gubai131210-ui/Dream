#!/usr/bin/env python3
"""Crop baked water-island bases from tree sprites.

Reads assets/sprites/trees/tree_XX.png, removes the miniature pond
(water ring + lily pads + large grey rocks), keeps trunk + canopy +
a small grass/soil mound, and writes:

  assets/sprites/trees/grounded/tree_XX.png
  assets/sprites/trees/grounded/meta.json

Nearest-neighbor only (no blur). Originals are left intact.
"""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT / "assets" / "sprites" / "trees"
OUT_DIR = SRC_DIR / "grounded"

# Vertical pad of grass/soil kept below the last clean trunk/green row.
GRASS_KEEP = 7
# Horizontal pad around opaque content after masking.
BBOX_PAD = 1
ALPHA_ON = 32


def _is_water(r: np.ndarray, g: np.ndarray, b: np.ndarray, a: np.ndarray) -> np.ndarray:
    """Blue water / pond pixels."""
    ri = r.astype(np.int16)
    gi = g.astype(np.int16)
    bi = b.astype(np.int16)
    return (
        (a > ALPHA_ON)
        & (bi > ri + 12)
        & (bi > gi)
        & (bi > 70)
        & (bi < 230)
        & (ri < 160)
    )


def _is_grey_rock(r: np.ndarray, g: np.ndarray, b: np.ndarray, a: np.ndarray) -> np.ndarray:
    """Grey boulder / rock pixels (not green foliage, not water)."""
    ri = r.astype(np.int16)
    gi = g.astype(np.int16)
    bi = b.astype(np.int16)
    water = _is_water(r, g, b, a)
    greenish = (gi > ri + 8) & (gi > bi + 8)
    return (
        (a > ALPHA_ON)
        & ~water
        & ~greenish
        & (np.abs(ri - gi) < 28)
        & (np.abs(gi - bi) < 28)
        & (np.abs(ri - bi) < 28)
        & (ri > 55)
        & (ri < 190)
    )


def _is_green(r: np.ndarray, g: np.ndarray, b: np.ndarray, a: np.ndarray) -> np.ndarray:
    ri = r.astype(np.int16)
    gi = g.astype(np.int16)
    bi = b.astype(np.int16)
    return (a > ALPHA_ON) & (gi > ri + 8) & (gi > bi + 8)


def _is_trunk_or_soil(r: np.ndarray, g: np.ndarray, b: np.ndarray, a: np.ndarray) -> np.ndarray:
    """Brown trunk / soil (not rock-grey)."""
    ri = r.astype(np.int16)
    gi = g.astype(np.int16)
    bi = b.astype(np.int16)
    return (
        (a > ALPHA_ON)
        & (ri > gi)
        & (ri > bi)
        & (ri > 40)
        & (gi < ri - 5)
        & (bi < ri - 10)
    )


def _dilate(mask: np.ndarray, radius: int = 2) -> np.ndarray:
    """Cheap binary dilation via max-filter style loops."""
    if radius <= 0:
        return mask
    out = mask.copy()
    h, w = mask.shape
    for dy in range(-radius, radius + 1):
        for dx in range(-radius, radius + 1):
            if dx == 0 and dy == 0:
                continue
            if dx * dx + dy * dy > radius * radius:
                continue
            ys = slice(max(0, dy), h + min(0, dy))
            xs = slice(max(0, dx), w + min(0, dx))
            src_ys = slice(max(0, -dy), h - max(0, dy))
            src_xs = slice(max(0, -dx), w - max(0, dx))
            out[ys, xs] |= mask[src_ys, src_xs]
    return out


def _lily_pads(green: np.ndarray, water: np.ndarray) -> np.ndarray:
    """Green pixels adjacent to water — lily pads on the pond."""
    return green & _dilate(water, radius=3)


def find_island_cut(rgba: np.ndarray) -> tuple[int, dict]:
    """Return exclusive bottom y (crop_y1) before island dominates.

    Scans upward from the image bottom. Island rows are those where
    water+rock+lily dominate opaque pixels, or water alone is high.
    The cut is the first non-island row from the bottom, then we keep
    GRASS_KEEP extra rows for a grass/soil mound (masked later).
    """
    h, w = rgba.shape[:2]
    r, g, b, a = rgba[:, :, 0], rgba[:, :, 1], rgba[:, :, 2], rgba[:, :, 3]
    water = _is_water(r, g, b, a)
    rock = _is_grey_rock(r, g, b, a)
    green = _is_green(r, g, b, a)
    trunk = _is_trunk_or_soil(r, g, b, a)
    lily = _lily_pads(green, water)
    opaque = a > ALPHA_ON
    island = water | rock | lily

    # Scan from bottom: find first row that is clearly "tree" not island.
    clean_y = None
    for y in range(h - 1, h // 2, -1):
        op = int(opaque[y].sum())
        if op < max(4, w // 20):
            continue  # empty / fringe
        isl = int(island[y].sum())
        wat = int(water[y].sum())
        tr = int(trunk[y].sum())
        gr = int((green[y] & ~lily[y]).sum())
        isl_frac = isl / op
        wat_frac = wat / op
        tree_frac = (tr + gr) / op
        # Island-dominated bottom ring
        if wat_frac >= 0.15 or isl_frac >= 0.35:
            continue
        # Prefer rows with real trunk/grass presence
        if tree_frac >= 0.40 or (tr >= 12 and wat_frac < 0.10 and isl_frac < 0.25):
            clean_y = y
            break

    if clean_y is None:
        # Fallback: first row where water frac drops below 0.15
        for y in range(h - 1, h // 2, -1):
            op = int(opaque[y].sum())
            if op < 4:
                continue
            if float(water[y].sum()) / op < 0.15:
                clean_y = y
                break
    if clean_y is None:
        clean_y = int(h * 0.78)

    # Keep a small grass mound under the clean line (may still contain
    # some island pixels — those get masked out below).
    crop_y1 = min(h, clean_y + 1 + GRASS_KEEP)

    info = {
        "clean_y": int(clean_y),
        "crop_y1_before_bbox": int(crop_y1),
        "grass_keep": GRASS_KEEP,
    }
    return crop_y1, info


def mask_island(rgba: np.ndarray, crop_y1: int) -> np.ndarray:
    """Zero alpha for water / lily / peripheral rocks; keep grass near feet."""
    out = rgba.copy()
    h, w = out.shape[:2]
    r, g, b, a = out[:, :, 0], out[:, :, 1], out[:, :, 2], out[:, :, 3]
    water = _is_water(r, g, b, a)
    rock = _is_grey_rock(r, g, b, a)
    green = _is_green(r, g, b, a)
    trunk = _is_trunk_or_soil(r, g, b, a)
    lily = _lily_pads(green, water)

    # Trunk center from mid-body (avoid canopy extremes and island).
    y0 = h // 3
    y1 = max(y0 + 1, int(h * 0.72))
    body = trunk[y0:y1] | (green[y0:y1] & ~lily[y0:y1])
    xs = np.where(body.any(axis=0))[0]
    if len(xs) == 0:
        cx = w // 2
    else:
        cx = int(xs.mean())

    # Max horizontal radius for keep-zone near the base (tight mound).
    mound_half = max(10, w // 5)

    drop = np.zeros((h, w), dtype=bool)
    # Always remove water + lily pads everywhere.
    drop |= water | lily

    # Remove grey rocks in the lower third / island zone (baked boulders).
    # Keep rocks only if high up (canopy texture) — lower rocks go.
    rock_cut = int(h * 0.62)
    drop |= rock & (np.arange(h)[:, None] >= rock_cut)

    # Below clean grass zone: only keep trunk/green/soil near center.
    # Everything else in the keep-pad band that is far from trunk → clear.
    yy = np.arange(h)[:, None]
    xx = np.arange(w)[None, :]
    in_mound_band = yy >= (crop_y1 - GRASS_KEEP)
    near_trunk = np.abs(xx - cx) <= mound_half
    keep_mound = (trunk | (green & ~lily) | _is_trunk_or_soil(r, g, b, a)) & near_trunk
    # Also allow a little green grass slightly wider
    keep_mound |= (green & ~lily) & (np.abs(xx - cx) <= mound_half + 4)
    drop |= in_mound_band & ~keep_mound & (a > ALPHA_ON)

    # Hard crop below crop_y1
    drop |= yy >= crop_y1

    out[:, :, 3] = np.where(drop, 0, a)
    # Clear RGB on fully transparent for cleaner files
    clear = out[:, :, 3] == 0
    out[clear, 0:3] = 0
    return out


def trim_sparse_bottom(rgba: np.ndarray, min_opaque: int = 5) -> np.ndarray:
    """Drop trailing rows that are nearly empty after island masking."""
    a = rgba[:, :, 3]
    h = a.shape[0]
    y1 = h
    while y1 > 1 and int((a[y1 - 1] > ALPHA_ON).sum()) < min_opaque:
        y1 -= 1
    if y1 >= h:
        return rgba
    out = rgba.copy()
    out[y1:, :, 3] = 0
    out[y1:, :, 0:3] = 0
    return out


def tight_bbox(rgba: np.ndarray, pad: int = BBOX_PAD) -> tuple[int, int, int, int]:
    a = rgba[:, :, 3]
    ys, xs = np.where(a > ALPHA_ON)
    if len(xs) == 0:
        h, w = a.shape
        return 0, 0, w, h
    x0 = max(0, int(xs.min()) - pad)
    y0 = max(0, int(ys.min()) - pad)
    x1 = min(a.shape[1], int(xs.max()) + 1 + pad)
    # No bottom pad — avoids a fully transparent trailing row under the feet.
    y1 = min(a.shape[0], int(ys.max()) + 1)
    return x0, y0, x1, y1


def process_tree(src: Path, dst: Path) -> dict:
    im = Image.open(src).convert("RGBA")
    rgba = np.array(im)
    src_w, src_h = im.size

    crop_y1, cut_info = find_island_cut(rgba)
    masked = mask_island(rgba, crop_y1)
    masked = trim_sparse_bottom(masked)
    x0, y0, x1, y1 = tight_bbox(masked)
    cropped = masked[y0:y1, x0:x1]

    dst.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(cropped, mode="RGBA").save(dst, optimize=True)

    return {
        "file": dst.name,
        "source": src.name,
        "src_size": [src_w, src_h],
        "out_size": [int(cropped.shape[1]), int(cropped.shape[0])],
        "crop_box": [int(x0), int(y0), int(x1), int(y1)],  # xyxy exclusive in source space
        "island_cut": cut_info,
        "filter": "NEAREST",
    }


def main() -> None:
    sources = sorted(SRC_DIR.glob("tree_*.png"))
    if not sources:
        raise SystemExit(f"No tree_*.png under {SRC_DIR}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    entries = []
    print(f"Writing grounded trees -> {OUT_DIR}")
    for src in sources:
        dst = OUT_DIR / src.name
        meta = process_tree(src, dst)
        entries.append(meta)
        print(
            f"  {src.name}: {meta['src_size'][0]}x{meta['src_size'][1]}"
            f" -> {meta['out_size'][0]}x{meta['out_size'][1]}"
            f"  crop={meta['crop_box']}  clean_y={meta['island_cut']['clean_y']}"
        )

    meta_path = OUT_DIR / "meta.json"
    payload = {
        "description": "Tree sprites with water-island bases removed; trunk+canopy+small grass mound retained.",
        "source_dir": "assets/sprites/trees",
        "output_dir": "assets/sprites/trees/grounded",
        "grass_keep": GRASS_KEEP,
        "trees": entries,
    }
    meta_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"Wrote {meta_path}")


if __name__ == "__main__":
    main()
