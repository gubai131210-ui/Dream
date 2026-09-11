#!/usr/bin/env python3
"""Quantitative helpers for interior-visual-qa skill.

Usage (PowerShell):
  python dream/.cursor/skills/interior-visual-qa/scripts/qa_interior_visual.py
  python .../qa_interior_visual.py --pair a.png b.png
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[4]  # dream/
PROP = ROOT / "assets" / "sprites" / "interior" / "props"

# Expected scene-fit lamps (name → must exist)
LAMP_MATRIX = {
	"lamp_indoor_00.png": "homes",
	"lamp_farm_00.png": "barn/coop",
	"lamp_shop_00.png": "grocery",
	"lamp_smith_00.png": "smith",
	"lamp_tavern_00.png": "tavern",
}

FAMILIES = {
	"pen": [
		"pen_fence_00.png",
		"pen_fence_v_00.png",
		"pen_corner_nw_00.png",
		"pen_corner_ne_00.png",
		"pen_corner_sw_00.png",
		"pen_corner_se_00.png",
	],
	"stall": [
		"stall_rail_00.png",
		"stall_rail_v_00.png",
		"stall_corner_nw_00.png",
		"stall_corner_ne_00.png",
		"stall_corner_sw_00.png",
		"stall_corner_se_00.png",
	],
	"dining": ["table_dining_00.png", "stool_00.png"],
	"tea": ["table_round_00.png", "stool_tea_00.png"],
}


def load_rgba(path: Path) -> np.ndarray:
	return np.array(Image.open(path).convert("RGBA"))


def alpha_bbox(a: np.ndarray, t: int = 16) -> tuple[int, int, int, int] | None:
	ys, xs = np.where(a[:, :, 3] > t)
	if len(xs) == 0:
		return None
	return int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())


def stats(path: Path) -> dict:
	a = load_rgba(path)
	bb = alpha_bbox(a)
	opaque = a[:, :, 3] > 16
	out: dict = {
		"file": path.name,
		"canvas": [int(a.shape[1]), int(a.shape[0])],
		"exists": True,
	}
	if bb is None:
		out["empty"] = True
		return out
	x0, y0, x1, y1 = bb
	out["bbox_wh"] = [x1 - x0 + 1, y1 - y0 + 1]
	pix = a[opaque][:, :3].astype(np.float32)
	out["palette_mean"] = [round(float(x), 1) for x in pix.mean(axis=0)]
	out["palette_std"] = [round(float(x), 1) for x in pix.std(axis=0)]
	out["opaque_px"] = int(opaque.sum())
	return out


def palette_distance(a: Path, b: Path) -> float:
	sa, sb = stats(a), stats(b)
	if "palette_mean" not in sa or "palette_mean" not in sb:
		return 999.0
	va = np.array(sa["palette_mean"])
	vb = np.array(sb["palette_mean"])
	return float(np.linalg.norm(va - vb))


def family_report(name: str, files: list[str]) -> dict:
	paths = [PROP / f for f in files]
	missing = [p.name for p in paths if not p.exists()]
	present = [p for p in paths if p.exists()]
	heights = []
	for p in present:
		s = stats(p)
		if "bbox_wh" in s:
			heights.append(s["bbox_wh"][1])
	dist = None
	if len(present) >= 2:
		dist = round(palette_distance(present[0], present[1]), 2)
	return {
		"family": name,
		"missing": missing,
		"height_span": [min(heights), max(heights)] if heights else None,
		"palette_dist_01": dist,
		"warn_height_span": bool(heights) and (max(heights) - min(heights) > 24),
		"warn_palette": dist is not None and dist > 45.0,
	}


def main() -> None:
	ap = argparse.ArgumentParser()
	ap.add_argument("--pair", nargs=2, metavar=("A", "B"), help="palette distance between two PNGs")
	ap.add_argument("--json", action="store_true")
	args = ap.parse_args()

	if args.pair:
		a, b = Path(args.pair[0]), Path(args.pair[1])
		print(json.dumps({"palette_l2": round(palette_distance(a, b), 2), "a": stats(a), "b": stats(b)}, indent=2))
		return

	report = {
		"lamps": {n: (PROP / n).exists() for n in LAMP_MATRIX},
		"families": [family_report(k, v) for k, v in FAMILIES.items()],
		"dining_stool_vs_table": None,
	}
	td, st = PROP / "table_dining_00.png", PROP / "stool_00.png"
	if td.exists() and st.exists():
		ht = stats(td).get("bbox_wh", [0, 0])[1]
		hs = stats(st).get("bbox_wh", [0, 0])[1]
		report["dining_stool_vs_table"] = {
			"table_h": ht,
			"stool_h": hs,
			"ok_stool_shorter": hs < ht,
			"palette_l2": round(palette_distance(td, st), 2),
		}

	text = json.dumps(report, indent=2, ensure_ascii=False)
	if args.json:
		print(text)
	else:
		print(text)
		fails = []
		for n, ok in report["lamps"].items():
			if not ok:
				fails.append(f"missing lamp {n}")
		for fam in report["families"]:
			if fam["missing"]:
				fails.append(f"{fam['family']} missing {fam['missing']}")
			if fam.get("warn_palette"):
				fails.append(f"{fam['family']} palette_dist high ({fam['palette_dist_01']})")
			if fam.get("warn_height_span"):
				fails.append(f"{fam['family']} height_span large ({fam['height_span']})")
		dst = report.get("dining_stool_vs_table") or {}
		if dst and not dst.get("ok_stool_shorter", True):
			fails.append("stool taller than dining table bbox")
		print("VERDICT:", "FAIL" if fails else "PASS")
		for f in fails:
			print("-", f)


if __name__ == "__main__":
	main()
