#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ArtPipeline continue: water, FX, NPC, trees, fountain. BASE_TILE=32 NEAREST."""
from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image

sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(r"d:\GoDot_Projects\Dream")
RAW = ROOT / "dream" / "assets" / "raw"
SLICED = ROOT / "dream" / "assets" / "sliced"
TILESETS = ROOT / "dream" / "assets" / "tilesets"
SPRITES = ROOT / "dream" / "assets" / "sprites"
BASE = 32
BG = 18


def to_rgba_key_black(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if r <= BG and g <= BG and b <= BG:
                px[x, y] = (0, 0, 0, 0)
    return im


def nearest_fit(im: Image.Image, tw: int, th: int) -> Image.Image:
    return im.resize((tw, th), Image.Resampling.NEAREST)


def scale_to_height(im: Image.Image, target_h: int) -> Image.Image:
    w, h = im.size
    if h <= 0:
        return im
    nh = target_h
    nw = max(1, int(round(w * (nh / h))))
    return im.resize((nw, nh), Image.Resampling.NEAREST)


def scale_to_max(im: Image.Image, max_side: int) -> Image.Image:
    w, h = im.size
    m = max(w, h)
    if m <= 0:
        return im
    scale = max_side / m
    nw = max(1, int(round(w * scale)))
    nh = max(1, int(round(h * scale)))
    return im.resize((nw, nh), Image.Resampling.NEAREST)


def find_islands(mask_w: int, mask_h: int, is_fg, min_area: int = 400):
    visited = [[False] * mask_w for _ in range(mask_h)]
    islands = []
    for y in range(mask_h):
        for x in range(mask_w):
            if visited[y][x] or not is_fg(x, y):
                continue
            stack = [(x, y)]
            visited[y][x] = True
            minx = maxx = x
            miny = maxy = y
            area = 0
            while stack:
                cx, cy = stack.pop()
                area += 1
                minx = min(minx, cx)
                maxx = max(maxx, cx)
                miny = min(miny, cy)
                maxy = max(maxy, cy)
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < mask_w and 0 <= ny < mask_h and not visited[ny][nx] and is_fg(nx, ny):
                        visited[ny][nx] = True
                        stack.append((nx, ny))
            if area >= min_area:
                islands.append((minx, miny, maxx + 1, maxy + 1, area))
    islands.sort(key=lambda t: (t[1], t[0]))
    return islands


def islands_from_rgb(path: Path, step: int = 2, min_area: int = 40):
    im = Image.open(path).convert("RGB")
    w, h = im.size
    px = im.load()

    def fg(x, y):
        r, g, b = px[min(w - 1, x * step), min(h - 1, y * step)]
        return not (r <= BG and g <= BG and b <= BG)

    raw = find_islands(w // step, h // step, fg, min_area=min_area)
    boxes = []
    for x0, y0, x1, y1, area in raw:
        boxes.append(
            {
                "box": (x0 * step, y0 * step, x1 * step, y1 * step),
                "area": area,
                "w": (x1 - x0) * step,
                "h": (y1 - y0) * step,
            }
        )
    return im, boxes


def mean_rgb(im: Image.Image, box) -> tuple[float, float, float]:
    crop = im.crop(box)
    w, h = crop.size
    px = crop.load()
    sr = sg = sb = n = 0
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            if r <= BG and g <= BG and b <= BG:
                continue
            sr += r
            sg += g
            sb += b
            n += 1
    if n == 0:
        return (0.0, 0.0, 0.0)
    return (sr / n, sg / n, sb / n)


def color_dist(a, b) -> float:
    return sum((a[i] - b[i]) ** 2 for i in range(3)) ** 0.5


def pad_square_nearest(rgba: Image.Image, size: int) -> Image.Image:
    cw, ch = rgba.size
    side = max(cw, ch, 1)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(rgba, ((side - cw) // 2, (side - ch) // 2), rgba)
    return nearest_fit(canvas, size, size)


def build_atlas(tile_paths: list[Path], atlas_path: Path, cols: int = 8) -> int:
    if not tile_paths:
        return 0
    rows = (len(tile_paths) + cols - 1) // cols
    atlas = Image.new("RGBA", (cols * BASE, rows * BASE), (0, 0, 0, 0))
    for i, t in enumerate(tile_paths):
        im = Image.open(t).convert("RGBA")
        x = (i % cols) * BASE
        y = (i // cols) * BASE
        atlas.paste(im, (x, y), im)
    atlas_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(atlas_path)
    return len(tile_paths)


def pick_largest_water() -> Path:
    # Prefer named lake; else largest B03 water sheet by bytes among lake/water names
    candidates = []
    for p in RAW.rglob("B03*.png"):
        n = p.name.lower()
        if "water" in n or "lake" in n or "river" in n or "ocean" in n or "stream" in n:
            # skip numeric duplicates like B03_09 if water_* sibling exists
            candidates.append(p)
    # Prefer descriptive names over B03_NN.png duplicates
    named = [p for p in candidates if "water" in p.name.lower() or "lake" in p.name.lower()]
    pool = named if named else candidates
    if not pool:
        raise FileNotFoundError("No B03 water sheets")
    # Prefer lake in name among top sizes, else absolute largest
    lake = [p for p in pool if "lake" in p.name.lower()]
    if lake:
        # largest lake-named; if user wanted largest overall water, still pick biggest sheet
        pass
    return max(pool, key=lambda p: p.stat().st_size)


def extract_water() -> dict:
    src = pick_largest_water()
    # Prefer B03_water_lake if within 30% of largest (true lake sheet), else largest
    lake = None
    for p in RAW.rglob("B03*.png"):
        if "lake" in p.name.lower() and "water" in p.name.lower():
            lake = p
            break
    if lake is None:
        for p in RAW.rglob("B03*.png"):
            if "lake" in p.name.lower():
                lake = p
                break
    # User: largest lake/water — use largest overall among water family
    src = pick_largest_water()

    im, boxes = islands_from_rgb(src, step=2, min_area=40)
    # tile-like cells ~80-180 px side
    tiles = [b for b in boxes if 70 <= b["w"] <= 200 and 70 <= b["h"] <= 200]
    tiles = tiles[:8] if len(tiles) >= 8 else tiles
    if len(tiles) < 8:
        # take more from remaining by area
        rest = [b for b in boxes if b not in tiles]
        rest.sort(key=lambda b: b["area"], reverse=True)
        tiles = (tiles + rest)[:8]

    out_dir = SLICED / "water"
    out_dir.mkdir(parents=True, exist_ok=True)
    # clear old tiles
    for old in out_dir.glob("tile_*.png"):
        old.unlink()

    tile_files = []
    meta_tiles = []
    for i, b in enumerate(tiles):
        crop = to_rgba_key_black(im.crop(b["box"]))
        tile = pad_square_nearest(crop, BASE)
        name = f"tile_{i:03d}.png"
        tile.save(out_dir / name)
        tile_files.append(out_dir / name)
        meta_tiles.append({"file": name, "src_box": list(b["box"]), "src_wh": [b["w"], b["h"]]})

    atlas_path = TILESETS / "water_atlas.png"
    build_atlas(tile_files, atlas_path, cols=4)

    # Water ripple frames: neighboring similar cells from first row
    fx_dir = SPRITES / "fx"
    fx_dir.mkdir(parents=True, exist_ok=True)
    for old in fx_dir.glob("water_frame_*.png"):
        old.unlink()

    # Use consecutive similar-size cells from row of first tile
    if tiles:
        y0 = tiles[0]["box"][1]
        row = [b for b in boxes if abs(b["box"][1] - y0) < 30 and 70 <= b["w"] <= 200]
        row = sorted(row, key=lambda b: b["box"][0])
    else:
        row = []

    n_frames = min(6, max(4, len(row))) if len(row) >= 4 else max(len(row), 0)
    if len(row) >= 4:
        n_frames = min(6, len(row))
        frame_boxes = row[:n_frames]
    else:
        # take first n similar from tiles list neighbors
        frame_boxes = tiles[: min(6, len(tiles))]
        n_frames = len(frame_boxes)

    frame_meta = []
    for i, b in enumerate(frame_boxes):
        crop = to_rgba_key_black(im.crop(b["box"]))
        frame = pad_square_nearest(crop, BASE)
        name = f"water_frame_{i}.png"
        frame.save(fx_dir / name)
        frame_meta.append({"file": name, "src_box": list(b["box"])})

    meta = {
        "source": src.name,
        "base_tile": BASE,
        "filter": "NEAREST",
        "tiles": meta_tiles,
        "atlas": "water_atlas.png",
        "ripple_frames": frame_meta,
        "note": f"Extracted {len(meta_tiles)} water tiles + {len(frame_meta)} ripple frames from {src.name}",
    }
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    (fx_dir / "water_ripple_meta.json").write_text(
        json.dumps({"source": src.name, "frames": frame_meta, "size": [BASE, BASE]}, indent=2),
        encoding="utf-8",
    )
    return {
        "source": src.name,
        "tiles": len(meta_tiles),
        "frames": len(frame_meta),
        "atlas": 1,
    }


def classify_fx(mean: tuple[float, float, float], w: int, h: int) -> str:
    r, g, b = mean
    # leaf: green dominant
    if g > r + 15 and g > b + 10:
        return "leaf"
    # sparkle: bright / yellowish-white
    if r > 180 and g > 180 and b > 140:
        return "sparkle"
    if r > 160 and g > 140 and b < 120:
        return "sparkle"
    # smoke: gray mid
    if abs(r - g) < 25 and abs(g - b) < 25 and 40 < r < 200:
        return "smoke"
    # soft white/gray small = smoke puff
    if r > 120 and g > 120 and b > 120 and max(w, h) < 60:
        return "smoke"
    # warm particle
    if r > g and r > b and r > 100:
        return "sparkle"
    return "fx"


def extract_fx() -> dict:
    # CURATED_FX_CAPS smoke/sparkle/leaf <=6 each; sparkle via bright pixels

    fx_dir = SPRITES / "fx"
    fx_dir.mkdir(parents=True, exist_ok=True)
    # remove prior smoke/sparkle/leaf from this pipeline
    for pattern in ("smoke_*.png", "sparkle_*.png", "leaf_*.png", "fx_misc_*.png"):
        for old in fx_dir.glob(pattern):
            old.unlink()

    sources = sorted(RAW.rglob("B15*.png"), key=lambda p: p.stat().st_size, reverse=True)
    counters = {"smoke": 0, "sparkle": 0, "leaf": 0, "fx": 0}
    saved = []
    meta_items = []

    for src in sources:
        im, boxes = islands_from_rgb(src, step=2, min_area=20)
        # small FX islands
        small = [b for b in boxes if 8 <= max(b["w"], b["h"]) <= 90 and b["area"] >= 20]
        # also medium wisps for smoke (up to 160)
        medium = [b for b in boxes if 40 <= max(b["w"], b["h"]) <= 160 and min(b["w"], b["h"]) >= 20]
        candidates = small + [b for b in medium if b not in small]
        # dedupe by box
        seen = set()
        uniq = []
        for b in candidates:
            key = b["box"]
            if key in seen:
                continue
            seen.add(key)
            uniq.append(b)

        for b in uniq:
            mean = mean_rgb(im, b["box"])
            kind = classify_fx(mean, b["w"], b["h"])
            if kind == "fx":
                # skip large unknown blobs
                if max(b["w"], b["h"]) > 100:
                    continue
                kind_name = "fx_misc"
            else:
                kind_name = kind
            crop = to_rgba_key_black(im.crop(b["box"]))
            scaled = scale_to_max(crop, 32)
            idx = counters.get(kind, counters.get("fx", 0))
            if kind == "fx":
                counters["fx"] = counters["fx"] + 1
                idx = counters["fx"] - 1
            else:
                counters[kind] = counters[kind] + 1
                idx = counters[kind] - 1
            name = f"{kind_name}_{idx:02d}.png"
            scaled.save(fx_dir / name)
            saved.append(name)
            meta_items.append(
                {
                    "file": name,
                    "kind": kind,
                    "source": src.name,
                    "src_box": list(b["box"]),
                    "mean_rgb": [round(x, 1) for x in mean],
                    "scaled_max": 32,
                }
            )
            # cap per kind to keep set reasonable
            if counters.get(kind, 0) >= 8 and kind != "fx":
                continue
        # stop if we have enough of each
        if counters["smoke"] >= 3 and counters["sparkle"] >= 3 and counters["leaf"] >= 2:
            break

    # Prefer having at least one of each if found; filter meta to useful set
    # Keep all saved but note counts
    meta = {
        "sources": [p.name for p in sources],
        "items": meta_items,
        "counts": {k: counters[k] for k in counters},
        "filter": "NEAREST",
        "target_max_px": 32,
    }
    (fx_dir / "fx_meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return {"files": len(saved), "counts": counters, "sources": [p.name for p in sources]}


def group_rows(chars: list[dict], y_tol: int = 50) -> list[list[dict]]:
    rows: list[list[dict]] = []
    for c in chars:
        placed = False
        for row in rows:
            if abs(row[0]["y"] - c["y"]) < y_tol:
                row.append(c)
                placed = True
                break
        if not placed:
            rows.append([c])
    for row in rows:
        row.sort(key=lambda c: c["box"][0])
    return rows


def extract_npcs() -> dict:
    out_dir = SPRITES / "npc"
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("npc_*.png"):
        old.unlink()
    for old in out_dir.glob("idle_*.png"):
        old.unlink()

    # Prefer sheets with clear 4-frame similar rows
    sheets = sorted(RAW.rglob("B14*.png"), key=lambda p: p.name)
    standing = []
    idle_info = None

    for src in sheets:
        im, boxes = islands_from_rgb(src, step=2, min_area=150)
        chars = []
        for b in boxes:
            if 70 <= b["w"] <= 160 and 140 <= b["h"] <= 300:
                mean = mean_rgb(im, b["box"])
                chars.append(
                    {
                        "box": b["box"],
                        "w": b["w"],
                        "h": b["h"],
                        "y": b["box"][1],
                        "mean": mean,
                        "source": src,
                        "im": im,
                    }
                )
        rows = group_rows(chars)
        # find best idle row: 4 frames, similar size, low color distance
        for row in rows:
            if len(row) < 4:
                continue
            seg = row[:4]
            hs = [c["h"] for c in seg]
            if max(hs) - min(hs) > 30:
                continue
            dists = [color_dist(seg[i]["mean"], seg[i + 1]["mean"]) for i in range(3)]
            if max(dists) <= 8.0 and sum(dists) / 3 < 5.0:
                idle_info = {"source": src.name, "frames": seg, "dists": dists}
                break
        if idle_info:
            break
        # collect standing candidates from first sheet with chars
        if not standing and chars:
            # pick 3 distinct by spacing across sheet
            standing = chars[:3] if len(chars) >= 3 else chars

    # Standing NPCs: take 3 from B14_npc_01 first row or distinct
    if not standing:
        src = sheets[0]
        im, boxes = islands_from_rgb(src, step=2, min_area=150)
        for b in boxes:
            if 70 <= b["w"] <= 160 and 140 <= b["h"] <= 300:
                standing.append(
                    {
                        "box": b["box"],
                        "w": b["w"],
                        "h": b["h"],
                        "y": b["box"][1],
                        "mean": mean_rgb(im, b["box"]),
                        "source": src,
                        "im": im,
                    }
                )
                if len(standing) >= 3:
                    break

    # Prefer 3 NPCs from different rows / different mean colors
    pick = []
    used_means = []
    # flatten all sheets for diversity
    all_chars = []
    for src in sheets:
        im, boxes = islands_from_rgb(src, step=2, min_area=150)
        for b in boxes:
            if 70 <= b["w"] <= 160 and 140 <= b["h"] <= 280:
                m = mean_rgb(im, b["box"])
                all_chars.append(
                    {
                        "box": b["box"],
                        "w": b["w"],
                        "h": b["h"],
                        "y": b["box"][1],
                        "mean": m,
                        "source": src,
                        "im": im,
                    }
                )
    for c in all_chars:
        if len(pick) >= 3:
            break
        if any(color_dist(c["mean"], um) < 12 for um in used_means):
            continue
        pick.append(c)
        used_means.append(c["mean"])
    if len(pick) < 3:
        for c in all_chars:
            if c in pick:
                continue
            pick.append(c)
            if len(pick) >= 3:
                break

    npc_meta = []
    for i, c in enumerate(pick[:3]):
        crop = to_rgba_key_black(c["im"].crop(c["box"]))
        scaled = scale_to_height(crop, 56)
        name = f"npc_{i:02d}.png"
        scaled.save(out_dir / name)
        npc_meta.append(
            {
                "file": name,
                "source": c["source"].name,
                "src_box": list(c["box"]),
                "height_px": 56,
                "filter": "NEAREST",
            }
        )

    idle_meta = {"has_idle_animation": False, "note": "No clear 4-frame idle row found; single standing frames only."}
    if idle_info:
        idle_meta = {
            "has_idle_animation": True,
            "source": idle_info["source"],
            "frame_count": 4,
            "color_dists": [round(d, 2) for d in idle_info["dists"]],
            "frames": [],
            "note": "Real sheet row used; no synthetic offset duplicates.",
        }
        for i, c in enumerate(idle_info["frames"][:4]):
            crop = to_rgba_key_black(c["im"].crop(c["box"]))
            scaled = scale_to_height(crop, 56)
            name = f"idle_frame_{i}.png"
            scaled.save(out_dir / name)
            idle_meta["frames"].append({"file": name, "src_box": list(c["box"])})

    meta = {
        "npcs": npc_meta,
        "idle": idle_meta,
        "height_px": 56,
        "filter": "NEAREST",
    }
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return {
        "npcs": len(npc_meta),
        "idle_frames": len(idle_meta.get("frames", [])) if idle_meta.get("has_idle_animation") else 0,
        "idle_note": idle_meta.get("note", ""),
    }


def extract_trees() -> dict:
    out_dir = SPRITES / "trees"
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("tree_*.png"):
        old.unlink()

    # largest trees sheet
    sheets = sorted(RAW.rglob("B05*.png"), key=lambda p: p.stat().st_size, reverse=True)
    src = sheets[0]
    im, boxes = islands_from_rgb(src, step=3, min_area=200)
    # tree-sized
    trees = [b for b in boxes if b["h"] >= 200 and b["w"] >= 150]
    trees = sorted(trees, key=lambda b: b["area"], reverse=True)[:4]
    if len(trees) < 4:
        trees = sorted(boxes, key=lambda b: b["area"], reverse=True)[:4]

    heights = [128, 144, 152, 160]
    meta_trees = []
    for i, b in enumerate(trees):
        crop = to_rgba_key_black(im.crop(b["box"]))
        th = heights[i % len(heights)]
        scaled = scale_to_height(crop, th)
        name = f"tree_{i:02d}.png"
        scaled.save(out_dir / name)
        meta_trees.append(
            {
                "file": name,
                "source": src.name,
                "src_box": list(b["box"]),
                "height_px": th,
                "filter": "NEAREST",
            }
        )

    meta = {"source": src.name, "trees": meta_trees, "height_range": [128, 160]}
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return {"source": src.name, "trees": len(meta_trees)}


def extract_fountain() -> dict:
    out_dir = SPRITES / "props"
    out_dir.mkdir(parents=True, exist_ok=True)

    # User said B11_06 fountain if exists — actual fountain is B11-05; B11-06 is mailbox
    fountain = None
    for p in RAW.rglob("B11*.png"):
        if "fountain" in p.name.lower():
            fountain = p
            break
    if fountain is None:
        for p in RAW.rglob("B11-06*.png"):
            fountain = p
            break
    if fountain is None:
        for p in RAW.rglob("B11_06*.png"):
            fountain = p
            break

    if fountain is None:
        meta = {"found": False, "note": "No B11 fountain / B11-06 sheet found"}
        (out_dir / "fountain_meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
        return {"found": False, "files": 0}

    im, boxes = islands_from_rgb(fountain, step=2, min_area=100)
    # largest island = main fountain
    boxes = sorted(boxes, key=lambda b: b["area"], reverse=True)
    b = boxes[0]
    crop = to_rgba_key_black(im.crop(b["box"]))
    scaled = scale_to_height(crop, 96)
    name = "plaza_fountain.png"
    scaled.save(out_dir / name)
    note = (
        f"Used {fountain.name} (fountain sheet). "
        "B11-06 is mailbox_board, not fountain — preferred B11-05_fountain."
        if "fountain" in fountain.name.lower()
        else f"Used {fountain.name} as requested B11_06 fallback."
    )
    meta = {
        "found": True,
        "file": name,
        "source": fountain.name,
        "src_box": list(b["box"]),
        "height_px": 96,
        "filter": "NEAREST",
        "note": note,
    }
    (out_dir / "fountain_meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return {"found": True, "file": name, "source": fountain.name}


def main() -> None:
    SLICED.mkdir(parents=True, exist_ok=True)
    TILESETS.mkdir(parents=True, exist_ok=True)
    SPRITES.mkdir(parents=True, exist_ok=True)

    results = {}
    print("=== WATER ===")
    results["water"] = extract_water()
    print(results["water"])

    print("=== FX ===")
    results["fx"] = extract_fx()
    print(results["fx"])

    print("=== NPC ===")
    results["npc"] = extract_npcs()
    print(results["npc"])

    print("=== TREES ===")
    results["trees"] = extract_trees()
    print(results["trees"])

    print("=== FOUNTAIN ===")
    results["fountain"] = extract_fountain()
    print(results["fountain"])

    # file counts
    counts = {
        "sliced/water": len(list((SLICED / "water").glob("*.png"))),
        "tilesets/water_atlas": len(list(TILESETS.glob("water_atlas.png"))),
        "sprites/fx": len(list((SPRITES / "fx").glob("*.png"))),
        "sprites/npc": len(list((SPRITES / "npc").glob("*.png"))),
        "sprites/trees": len(list((SPRITES / "trees").glob("*.png"))),
        "sprites/props/fountain": 1 if (SPRITES / "props" / "plaza_fountain.png").exists() else 0,
    }
    results["file_counts"] = counts
    summary_path = ROOT / "dream" / "tools" / "_art_pipeline_continue_summary.json"
    summary_path.write_text(json.dumps(results, indent=2), encoding="utf-8")
    print("\nFILE COUNTS:")
    for k, v in counts.items():
        print(f"  {k}: {v}")
    print("TOTAL pngs written categories:", sum(counts.values()))
    print("Summary ->", summary_path)


if __name__ == "__main__":
    main()
