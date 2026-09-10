# -*- coding: utf-8 -*-
"""Slice / normalize raw Dream sheets into BASE_TILE=32 gameplay assets.

Uses PIL Image.Resampling.NEAREST only. See dream/docs/SCALE.md.
"""
from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

import numpy as np
from PIL import Image

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_TILE = 32
COTTAGE_H = 5 * BASE_TILE  # 160
LARGE_H = 7 * BASE_TILE  # 224
BLACK_THR = 18
NEAREST = Image.Resampling.NEAREST

REPO = Path(__file__).resolve().parents[2]
RAW = REPO / "dream" / "assets" / "raw"
SLICED = REPO / "dream" / "assets" / "sliced"

failures: list[str] = []
counts: dict[str, int] = {
    "grass": 0,
    "path": 0,
    "water": 0,
    "props": 0,
    "buildings": 0,
}


def load_rgb(path: Path) -> tuple[Image.Image, np.ndarray]:
    im = Image.open(path).convert("RGBA")
    return im, np.array(im.convert("RGB"))


def content_mask(rgb: np.ndarray, thr: int = BLACK_THR) -> np.ndarray:
    return ~((rgb[:, :, 0] <= thr) & (rgb[:, :, 1] <= thr) & (rgb[:, :, 2] <= thr))


def to_rgba_keyed(rgb: np.ndarray, thr: int = BLACK_THR) -> Image.Image:
    mask = content_mask(rgb, thr)
    rgba = np.zeros((rgb.shape[0], rgb.shape[1], 4), dtype=np.uint8)
    rgba[:, :, :3] = rgb
    rgba[:, :, 3] = np.where(mask, 255, 0)
    return Image.fromarray(rgba, "RGBA")


def content_bbox(mask: np.ndarray) -> tuple[int, int, int, int] | None:
    ys, xs = np.where(mask)
    if len(xs) == 0:
        return None
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def find_gaps(occ: np.ndarray, min_gap: int = 3) -> list[tuple[int, int]]:
    gaps: list[tuple[int, int]] = []
    n = len(occ)
    i = 0
    while i < n:
        j = i
        while j < n and bool(occ[j]) == bool(occ[i]):
            j += 1
        if not occ[i] and (j - i) >= min_gap:
            gaps.append((i, j))
        i = j
    return gaps


def gap_centers(gaps: list[tuple[int, int]], lo: int, hi: int) -> list[int]:
    seps: list[int] = []
    for a, b in gaps:
        if b <= lo or a >= hi:
            continue
        seps.append((a + b) // 2)
    return sorted(seps)


def cells_from_separators(seps: list[int], start: int, end: int) -> list[tuple[int, int]]:
    bounds = [start] + seps + [end]
    cells: list[tuple[int, int]] = []
    for i in range(len(bounds) - 1):
        a, b = bounds[i], bounds[i + 1]
        if b - a >= 8:
            cells.append((a, b))
    return cells


def slice_regular_grid(
    rgba: Image.Image,
    rgb: np.ndarray,
    expect_cols: int = 12,
    expect_rows: int = 8,
) -> list[Image.Image]:
    mask = content_mask(rgb)
    bbox = content_bbox(mask)
    if bbox is None:
        return []
    x0, y0, x1, y1 = bbox
    row_occ = mask.any(axis=1)
    col_occ = mask.any(axis=0)
    col_seps = gap_centers(find_gaps(col_occ, 3), x0, x1)
    row_seps = gap_centers(find_gaps(row_occ, 3), y0, y1)

    if abs(len(col_seps) - (expect_cols - 1)) > 3 or abs(len(row_seps) - (expect_rows - 1)) > 3:
        cw = (x1 - x0) / expect_cols
        rh = (y1 - y0) / expect_rows
        col_seps = [int(x0 + cw * i) for i in range(1, expect_cols)]
        row_seps = [int(y0 + rh * i) for i in range(1, expect_rows)]

    cols = cells_from_separators(col_seps, x0, x1)
    rows = cells_from_separators(row_seps, y0, y1)
    tiles: list[Image.Image] = []
    for ry0, ry1 in rows:
        for cx0, cx1 in cols:
            cell = rgba.crop((cx0, ry0, cx1, ry1))
            carr = np.array(cell.convert("RGB"))
            cb = content_bbox(content_mask(carr))
            if cb is None:
                continue
            cell = to_rgba_keyed(np.array(cell.crop(cb).convert("RGB")))
            tiles.append(cell.resize((BASE_TILE, BASE_TILE), NEAREST))
    return tiles


def connected_components(
    mask: np.ndarray,
    min_area: int = 400,
    downsample: int = 4,
) -> list[tuple[int, int, int, int]]:
    h, w = mask.shape
    small = mask[::downsample, ::downsample] if downsample > 1 else mask
    sh, sw = small.shape
    visited = np.zeros_like(small, dtype=bool)
    boxes: list[tuple[int, int, int, int, int]] = []
    for y in range(sh):
        for x in range(sw):
            if not small[y, x] or visited[y, x]:
                continue
            stack = [(y, x)]
            visited[y, x] = True
            minx = maxx = x
            miny = maxy = y
            area = 0
            while stack:
                cy, cx = stack.pop()
                area += 1
                minx = min(minx, cx)
                maxx = max(maxx, cx)
                miny = min(miny, cy)
                maxy = max(maxy, cy)
                for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                    if 0 <= ny < sh and 0 <= nx < sw and small[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = True
                        stack.append((ny, nx))
            if area >= max(1, min_area // (downsample * downsample)):
                boxes.append((minx, miny, maxx + 1, maxy + 1, area))

    out: list[tuple[int, int, int, int]] = []
    for minx, miny, maxx, maxy, _area in boxes:
        x0 = max(0, minx * downsample - downsample)
        y0 = max(0, miny * downsample - downsample)
        x1 = min(w, maxx * downsample + downsample)
        y1 = min(h, maxy * downsample + downsample)
        bb = content_bbox(mask[y0:y1, x0:x1])
        if bb is None:
            continue
        sx0, sy0, sx1, sy1 = bb
        out.append((x0 + sx0, y0 + sy0, x0 + sx1, y0 + sy1))
    out.sort(key=lambda b: (b[1] // 40, b[0]))
    return out


def extract_cc_tiles(
    rgba: Image.Image,
    rgb: np.ndarray,
    min_area: int = 800,
    target_size: tuple[int, int] | None = (BASE_TILE, BASE_TILE),
    downsample: int = 4,
) -> list[Image.Image]:
    tiles: list[Image.Image] = []
    for x0, y0, x1, y1 in connected_components(content_mask(rgb), min_area, downsample):
        cell = to_rgba_keyed(np.array(rgba.crop((x0, y0, x1, y1)).convert("RGB")))
        if target_size is not None:
            cell = cell.resize(target_size, NEAREST)
        tiles.append(cell)
    return tiles


def scale_height_nn(im: Image.Image, target_h: int) -> Image.Image:
    w, h = im.size
    if h <= 0:
        return im
    return im.resize((max(1, int(round(w * (target_h / h)))), target_h), NEAREST)


def write_meta(path: Path, payload: dict) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def clear_dir(d: Path) -> None:
    if d.exists():
        shutil.rmtree(d)
    d.mkdir(parents=True, exist_ok=True)


def slice_grass() -> None:
    src = RAW / "B01-01_grass.png"
    out_dir = SLICED / "terrain" / "grass"
    clear_dir(out_dir)
    if not src.is_file():
        failures.append(f"missing {src.name}")
        return
    print(f"Slicing grass grid from {src.name} ...")
    _im, rgb = load_rgb(src)
    rgba = to_rgba_keyed(rgb)
    tiles = slice_regular_grid(rgba, rgb, 12, 8)
    if len(tiles) < 40:
        print(f"  grid yielded {len(tiles)}; falling back to CC")
        tiles = extract_cc_tiles(rgba, rgb, min_area=2000)
    for i, tile in enumerate(tiles, start=1):
        tile.save(out_dir / f"grass_{i:03d}.png")
        counts["grass"] += 1
    write_meta(
        out_dir / "meta.json",
        {
            "source": src.name,
            "base_tile": BASE_TILE,
            "method": "grid_12x8_or_cc",
            "count": counts["grass"],
            "target_size": [BASE_TILE, BASE_TILE],
            "resampling": "NEAREST",
        },
    )
    print(f"  grass tiles: {counts['grass']}")


def slice_paths() -> None:
    prefer = RAW / "B02_path_dirt_trail.png"
    candidates = sorted(RAW.glob("B02_path_*.png"))
    out_dir = SLICED / "terrain" / "path"
    clear_dir(out_dir)
    if prefer.is_file():
        src = prefer
    elif candidates:
        src = candidates[0]
    else:
        failures.append("no B02_path_*.png in raw/")
        return
    print(f"Slicing paths from {src.name} ...")
    _im, rgb = load_rgb(src)
    rgba = to_rgba_keyed(rgb)
    tiles = slice_regular_grid(rgba, rgb, 8, 6)
    if len(tiles) < 8:
        tiles = extract_cc_tiles(rgba, rgb, min_area=1500)
    for i, tile in enumerate(tiles, start=1):
        tile.save(out_dir / f"path_{i:03d}.png")
        counts["path"] += 1
    write_meta(
        out_dir / "meta.json",
        {
            "source": src.name,
            "base_tile": BASE_TILE,
            "count": counts["path"],
            "target_size": [BASE_TILE, BASE_TILE],
            "resampling": "NEAREST",
        },
    )
    print(f"  path tiles: {counts['path']}")


def slice_water() -> None:
    src = RAW / "B03_water_lake.png"
    if not src.is_file():
        cands = sorted(RAW.glob("B03_water_*.png"))
        src = cands[0] if cands else None  # type: ignore
    out_dir = SLICED / "terrain" / "water"
    clear_dir(out_dir)
    if src is None or not Path(src).is_file():
        failures.append("no B03 water sheet found")
        return
    print(f"Slicing water from {src.name} ...")
    _im, rgb = load_rgb(src)
    rgba = to_rgba_keyed(rgb)
    tiles = slice_regular_grid(rgba, rgb, 8, 6)
    if len(tiles) < 8:
        tiles = extract_cc_tiles(rgba, rgb, min_area=1200)
    for i, tile in enumerate(tiles, start=1):
        tile.save(out_dir / f"water_{i:03d}.png")
        counts["water"] += 1
    write_meta(
        out_dir / "meta.json",
        {
            "source": src.name,
            "base_tile": BASE_TILE,
            "count": counts["water"],
            "target_size": [BASE_TILE, BASE_TILE],
            "resampling": "NEAREST",
            "note": "lake sheet preferred when identifiable",
        },
    )
    print(f"  water tiles: {counts['water']}")


def slice_props() -> None:
    sheets = sorted(RAW.glob("B11-*.png"))
    out_dir = SLICED / "props"
    clear_dir(out_dir)
    if not sheets:
        failures.append("no B11-*.png in raw/")
        return
    meta_items: list[dict] = []
    for sheet in sheets:
        print(f"Slicing props from {sheet.name} ...")
        _im, rgb = load_rgb(sheet)
        rgba = to_rgba_keyed(rgb)
        boxes = connected_components(content_mask(rgb), min_area=600, downsample=3)
        for i, (x0, y0, x1, y1) in enumerate(boxes, start=1):
            cell = to_rgba_keyed(np.array(rgba.crop((x0, y0, x1, y1)).convert("RGB")))
            h = cell.size[1]
            if h > 96:
                target_h = 96
            elif h > 48:
                target_h = 48
            elif h < 16:
                target_h = 16
            else:
                target_h = h
            if target_h != h:
                cell = scale_height_nn(cell, target_h)
            name = f"{sheet.stem}_{i:02d}.png"
            cell.save(out_dir / name)
            counts["props"] += 1
            meta_items.append(
                {
                    "file": name,
                    "source": sheet.name,
                    "size": list(cell.size),
                    "target_height_px": cell.size[1],
                }
            )
    write_meta(
        out_dir / "meta.json",
        {
            "base_tile": BASE_TILE,
            "count": counts["props"],
            "resampling": "NEAREST",
            "items": meta_items,
            "prop_height_band_px": [16, 96],
        },
    )
    print(f"  prop sprites: {counts['props']}")


def slice_buildings() -> None:
    sheets = sorted(RAW.glob("B08-*.png"))
    out_dir = SLICED / "buildings"
    clear_dir(out_dir)
    if not sheets:
        failures.append("no B08-*.png in raw/")
        return
    meta_items: list[dict] = []
    for sheet in sheets:
        print(f"Slicing buildings from {sheet.name} ...")
        _im, rgb = load_rgb(sheet)
        rgba = to_rgba_keyed(rgb)
        boxes = [
            b
            for b in connected_components(content_mask(rgb), min_area=8000, downsample=4)
            if (b[2] - b[0]) * (b[3] - b[1]) >= 20000
        ]
        for i, (x0, y0, x1, y1) in enumerate(boxes, start=1):
            cell = to_rgba_keyed(np.array(rgba.crop((x0, y0, x1, y1)).convert("RGB")))
            native_h = cell.size[1]
            target_h = LARGE_H if native_h >= 480 else COTTAGE_H
            cell = scale_height_nn(cell, target_h)
            name = f"{sheet.stem}_{i:02d}.png"
            cell.save(out_dir / name)
            counts["buildings"] += 1
            meta_items.append(
                {
                    "file": name,
                    "source": sheet.name,
                    "native_bbox": [x0, y0, x1, y1],
                    "native_height": native_h,
                    "target_height_px": target_h,
                    "target_height_tiles": target_h / BASE_TILE,
                    "size": list(cell.size),
                    "role": "landmark" if target_h == LARGE_H else "cottage",
                }
            )
    write_meta(
        out_dir / "meta.json",
        {
            "base_tile": BASE_TILE,
            "cottage_height_px": COTTAGE_H,
            "large_height_px": LARGE_H,
            "count": counts["buildings"],
            "resampling": "NEAREST",
            "items": meta_items,
        },
    )
    print(f"  building sprites: {counts['buildings']}")


def main() -> int:
    if not RAW.is_dir():
        print(f"ERROR: raw dir missing: {RAW}")
        return 1
    SLICED.mkdir(parents=True, exist_ok=True)

    for fn, label in (
        (slice_grass, "grass"),
        (slice_paths, "path"),
        (slice_water, "water"),
        (slice_props, "props"),
        (slice_buildings, "buildings"),
    ):
        try:
            fn()
        except Exception as e:
            failures.append(f"{label}: {e}")
            print(f"FAIL {label}: {e}")

    total = sum(counts.values())
    summary = {
        "base_tile": BASE_TILE,
        "counts": counts,
        "total_sliced": total,
        "failures": failures,
    }
    write_meta(SLICED / "meta.json", summary)
    print("==== SLICE SUMMARY ====")
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
