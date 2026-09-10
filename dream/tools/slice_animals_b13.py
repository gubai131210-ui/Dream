#!/usr/bin/env python3
"""Slice B13 animal sheets into idle/walk frames under assets/sprites/animals/.

Sheets (manual ID from visual QA):
  01 sheep, 02 deer, 03 cat, 04 cow, 05 dog
No chicken/bird sheets in B13_animals_01..05 — catalog records that gap.
"""

from __future__ import annotations

import json
from collections import deque
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "assets" / "raw"
OUT = ROOT / "assets" / "sprites" / "animals"

BLACK_SUM = 30
PAD = 2
MIN_AREA = 400

# Species guess per sheet index (1-based filenames).
SHEETS: list[dict] = [
    {"file": "B13_animals_01.png", "id": "sheep", "zh": "羊", "min_area": 800},
    {"file": "B13_animals_02.png", "id": "deer", "zh": "鹿", "min_area": 800},
    {"file": "B13_animals_03.png", "id": "cat", "zh": "猫", "min_area": 400},
    {"file": "B13_animals_04.png", "id": "cow", "zh": "牛", "min_area": 1000},
    {"file": "B13_animals_05.png", "id": "dog", "zh": "狗", "min_area": 500},
]


@dataclass
class Blob:
    area: int
    x0: int
    y0: int
    x1: int
    y1: int

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


def find_blobs(rgb: np.ndarray, min_area: int) -> list[Blob]:
    mask = rgb.astype(np.int32).sum(axis=2) >= BLACK_SUM
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
                minx = min(minx, cx)
                maxx = max(maxx, cx)
                miny = min(miny, cy)
                maxy = max(maxy, cy)
                for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                    if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = True
                        q.append((ny, nx))
            if area >= min_area:
                blobs.append(Blob(area, minx, miny, maxx + 1, maxy + 1))
    return blobs


def to_rgba_keyed(im: Image.Image) -> Image.Image:
    rgba = im.convert("RGBA")
    arr = np.asarray(rgba).copy()
    empty = arr[:, :, 0:3].astype(np.int32).sum(axis=2) < BLACK_SUM
    arr[empty, 3] = 0
    return Image.fromarray(arr, "RGBA")


def crop_blob(rgba: Image.Image, blob: Blob, pad: int = PAD) -> Image.Image:
    w, h = rgba.size
    x0 = max(0, blob.x0 - pad)
    y0 = max(0, blob.y0 - pad)
    x1 = min(w, blob.x1 + pad)
    y1 = min(h, blob.y1 + pad)
    return rgba.crop((x0, y0, x1, y1))


def cluster_rows(blobs: list[Blob], gap: float = 40.0) -> list[list[Blob]]:
    if not blobs:
        return []
    ordered = sorted(blobs, key=lambda b: b.cy)
    rows: list[list[Blob]] = [[ordered[0]]]
    for b in ordered[1:]:
        if abs(b.cy - rows[-1][-1].cy) <= gap:
            rows[-1].append(b)
        else:
            rows.append([b])
    for row in rows:
        row.sort(key=lambda b: b.cx)
    return rows


def slice_sheet(meta: dict) -> dict:
    path = RAW / meta["file"]
    rgb_im = Image.open(path).convert("RGB")
    rgba = to_rgba_keyed(rgb_im)
    arr = np.asarray(rgb_im)
    blobs = find_blobs(arr, int(meta["min_area"]))
    # Drop tiny noise / grass-only crumbs by median area
    if blobs:
        areas = sorted(b.area for b in blobs)
        med = areas[len(areas) // 2]
        blobs = [b for b in blobs if b.area >= max(meta["min_area"], med * 0.35)]
    rows = cluster_rows(blobs, gap=max(36.0, float(rgb_im.size[1]) * 0.04))

    species = meta["id"]
    out_dir = OUT / species
    out_dir.mkdir(parents=True, exist_ok=True)

    idle_frames: list[str] = []
    walk_frames: list[str] = []
    extra: dict[str, list[str]] = {}

    # Heuristic: row0 = idle/stand, row1 = walk (widest / most frames), rest = extras
    if not rows:
        raise RuntimeError(f"no blobs in {meta['file']}")

    idle_row = rows[0]
    walk_row = max(rows[1:], key=lambda r: len(r)) if len(rows) > 1 else rows[0]

    for i, blob in enumerate(idle_row[:4]):
        name = f"idle_{i}.png"
        crop_blob(rgba, blob).save(out_dir / name, "PNG")
        idle_frames.append(f"res://assets/sprites/animals/{species}/{name}")

    for i, blob in enumerate(walk_row[:8]):
        name = f"walk_{i}.png"
        crop_blob(rgba, blob).save(out_dir / name, "PNG")
        walk_frames.append(f"res://assets/sprites/animals/{species}/{name}")

    # Keep first frame of remaining rows as optional pose refs
    for ri, row in enumerate(rows[2:], start=2):
        if not row:
            continue
        name = f"pose_r{ri}_0.png"
        crop_blob(rgba, row[0]).save(out_dir / name, "PNG")
        extra.setdefault(f"row{ri}", []).append(
            f"res://assets/sprites/animals/{species}/{name}"
        )

    entry = {
        "id": species,
        "zh": meta["zh"],
        "source": meta["file"],
        "blob_count": len(blobs),
        "row_counts": [len(r) for r in rows],
        "idle": idle_frames,
        "walk": walk_frames,
        "extra": extra,
        "notes": "idle=row0, walk=longest later row; black keyed to alpha",
    }
    print(
        f"  {species}: blobs={len(blobs)} rows={entry['row_counts']} "
        f"idle={len(idle_frames)} walk={len(walk_frames)}"
    )
    return entry


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    catalog: dict = {
        "source_glob": "B13_animals_01.png … _05.png",
        "missing_requested": ["chicken", "bird"],
        "missing_note": "B13 sheets contain sheep/deer/cat/cow/dog only; no 鸡/鸟 art.",
        "species": [],
    }
    print("== slice B13 animals ==")
    for meta in SHEETS:
        catalog["species"].append(slice_sheet(meta))
    cat_path = OUT / "catalog.json"
    cat_path.write_text(json.dumps(catalog, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {cat_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
