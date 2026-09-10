#!/usr/bin/env python3
"""Slice 4-direction walk cycles from B14 (and gen) NPC sheets into sprites/npc/{id}/."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "assets" / "raw"
OUT = ROOT / "assets" / "sprites" / "npc"
TARGET_H = 56
DIRS = ("down", "left", "right", "up")  # typical top-down sheet row order


SHEETS = [
    {"id": "elder_woman", "file": "B14_npc_01.png", "title": "老妇人"},
    {"id": "station_master", "file": "B14_npc_02.png", "title": "站长"},
    {"id": "blacksmith", "file": "B14_npc_03.png", "title": "铁匠"},
    {"id": "farmer", "file": "gen_npc_farmer.png", "title": "农夫", "optional": True},
    {"id": "merchant", "file": "gen_npc_merchant.png", "title": "商贩", "optional": True},
]


def key_black(im: Image.Image, thresh: int = 18) -> Image.Image:
    rgba = im.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if r <= thresh and g <= thresh and b <= thresh:
                px[x, y] = (0, 0, 0, 0)
    return rgba


def scale_h(im: Image.Image, height: int) -> Image.Image:
    w, h = im.size
    if h <= 0:
        return im
    nw = max(1, int(round(w * (height / float(h)))))
    return im.resize((nw, height), Image.Resampling.NEAREST)


def islands(im: Image.Image, step: int = 2, min_area: int = 120):
    """Return bounding boxes of non-black islands (RGB)."""
    rgb = im.convert("RGB")
    w, h = rgb.size
    visited = [[False] * w for _ in range(h)]
    boxes = []

    def is_fg(x: int, y: int) -> bool:
        r, g, b = rgb.getpixel((x, y))
        return not (r <= 18 and g <= 18 and b <= 18)

    for y0 in range(0, h, step):
        for x0 in range(0, w, step):
            if visited[y0][x0] or not is_fg(x0, y0):
                continue
            stack = [(x0, y0)]
            visited[y0][x0] = True
            minx = maxx = x0
            miny = maxy = y0
            count = 0
            while stack:
                x, y = stack.pop()
                count += 1
                minx = min(minx, x)
                maxx = max(maxx, x)
                miny = min(miny, y)
                maxy = max(maxy, y)
                for nx, ny in ((x - step, y), (x + step, y), (x, y - step), (x, y + step)):
                    if nx < 0 or ny < 0 or nx >= w or ny >= h:
                        continue
                    if visited[ny][nx]:
                        continue
                    if not is_fg(nx, ny):
                        continue
                    visited[ny][nx] = True
                    stack.append((nx, ny))
            area = (maxx - minx + 1) * (maxy - miny + 1)
            if count * step * step < min_area:
                continue
            bw = maxx - minx + 1
            bh = maxy - miny + 1
            # Character-ish cells on these sheets.
            if 40 <= bw <= 220 and 80 <= bh <= 320:
                boxes.append({"box": (minx, miny, maxx + 1, maxy + 1), "w": bw, "h": bh, "cx": (minx + maxx) / 2, "cy": (miny + maxy) / 2})
    return boxes


def group_rows(boxes: list, y_tol: float = 40.0) -> list:
    rows: list[list] = []
    for b in sorted(boxes, key=lambda x: x["cy"]):
        placed = False
        for row in rows:
            if abs(row[0]["cy"] - b["cy"]) <= y_tol:
                row.append(b)
                placed = True
                break
        if not placed:
            rows.append([b])
    for row in rows:
        row.sort(key=lambda x: x["cx"])
    return rows


def pick_walk_grid(boxes: list) -> list[list] | None:
    """Prefer left-side 4 rows x 4 frames walk block."""
    if not boxes:
        return None
    max_x = max(b["box"][2] for b in boxes)
    left = [b for b in boxes if b["cx"] < max_x * 0.58]
    rows = group_rows(left if len(left) >= 12 else boxes, y_tol=55.0)
    good = []
    for row in rows:
        if len(row) < 4:
            continue
        seg = sorted(row, key=lambda c: c["h"])
        median_h = seg[len(seg) // 2]["h"]
        near = [c for c in row if abs(c["h"] - median_h) <= 30]
        if len(near) < 4:
            near = row[:4]
        near = sorted(near, key=lambda c: c["cx"])[:4]
        if len(near) < 4:
            continue
        hs = [c["h"] for c in near]
        if max(hs) - min(hs) > 60:
            continue
        good.append(near)
    if len(good) >= 4:
        good.sort(key=lambda r: r[0]["cy"])
        return good[:4]
    fat = [r[:4] for r in rows if len(r) >= 4]
    if len(fat) >= 4:
        fat.sort(key=lambda r: r[0]["cy"])
        return fat[:4]
    return None


def export_character(char_id: str, src: Path, title: str) -> dict | None:
    im = Image.open(src)
    boxes = islands(im)
    grid = pick_walk_grid(boxes)
    if not grid:
        print(f"[warn] no walk grid for {src.name}")
        return None
    out_dir = OUT / char_id
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("*.png"):
        old.unlink()
    frames_meta = {}
    for di, row in enumerate(grid):
        dname = DIRS[di]
        frames_meta[dname] = []
        for fi, cell in enumerate(row):
            crop = key_black(im.crop(cell["box"]))
            scaled = scale_h(crop, TARGET_H)
            name = f"walk_{dname}_{fi}.png"
            scaled.save(out_dir / name)
            frames_meta[dname].append(name)
    meta = {
        "id": char_id,
        "title": title,
        "source": src.name,
        "height_px": TARGET_H,
        "dirs": DIRS,
        "frames": frames_meta,
        "filter": "NEAREST",
    }
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[ok] {char_id}: {[len(frames_meta[d]) for d in DIRS]} frames from {src.name}")
    return meta


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    catalog = {"characters": [], "height_px": TARGET_H}
    for spec in SHEETS:
        src = RAW / spec["file"]
        if not src.exists():
            if spec.get("optional"):
                print(f"[skip] optional missing {spec['file']}")
                continue
            raise SystemExit(f"missing {src}")
        meta = export_character(spec["id"], src, spec["title"])
        if meta:
            catalog["characters"].append(
                {"id": meta["id"], "title": meta["title"], "dir": meta["id"], "source": meta["source"]}
            )
    (OUT / "catalog.json").write_text(json.dumps(catalog, indent=2), encoding="utf-8")
    print(json.dumps(catalog, indent=2))


if __name__ == "__main__":
    main()
