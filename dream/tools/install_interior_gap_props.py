#!/usr/bin/env python3
"""Rembg + normalize generated gap props into interior/props (64px tall)."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image
from rembg import new_session, remove

ROOT = Path(__file__).resolve().parents[1]
PROP = ROOT / "assets" / "sprites" / "interior" / "props"
# Cursor GenerateImage output folder (this machine)
GEN = Path(r"C:\Users\孤白赟悫\.cursor\projects\d-GoDot-Projects-Dream\assets")
TARGET_H = 64
PAD = 2

# gen filename → ship name
MAP = {
    "gen_table_dining_bare.png": "table_dining_00.png",
    "gen_counter_long.png": "counter_00.png",
    "gen_shelf_grocery.png": "shelf_grocery_00.png",
    "gen_roost.png": "roost_00.png",
    "gen_rocking.png": "rocking_00.png",
    "gen_lamp_indoor.png": "lamp_indoor_00.png",
}


def normalize(im: Image.Image) -> Image.Image:
    a = np.array(im.convert("RGBA"))
    alpha = a[:, :, 3]
    ys, xs = np.where(alpha > 16)
    if len(xs) == 0:
        return im
    x0, x1 = int(xs.min()), int(xs.max())
    y0, y1 = int(ys.min()), int(ys.max())
    crop = a[max(0, y0 - PAD) : y1 + 1 + PAD, max(0, x0 - PAD) : x1 + 1 + PAD]
    h = crop.shape[0]
    scale = TARGET_H / float(h)
    out = Image.fromarray(crop, "RGBA")
    nw = max(8, int(round(out.width * scale)))
    nh = TARGET_H
    return out.resize((nw, nh), Image.Resampling.NEAREST)


def main() -> None:
    session = new_session("birefnet-general")
    PROP.mkdir(parents=True, exist_ok=True)
    for src_name, dest_name in MAP.items():
        src = GEN / src_name
        if not src.exists():
            print("MISSING", src)
            continue
        raw = src.read_bytes()
        cut = remove(raw, session=session)
        im = Image.open(__import__("io").BytesIO(cut)).convert("RGBA")
        # punch near-black leftover
        a = np.array(im)
        m = (a[:, :, 0] < 18) & (a[:, :, 1] < 18) & (a[:, :, 2] < 18) & (a[:, :, 3] > 0)
        a[m, 3] = 0
        im = Image.fromarray(a, "RGBA")
        im = normalize(im)
        dest = PROP / dest_name
        # archive previous if replacing
        if dest.exists() and dest_name in ("counter_00.png", "roost_00.png", "rocking_00.png", "table_dining_00.png"):
            arch = PROP / "_misnamed_archive" / f"pre_gapgen_{dest_name}"
            arch.parent.mkdir(parents=True, exist_ok=True)
            if not arch.exists():
                dest.replace(arch)
            else:
                dest.unlink()
        im.save(dest)
        print("wrote", dest.name, im.size)


if __name__ == "__main__":
    main()
