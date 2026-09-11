#!/usr/bin/env python3
"""Re-slice rembg'd interior atlases, normalize heights, fix cozy walls without labels."""
from __future__ import annotations

import json
import shutil
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PROP = ROOT / "assets" / "sprites" / "interior" / "props"
TILE = ROOT / "assets" / "sprites" / "interior" / "tiles"
CUT = ROOT / "assets" / "sprites" / "interior" / "_source_atlases" / "cut"
DIAG = ROOT / "assets" / "sprites" / "interior" / "_diag"
COZY = ROOT / "assets" / "sprites" / "interior" / "c01_room_reference_cozy.png"
BENCH = ROOT / "assets" / "sprites" / "props" / "bench_0.png"

TARGET_H = 64  # outdoor props ~48; signature furniture up to 64–72
MIN_AREA = 1800
MIN_SIDE = 36
ALPHA_T = 40


def components(alpha: np.ndarray) -> list[tuple[int, int, int, int]]:
    h, w = alpha.shape
    mask = alpha > ALPHA_T
    visited = np.zeros_like(mask, dtype=bool)
    boxes: list[tuple[int, int, int, int, int]] = []
    for y in range(h):
        for x in range(w):
            if not mask[y, x] or visited[y, x]:
                continue
            stack = [(y, x)]
            visited[y, x] = True
            ys, xs = [y], [x]
            while stack:
                cy, cx = stack.pop()
                for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                    if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = True
                        stack.append((ny, nx))
                        ys.append(ny)
                        xs.append(nx)
            y0, y1, x0, x1 = min(ys), max(ys), min(xs), max(xs)
            area = int((alpha[y0 : y1 + 1, x0 : x1 + 1] > ALPHA_T).sum())
            bw, bh = x1 - x0 + 1, y1 - y0 + 1
            if area < MIN_AREA or bw < MIN_SIDE or bh < MIN_SIDE:
                continue
            boxes.append((x0, y0, x1, y1, area))
    # sort by row (quantize) then x
    boxes.sort(key=lambda b: ((b[1] + b[3]) // 2 // 120, b[0]))
    return [(b[0], b[1], b[2], b[3]) for b in boxes]


def normalize_h(im: Image.Image, target_h: int = TARGET_H) -> Image.Image:
    w, h = im.size
    if h <= 0:
        return im
    scale = target_h / float(h)
    nw = max(8, int(round(w * scale)))
    return im.resize((nw, target_h), Image.Resampling.NEAREST)


def slice_rgba(path: Path, names: list[str], out: Path) -> dict:
    im = Image.open(path).convert("RGBA")
    a = np.array(im)
    boxes = components(a[:, :, 3])
    print(f"{path.name}: {len(boxes)} islands")
    mapping = {}
    for i, (x0, y0, x1, y1) in enumerate(boxes):
        crop = im.crop((x0, y0, x1 + 1, y1 + 1))
        crop = normalize_h(crop)
        name = names[i] if i < len(names) else f"extra_{i:02d}"
        dest = out / f"{name}.png"
        crop.save(dest)
        mapping[name] = {"box": [x0, y0, x1, y1], "size": list(crop.size)}
        print(f"  {name:20} {crop.size}")
    return mapping


def indoor_table() -> None:
    if not BENCH.exists():
        return
    im = Image.open(BENCH).convert("RGBA")
    a = np.array(im)
    r, g, b, al = a[:, :, 0], a[:, :, 1], a[:, :, 2], a[:, :, 3]
    grass = (g > 90) & (g > r + 25) & (g > b + 15) & (al > 200)
    a[grass, 3] = 0
    ys, xs = np.where(a[:, :, 3] > 20)
    crop = Image.fromarray(a, "RGBA").crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    crop.save(PROP / "table_dining_00.png")
    crop.save(PROP / "table_indoor_00.png")
    print("table_dining", crop.size)


def cozy_walls() -> None:
    """Crop wall composite below label, export 32x64 then split."""
    # Prefer full cozy crop of content band without using DIAG if labeled
    im = Image.open(COZY).convert("RGBA")
    # content band for composite walls from earlier: y357-458
    band = im.crop((0, 360, 1024, 455))
    a = np.array(band)
    # remove pure black
    content = ~((a[:, :, 0] < 15) & (a[:, :, 1] < 15) & (a[:, :, 2] < 15))
    # also remove near-white label text rows at top if any
    row_white = ((a[:, :, 0] > 200) & (a[:, :, 1] > 200) & (a[:, :, 2] > 200)).mean(axis=1)
    y0 = 0
    for i, frac in enumerate(row_white):
        if frac > 0.02:
            y0 = i + 1
        elif y0 > 0 and frac < 0.002 and i > y0 + 2:
            break
    ys = np.where(content.any(axis=1))[0]
    xs = np.where(content.any(axis=0))[0]
    y_start = max(int(ys.min()), y0)
    band = band.crop((int(xs.min()), y_start, int(xs.max()) + 1, int(ys.max()) + 1))
    # if still has 'ROW' like bright pixels in top 8 rows, trim
    ba = np.array(band)
    top = ba[:10, :, :3]
    if ((top > 220).all(axis=2)).mean() > 0.01:
        band = band.crop((0, 12, band.width, band.height))
    band = band.resize((band.width * 64 // band.height, 64), Image.Resampling.NEAREST)
    n = min(8, band.width // 32)
    for i in range(n):
        tile = band.crop((i * 32, 0, (i + 1) * 32, 64))
        # skip if mostly black
        ta = np.array(tile)
        if (ta[:, :, 3] > 20).mean() < 0.3 and (ta[:, :, 0] < 20).mean() > 0.7:
            continue
        tile.save(TILE / f"wall_full_{i:02d}.png")
        tile.crop((0, 0, 32, 32)).save(TILE / f"wall_upper_{i:02d}.png")
        tile.crop((0, 32, 32, 64)).save(TILE / f"wall_lower_{i:02d}.png")
        print("wall", i)

    # window from y480-581 band
    winband = im.crop((0, 490, 1024, 575))
    wa = np.array(winband)
    content = ~((wa[:, :, 0] < 15) & (wa[:, :, 1] < 15) & (wa[:, :, 2] < 15))
    ys = np.where(content.any(axis=1))[0]
    xs = np.where(content.any(axis=0))[0]
    winband = winband.crop((int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1))
    # take a glowing window third
    w = winband.width
    seg = winband.crop((int(w * 0.28), 0, int(w * 0.52), winband.height))
    seg = seg.resize((40, 56), Image.Resampling.NEAREST)
    sa = np.array(seg.convert("RGBA"))
    m = (sa[:, :, 0] < 12) & (sa[:, :, 1] < 12) & (sa[:, :, 2] < 12)
    sa[m, 3] = 0
    Image.fromarray(sa, "RGBA").save(TILE / "window_00.png")
    print("window", seg.size)

    # rugs y729-829
    rugband = im.crop((0, 735, 1024, 825))
    ra = np.array(rugband)
    content = ~((ra[:, :, 0] < 15) & (ra[:, :, 1] < 15) & (ra[:, :, 2] < 15))
    ys = np.where(content.any(axis=1))[0]
    xs = np.where(content.any(axis=0))[0]
    rug = rugband.crop((int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1))
    rug = rug.resize((64, 64), Image.Resampling.NEAREST)
    for qy in range(2):
        for qx in range(2):
            rug.crop((qx * 32, qy * 32, (qx + 1) * 32, (qy + 1) * 32)).save(TILE / f"rug_{qy}_{qx}.png")
    print("rugs ok")


# After rembg, island order for home (verify by size/aspect after run — editable).
HOME_NAMES = [
    "fireplace_00",
    "stove_00",
    "bed_double_00",
    "bed_single_00",
    "dresser_00",
    "table_round_00",
    "stool_00",
    "rocking_00",
    "shelf_00",
    "herbs_00",
]

WORK_NAMES = [
    "forge_00",
    "anvil_00",
    "tool_rack_00",
    "counter_00",
    "bar_00",
    "shelf_grocery_00",
    "basket_00",
    "notice_00",
    "table_pub_00",
    "stool_bar_00",
    "mug_shelf_00",
    "hay_00",
    "nest_00",
    "trough_00",
    "ledger_00",
    "coin_chest_00",
    "medicine_00",
    "roost_00",
]


def main() -> None:
    PROP.mkdir(parents=True, exist_ok=True)
    # clear previous prop pngs except archive
    for p in PROP.glob("*.png"):
        p.unlink()

    home = CUT / "home_rgba.png"
    work = CUT / "work_rgba.png"
    if not home.exists() or not work.exists():
        raise SystemExit("run rembg first into _source_atlases/cut/")

    meta = {
        "home": slice_rgba(home, HOME_NAMES, PROP),
        "work": slice_rgba(work, WORK_NAMES, PROP),
    }
    indoor_table()
    cozy_walls()

    # aliases for profiles
    aliases = [
        ("table_pub_00.png", "table_round_00.png"),  # only if round missing
        ("stool_bar_00.png", "stool_00.png"),
        ("shelf_grocery_00.png", "shelf_00.png"),  # grocery-specific preferred in profiles
    ]
    # Ensure stool exists
    if not (PROP / "stool_00.png").exists() and (PROP / "stool_bar_00.png").exists():
        shutil.copy2(PROP / "stool_bar_00.png", PROP / "stool_00.png")
    if not (PROP / "table_round_00.png").exists() and (PROP / "table_pub_00.png").exists():
        shutil.copy2(PROP / "table_pub_00.png", PROP / "table_round_00.png")
    # cauldron: small crop from fireplace glow not available — skip; profiles can omit

    (CUT / "manifest.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print("done", len(list(PROP.glob('*.png'))), "props")


if __name__ == "__main__":
    main()
