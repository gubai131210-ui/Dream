#!/usr/bin/env python3
"""Rewrite broken Wave E prop .import sidecars to match Godot texture import format."""
from __future__ import annotations

import hashlib
from pathlib import Path

PROP_DIR = Path(__file__).resolve().parents[1] / "assets" / "sprites" / "interior" / "props"
NAMES = [
	"balcony_rail_00",
	"cheese_aging_00",
	"clothesline_00",
	"cobweb_00",
	"doghouse_00",
	"pickle_crock_00",
	"trunk_old_00",
	"wine_rack_00",
	"wood_pile_00",
]


def main() -> None:
	template = (PROP_DIR / "counter_00.png.import").read_text(encoding="utf-8")
	params = template.split("[params]")[1]
	for name in NAMES:
		src = f"res://assets/sprites/interior/props/{name}.png"
		digest = hashlib.md5(src.encode("utf-8")).hexdigest()
		uid = "uid://" + hashlib.md5(f"{name}-wavee".encode()).hexdigest()[:13]
		ctex = f"res://.godot/imported/{name}.png-{digest}.ctex"
		content = (
			"[remap]\n\n"
			'importer="texture"\n'
			'type="CompressedTexture2D"\n'
			f'uid="{uid}"\n'
			f'path="{ctex}"\n'
			"metadata={\n"
			'"vram_texture": false\n'
			"}\n\n"
			"[deps]\n\n"
			f'source_file="{src}"\n'
			f'dest_files=["{ctex}"]\n\n'
			"[params]\n"
			f"{params}"
		)
		out = PROP_DIR / f"{name}.png.import"
		out.write_text(content, encoding="utf-8", newline="\n")
		head = content.split("[deps]")[0]
		assert "metadata={{" not in head
		assert "false\n}}" not in head
		print(f"rewrote {name} -> {digest}")


if __name__ == "__main__":
	main()
