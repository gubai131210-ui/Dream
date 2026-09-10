#!/usr/bin/env python3
"""Slice landmark props from B04/B07/B08 raw sheets into gameplay PNGs.

Uses near-black keying + connected-component bboxes. Black becomes alpha.
Does not paste reference maps or touch scene assemblers.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "assets" / "raw"
PROPS = ROOT / "assets" / "sprites" / "props"
FX = ROOT / "assets" / "sprites" / "fx"
BUILDINGS = ROOT / "assets" / "sprites" / "buildings"

BLACK_SUM = 30  # sum(RGB) < this → empty / transparent
PAD = 2


@dataclass
class Blob:
    area: int
    x0: int
    y0: int
    x1: int  # exclusive
    y1: int  # exclusive

    @property
    def w(self) -> int:
        return self.x1 - self.x0

    @property
    def h(self) -> int:
        return self.y1 - self.y0

    @property
    def cx(self) -> float:
        return (self.x0 + self.x1 - 1) / 2.0

    @property
    def cy(self) -> float:
        return (self.y0 + self.y1 - 1) / 2.0

    @property
    def bbox(self) -> tuple[int, int, int, int]:
        return (self.x0, self.y0, self.x1, self.y1)


def find_blobs(rgb: np.ndarray, min_area: int, black_sum: int = BLACK_SUM) -> list[Blob]:
    """4-connected components on non-near-black pixels."""
    mask = rgb.astype(np.int32).sum(axis=2) >= black_sum
    h, w = mask.shape
    visited = np.zeros((h, w), dtype=bool)
    blobs: list[Blob] = []

    for y in range(h):
        for x in range(w):
            if not mask[y, x] or visited[y, x]:
                continue
            q: deque[tuple[int, int]] = deque([(y, x)])
            visited[y, x] = True
            minx = maxx = x
            miny = maxy = y
            area = 0
            while q:
                cy, cx = q.popleft()
                area += 1
                if cx < minx:
                    minx = cx
                if cx > maxx:
                    maxx = cx
                if cy < miny:
                    miny = cy
                if cy > maxy:
                    maxy = cy
                for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                    if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = True
                        q.append((ny, nx))
            if area >= min_area:
                blobs.append(Blob(area, minx, miny, maxx + 1, maxy + 1))
    return blobs


def to_rgba_keyed(im: Image.Image, black_sum: int = BLACK_SUM) -> Image.Image:
    rgba = im.convert("RGBA")
    arr = np.asarray(rgba).copy()
    empty = arr[:, :, 0:3].astype(np.int32).sum(axis=2) < black_sum
    arr[empty, 3] = 0
    return Image.fromarray(arr, "RGBA")


def crop_blob(rgba: Image.Image, blob: Blob, pad: int = PAD) -> Image.Image:
    w, h = rgba.size
    x0 = max(0, blob.x0 - pad)
    y0 = max(0, blob.y0 - pad)
    x1 = min(w, blob.x1 + pad)
    y1 = min(h, blob.y1 + pad)
    return rgba.crop((x0, y0, x1, y1))


def save_png(im: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path, "PNG")
    print(f"  wrote {path.relative_to(ROOT)}  {im.size[0]}x{im.size[1]}")


def load_sheet(name: str) -> tuple[Image.Image, np.ndarray, Image.Image]:
    path = RAW / name
    rgb_im = Image.open(path).convert("RGB")
    rgba = to_rgba_keyed(rgb_im)
    return rgb_im, np.asarray(rgb_im), rgba


def slice_waterfall() -> None:
    print("\n== B04 waterfall ==")
    _, arr, rgba = load_sheet("B04_waterfall_01.png")
    blobs = find_blobs(arr, min_area=150)
    by_area = sorted(blobs, key=lambda b: -b.area)

    tall = [b for b in by_area if b.cy < 400 and b.h >= 300]
    mid = [b for b in by_area if 450 < b.cy < 750 and b.h >= 200]
    # Bottom row: left = splash bases (wide), right = mist clouds
    bottom = [b for b in by_area if b.cy > 1050 and b.area >= 8000]
    splash = [b for b in bottom if b.cx < 650 and (b.w / max(b.h, 1)) >= 1.1]
    mist = [b for b in bottom if b.cx >= 650]

    if not tall or not mid or not splash:
        raise RuntimeError(
            f"waterfall pick failed: tall={len(tall)} mid={len(mid)} splash={len(splash)}"
        )

    picks = [
        ("waterfall_tall_00.png", PROPS, tall[0]),
        ("waterfall_mid_00.png", PROPS, mid[0]),
        ("waterfall_splash_00.png", PROPS, splash[0]),
    ]
    for name, folder, blob in picks:
        print(
            f"  pick {name}: area={blob.area} {blob.w}x{blob.h} "
            f"@({blob.x0},{blob.y0})"
        )
        save_png(crop_blob(rgba, blob), folder / name)

    # 1–2 mist blobs if separable
    mist_sorted = sorted(mist, key=lambda b: -b.area)[:2]
    for i, blob in enumerate(mist_sorted):
        name = f"waterfall_mist_{i:02d}.png"
        print(f"  pick {name}: area={blob.area} {blob.w}x{blob.h} @({blob.x0},{blob.y0})")
        save_png(crop_blob(rgba, blob), FX / name)


def slice_rocks() -> None:
    print("\n== B07 rocks ==")
    _, arr, rgba = load_sheet("B07_rocks_03.png")
    # Medium+ large: ignore tiny pebbles
    blobs = find_blobs(arr, min_area=8000)
    picks = sorted(blobs, key=lambda b: -b.area)[:6]
    for i, blob in enumerate(picks):
        name = f"rock_{i:02d}.png"
        print(f"  pick {name}: area={blob.area} {blob.w}x{blob.h} @({blob.x0},{blob.y0})")
        save_png(crop_blob(rgba, blob), PROPS / name)


def slice_special_buildings() -> None:
    print("\n== B08 special buildings ==")
    _, arr, rgba = load_sheet("B08-05_special.png")
    # Ignore sparkles / tiny noise
    blobs = find_blobs(arr, min_area=5000)
    if len(blobs) < 2:
        raise RuntimeError(f"expected >=2 building blobs, got {len(blobs)}")

    # Lighthouse: top-left island; dock/boathouse: bottom-left
    upper = [b for b in blobs if b.cy < 500]
    lower = [b for b in blobs if b.cy > 600]
    if not upper or not lower:
        raise RuntimeError(f"building rows missing: upper={len(upper)} lower={len(lower)}")
    lighthouse = min(upper, key=lambda b: b.cx)
    dock = min(lower, key=lambda b: b.cx)

    picks = [
        ("lighthouse_00.png", lighthouse),
        ("dock_house_00.png", dock),
    ]
    for name, blob in picks:
        print(f"  pick {name}: area={blob.area} {blob.w}x{blob.h} @({blob.x0},{blob.y0})")
        save_png(crop_blob(rgba, blob), BUILDINGS / name)


def main() -> None:
    slice_waterfall()
    slice_rocks()
    slice_special_buildings()
    print("\nDone.")


if __name__ == "__main__":
    main()
