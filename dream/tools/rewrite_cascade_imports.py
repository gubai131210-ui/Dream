#!/usr/bin/env python3
"""Rewrite .import sidecars for cascade redraw assets."""
from __future__ import annotations

import hashlib
import re
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMPL = (ROOT / "assets/sprites/props/waterfall_tall_00.png.import").read_text(encoding="utf-8")

FILES = [
	ROOT / "assets/sprites/props/cascade_cliff_mouth_v1.png",
	ROOT / "assets/sprites/props/cascade_vines_00.png",
	ROOT / "assets/sprites/props/cascade_fern_00.png",
	ROOT / "assets/sprites/props/cascade_moss_rock_00.png",
	ROOT / "assets/sprites/props/cascade_bench_00.png",
	ROOT / "assets/sprites/fx/cascade_mist_00.png",
	ROOT / "assets/sprites/fx/cascade_splash_ring_00.png",
] + [ROOT / f"assets/sprites/props/waterfall_water_{i:02d}.png" for i in range(6)]


def main() -> None:
	for path in FILES:
		name = path.name
		folder = path.parent.name
		uid = "uid://c" + uuid.uuid4().hex[:13]
		h = hashlib.md5(path.as_posix().encode()).hexdigest()
		ctex = f"{name}-{h}.ctex"
		text = TMPL.replace("waterfall_tall_00.png", name)
		text = text.replace("res://assets/sprites/props/", f"res://assets/sprites/{folder}/")
		text = re.sub(r"waterfall_tall_00\.png-[a-f0-9]+\.ctex", ctex, text)
		text = re.sub(r'uid://[^"\n]+', uid, text, count=1)
		text = re.sub(r"\.godot/imported/[^\"]+", f".godot/imported/{ctex}", text)
		(path.parent / f"{name}.import").write_text(text, encoding="utf-8")
		print(f"import {folder}/{name} {uid}")


if __name__ == "__main__":
	main()
