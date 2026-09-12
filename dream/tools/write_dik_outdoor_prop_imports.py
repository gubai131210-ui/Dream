#!/usr/bin/env python3
from __future__ import annotations

import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
TMPL = (PROPS / "crate_0.png.import").read_text(encoding="utf-8")
NAMES = [
	"handcart_00.png",
	"fruit_crate_stack_00.png",
	"hay_stack_00.png",
	"hay_00.png",
	"trough_00.png",
	"wood_pile_00.png",
	"anvil_00.png",
	"stove_00.png",
	"grain_stack_00.png",
	"flower_bed_00.png",
	"herbs_00.png",
	"lantern_string_00.png",
	"coin_chest_00.png",
]


def main() -> None:
	for name in NAMES:
		if not (PROPS / name).exists():
			raise SystemExit(f"missing {name}")
		text = TMPL.replace("crate_0.png", name)
		uid = "uid://p" + uuid.uuid4().hex[:12]
		lines = []
		for line in text.splitlines(True):
			if line.startswith("uid="):
				lines.append(f'uid="{uid}"\n')
			else:
				lines.append(line)
		(PROPS / f"{name}.import").write_text("".join(lines), encoding="utf-8")
		print("wrote", name + ".import")


if __name__ == "__main__":
	main()
