#!/usr/bin/env python3
"""Alias B11-02 crate cuts to semantic prop names for C05."""
from __future__ import annotations

import shutil
import uuid
from pathlib import Path

PROPS = Path(__file__).resolve().parents[1] / "assets" / "sprites" / "props"

PAIRS = [
	("produce_crate_00.png", "B11-02_crates_boxes_06.png"),
	("stall_face_00.png", "B11-02_crates_boxes_04.png"),
	("lumber_stack_00.png", "B11-02_crates_boxes_10.png"),
	("stall_bin_base_00.png", "B11-02_crates_boxes_03.png"),
]


def main() -> None:
	for name, old in PAIRS:
		src = PROPS / old
		dst = PROPS / name
		shutil.copy2(src, dst)
		tmpl = (PROPS / f"{old}.import").read_text(encoding="utf-8")
		text = tmpl.replace(old, name)
		uid = "uid://c" + uuid.uuid4().hex[:12]
		lines = []
		for line in text.splitlines(True):
			if line.startswith("uid="):
				lines.append(f'uid="{uid}"\n')
			else:
				lines.append(line)
		(PROPS / f"{name}.import").write_text("".join(lines), encoding="utf-8")
		print(f"aliased {old} -> {name} ({dst.stat().st_size} bytes)")


if __name__ == "__main__":
	main()
