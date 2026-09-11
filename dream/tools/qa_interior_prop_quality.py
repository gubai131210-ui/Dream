#!/usr/bin/env python3
"""Red-capable visual QA: interior specialty props must not be flat placeholders.

Fails if average unique opaque colors is far below outdoor B11 props.
Run: python dream/tools/qa_interior_prop_quality.py
"""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
INTERIOR = ROOT / "assets" / "sprites" / "interior" / "props"
OUTDOOR = ROOT / "assets" / "sprites" / "props"

# Placeholders typically have <15 unique colors; painted B11 props >> 200.
MIN_AVG_COLORS = 40.0
MIN_AVG_EDGE = 12.0


def metrics(path: Path) -> dict:
    im = Image.open(path).convert("RGBA")
    a = np.array(im)
    rgb, alpha = a[:, :, :3], a[:, :, 3]
    opaque = alpha > 200
    n = int(opaque.sum())
    if n == 0:
        return {"colors": 0, "edge": 0.0, "bytes": path.stat().st_size}
    colors = len({tuple(c) for c in rgb[opaque]})
    gy = np.abs(rgb[1:, :, :].astype(int) - rgb[:-1, :, :].astype(int)).mean()
    gx = np.abs(rgb[:, 1:, :].astype(int) - rgb[:, :-1, :].astype(int)).mean()
    return {"colors": colors, "edge": float((gx + gy) / 2), "bytes": path.stat().st_size}


def summarize(files: list[Path]) -> tuple[float, float, float]:
    rows = [metrics(f) for f in files if f.suffix.lower() == ".png"]
    if not rows:
        return 0.0, 0.0, 0.0
    return (
        sum(r["colors"] for r in rows) / len(rows),
        sum(r["edge"] for r in rows) / len(rows),
        sum(r["bytes"] for r in rows) / len(rows),
    )


def main() -> int:
    interior = sorted(INTERIOR.glob("*.png"))
    outdoor = sorted(OUTDOOR.glob("*.png"))[:20]
    ic, ie, ib = summarize(interior)
    oc, oe, ob = summarize(outdoor)
    print(f"interior_specialty n={len(interior)} avg_colors={ic:.1f} avg_edge={ie:.1f} avg_bytes={ib:.0f}")
    print(f"outdoor_props_sample n={len(outdoor)} avg_colors={oc:.1f} avg_edge={oe:.1f} avg_bytes={ob:.0f}")
    print(f"thresholds: avg_colors>={MIN_AVG_COLORS} avg_edge>={MIN_AVG_EDGE}")

    failed = False
    if ic < MIN_AVG_COLORS:
        print(f"FAIL: interior avg unique colors {ic:.1f} < {MIN_AVG_COLORS} (placeholder PIL art)")
        failed = True
    if ie < MIN_AVG_EDGE:
        print(f"FAIL: interior avg edge {ie:.1f} < {MIN_AVG_EDGE}")
        failed = True
    if not failed:
        print("PASS")
        return 0
    print("See docs/INTERIOR_DIAGNOSIS.md")
    return 1


if __name__ == "__main__":
    sys.exit(main())
